--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with MAX7219; use MAX7219;
with HAL; use HAL;

package body LED_Matrix is
   procedure Initialize
      (This : in out Chain)
   is
   begin
      Write (This.Device, Shutdown, 1, This.Length);
      Write (This.Device, Display_Test, 0, This.Length);
      Write (This.Device, Intensity, 8, This.Length);
      Write (This.Device, Scan_Limit, 2#111#, This.Length);
      Write (This.Device, Decode_Mode, 0, This.Length);
   end Initialize;

   procedure Clear
      (This : in out Chain)
   is
   begin
      This.Data := (others => 0);
   end Clear;

   procedure Update
      (This : in out Chain)
   is
   begin
      MAX7219.Write (This.Device, This.Data);
   end Update;

   procedure Set_Pixel
      (This         : in out Chain;
       Device_Index : Positive;
       X, Y         : Coordinate;
       Value        : Boolean)
   is
      Mask : constant Pixel_Data := MAX7219.Shift_Left (1, (Y * 8) + (7 - X));
   begin
      if Value then
         This.Data (Device_Index) := This.Data (Device_Index) or Mask;
      else
         This.Data (Device_Index) := This.Data (Device_Index) and not Mask;
      end if;
   end Set_Pixel;

   procedure Set_Pixel
      (This  : in out Chain;
       X, Y  : Coordinate;
       Value : Boolean)
   is
      Device_Index : constant Positive := (X / 8) + 1;
   begin
      Set_Pixel (This,
         Device_Index => Device_Index,
         X            => X mod 8,
         Y            => Y,
         Value        => Value);
   end Set_Pixel;

   function Width
      (This : Chain)
      return Natural
   is (This.Length * 8);

   function Height
      (This : Chain)
      return Natural
   is (8);
end LED_Matrix;
