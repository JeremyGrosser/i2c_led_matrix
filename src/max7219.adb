--
--  Copyright 2021 (C) Jeremy Grosser
--
--  SPDX-License-Identifier: BSD-3-Clause
--
package body MAX7219 is
   tCSS : constant := 4;
   tCSW : constant := 2;

   procedure Write
      (This    : in out Device;
       Address : Register;
       Data    : UInt8;
       Repeat  : Positive := 1)
   is
      D      : SPI_Data_16b (1 .. 1);
      Status : SPI_Status;
   begin
      This.Latch.Clear;
      This.Delays.Delay_Microseconds (tCSS);
      D (1) := Shift_Left (UInt16 (Register'Pos (Address)), 8) or UInt16 (Data);
      for I in 1 .. Repeat loop
         This.Port.Transmit (D, Status);
      end loop;
      This.Delays.Delay_Microseconds (tCSW);
      This.Latch.Set;
      This.Delays.Delay_Microseconds (tCSS);
   end Write;

   procedure Write
      (This  : in out Device;
       Data  : Pixel_Array)
   is
      Commands : SPI_Data_16b (Data'Range);
      Status   : SPI_Status;
   begin
      for Row in 0 .. 7 loop
         This.Latch.Clear;
         This.Delays.Delay_Microseconds (tCSS);
         for Device_Index in Commands'Range loop
            Commands (Device_Index) := Shift_Left (UInt16 (Row + 1), 8) or
               UInt16 (Shift_Right (Data (Device_Index), Row * 8) and 16#FF#);
         end loop;
         This.Port.Transmit (Commands, Status);
         This.Delays.Delay_Microseconds (tCSW);
         This.Latch.Set;
         This.Delays.Delay_Microseconds (tCSS);
      end loop;
   end Write;

end MAX7219;
