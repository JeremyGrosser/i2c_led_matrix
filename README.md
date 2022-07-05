This is a quick and dirty demo of an I2C target device using the new RP.I2C interface.

It expects a write of 32 bytes containing pixel data for [4 8x8 LED matrix panels with MAX7219 drivers](https://www.amazon.com/HiLetgo-MAX7219-Arduino-Microcontroller-Display/dp/B07FFV537V/?tag=synack-20), which it then writes out to a display over SPI.
