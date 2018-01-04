# SPI module for TRSQ8 

## REGISTERS
|Address|Name     |about                |
|:------|:--------|:--------------------|
|0x00   |SPICON   |spi control registers|
|0x01   |SPICLKDIV|spi clock divider    |
|0x02   |SPITX    |TX register          |
|0x03   |SPIRX    |RX register          |

## SPICON register
|Bit|Name      |about                      |
|:-:|:---------|:--------------------------|
|7  |reserved  |                           |
|6  |reserved  |                           |
|5  |reserved  |                           |
|4  |spi enable|enable spi module          |
|3  |cont      |continuous transaction mode|
|2  |cpha      |clock phase                |
|1  |cpol      |clock polarity             |
|0  |spi busy  |spi module is busy         |

## SPICLKDIV register
This is a reserved register.

## SPITX register

## SPIRX register
