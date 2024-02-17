# WS2812 LED

## Specification
You are tasked with designing a controller for an LED intended to be used in a cascaded chain (see [Cascade Description](#cascade-description) diagram below). Codes are transmitted to the LED, which uses the first one received as its code and passes on additional codes to LEDs further along the chain until a reset signal is received, where the process begins again. Protocol and timing details are provided below and in linked datasheet.
<!-- language: lang-none -->
                 ------------------
                 | led_controller |
                 |                |---- o_serial
    i_serial ----|                |
                 |                |---- o_led
                 |                |
                 ------------------
The serial stream you are to decode is described in detail
[here](https://cdn-shop.adafruit.com/datasheets/WS2812.pdf).

#### Serial Stream Symbols
<!-- language: lang-none -->
         one coding               zero coding              Ret coding
    -------------       |    ---------           |    |                  |
    |           |       |    |       |           |    |                  |
    |<-- T1H -->|<-T1L->|    |<-T0H->|<-- T0L -->|    |<---  Treset  --->|
    |           |       |    |       |           |    |                  |
    |           ---------    |       -------------    --------------------

| symbol   | time           | margin     |
|:--------:|:--------------:|:----------:|
| T1H      | 0.7 &mu;s      | +/- 150 ns |
| T1L      | 0.6 &mu;s      | +/- 150 ns |
| T0H      | 0.35 &mu;s     | +/- 150 ns |
| T0L      | 0.8 &mu;s      | +/- 150 ns |
| Treset   | above 50 &mu;s |            |

#### Cascade Description
<!-- language: lang-none -->
         -----------        -----------        -----------
         |         |        |         |        |         |
    D1-->|in    out|-->D2-->|in    out|-->D3-->|in    out|-->D4
         |         |        |         |        |         |
         |  LED1   |        |  LED2   |        |  LED3   |
         -----------        -----------        -----------

#### Data Transmission
<!-- language: lang-none -->
        |<- Data cycle 1 ->|                |<- Data cycle 2 ->|
        |                  |<-- ret code -->|                  |
        |------------------|     50 us      |------------------|
    D1--|first|second|third|________________|first|second|third|
        |------------------|                |------------------|
        |                  |                |                  |
        |     -------------|                |     -------------|
    D2--|_____|second|third|________________|_____|second|third|
        |     -------------|                |     -------------|
        |                  |                |                  |
        |            ------|                |            ------|
    D3--|____________|third|________________|____________|third|
        |            ------|                |            ------|
        |                  |                |                  |
        |                  |                |                  |
    D4--|__________________|                |__________________|
        |                  |                |                  |
note: each word is 24 bits in length, the serial stream is sent in to module D1,
      which then daisy chains data to D2, etc... Also note that the bits are
      sent MSB first.

#### Task
You are to design the `led` module in order to meet the above specification. Note the complete, decoded LED word should appear on o_led once it is fully received and should persist until the next full word is decoded.

We have provided you some basic test benches to test your design. However, you should modify them or add additional tests as reqiured to prove your module's functionality. To run the tests, you may need to install `iverilog` and `gtkwave` to view the vcd files.
