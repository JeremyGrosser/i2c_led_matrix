--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with RP2040_SVD.I2C;
with RP.I2C;

with HAL.SPI;
with RP.SPI;

with RP.Timer; use RP.Timer;
with RP.GPIO; use RP.GPIO;
with HAL; use HAL;
with RP.Clock;
with RP.Device;
with Pico;
with LED_Matrix;

procedure I2c_Led_Matrix is
   SDA  : GPIO_Point renames Pico.GP0;
   SCL  : GPIO_Point renames Pico.GP1;
   Port : aliased RP.I2C.I2C_Port (0, RP2040_SVD.I2C.I2C0_Periph'Access);
   Addr : constant UInt7 := 16#3C#;

   SCK  : GPIO_Point renames Pico.GP2;
   MOSI : GPIO_Point renames Pico.GP3;
   CS   : GPIO_Point renames Pico.GP5;
   SPI  : RP.SPI.SPI_Port renames RP.Device.SPI_0;
   SPI_Config : constant RP.SPI.SPI_Configuration :=
      (Role       => RP.SPI.Master,
       Baud       => 1_000_000,
       Data_Size  => HAL.SPI.Data_Size_16b,
       others     => <>);
   M : LED_Matrix.Chain
      (Port    => SPI'Access,
       CS      => CS'Access,
       Delays  => RP.Device.Timer'Access,
       Length  => 4);

   use type RP.I2C.I2C_Status;
   Status   : RP.I2C.I2C_Status;
   Deadline : Time;
   Data     : UInt8_Array (1 .. M.Data'Size / 8)
      with Address => M.Data'Address;

   Started : Boolean := False;
   I : Integer := Data'First;
begin
   RP.Clock.Initialize (Pico.XOSC_Frequency);
   RP.Device.Timer.Enable;
   Pico.LED.Configure (Output);
   Pico.LED.Clear;

   SCK.Configure (Output, Pull_Up, RP.GPIO.SPI);
   CS.Configure (Output, Pull_Up);
   MOSI.Configure (Output, Pull_Up, RP.GPIO.SPI);
   SPI.Configure (SPI_Config);
   M.Initialize;
   M.Clear;
   M.Set_Pixel (Device_Index => 1, X => 0, Y => 0, Value => True);
   M.Update;

   SDA.Configure (Output, Pull_Up, RP.GPIO.I2C, Schmitt => True);
   SCL.Configure (Output, Pull_Up, RP.GPIO.I2C, Schmitt => True);
   Port.Configure ((Role => RP.I2C.Target, Timing => RP.I2C.Standard_Mode));
   Port.Set_Address (Addr);

   while not Port.Enabled loop
      Port.Clear_Error;
      Port.Enable;
   end loop;

   Deadline := Clock;
   loop
      Deadline := Deadline + Milliseconds (1_000);

      if not Started then
         Port.Start_Read (Data'Length);
         I := Data'First;
         Started := True;
      elsif I > Data'Last then
         M.Update;
         Started := False;
      elsif Port.Read_Ready then
         Port.Read (Data (I), Status, Deadline);
         if Status /= RP.I2C.Ok then
            Started := False;
         else
            I := I + 1;
         end if;
      elsif Port.State.Is_Error then
         Port.Clear_Error;
         Started := False;
      end if;
   end loop;
end I2c_Led_Matrix;
