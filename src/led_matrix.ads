--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL.Time;
with HAL.GPIO;
with HAL.SPI;

with MAX7219;

package LED_Matrix is
   type Chain
      (Port   : HAL.SPI.Any_SPI_Port;
       CS     : HAL.GPIO.Any_GPIO_Point;
       Delays : HAL.Time.Any_Delays;
       Length : Positive)
   is tagged record
      Device : MAX7219.Device (Port, CS, Delays);
      Data   : MAX7219.Pixel_Array (1 .. Length);
   end record;

   subtype Coordinate is Natural;

   procedure Initialize
      (This : in out Chain);

   procedure Update
      (This : in out Chain);

   procedure Clear
      (This : in out Chain);

   procedure Set_Pixel
      (This         : in out Chain;
       Device_Index : Positive;
       X, Y         : Coordinate;
       Value        : Boolean)
       with Pre => Device_Index <= This.Length and then
                   X < 8 and then
                   Y < 8;

   procedure Set_Pixel
      (This  : in out Chain;
       X, Y  : Coordinate;
       Value : Boolean)
       with Pre => X < Width (This) and then
                   Y < Height (This);

   function Width
      (This : Chain)
      return Natural;

   function Height
      (This : Chain)
      return Natural;

end LED_Matrix;
