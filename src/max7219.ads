--
--  Copyright 2021 (C) Jeremy Grosser
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL.Time; use HAL.Time;
with HAL.GPIO; use HAL.GPIO;
with HAL.SPI;  use HAL.SPI;
with HAL;      use HAL;

package MAX7219 is
   type Register is
      (No_Op, D0, D1, D2, D3, D4, D5, D6, D7,
       Decode_Mode, Intensity, Scan_Limit, Shutdown, Display_Test);
   subtype Digit is Register range D0 .. D7;

   --  Row-major order 8x8
   subtype Pixel_Data is UInt64;
   type Pixel_Array is array (Positive range <>) of Pixel_Data;

   type Device
      (Port   : Any_SPI_Port;
       Latch  : Any_GPIO_Point;
       Delays : Any_Delays)
   is null record;

   procedure Write
      (This    : in out Device;
       Address : Register;
       Data    : UInt8;
       Repeat  : Positive := 1);

   procedure Write
      (This : in out Device;
       Data : Pixel_Array);

   function Shift_Left
      (Value  : Pixel_Data;
       Amount : Natural)
       return Pixel_Data;

   function Shift_Right
      (Value  : Pixel_Data;
       Amount : Natural)
       return Pixel_Data;

   pragma Import (Intrinsic, Shift_Left);
   pragma Import (Intrinsic, Shift_Right);

end MAX7219;
