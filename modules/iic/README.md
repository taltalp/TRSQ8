# IIC module for TRSQ8 

## REGISTERS
|Address|Name     |aboue                 |
|:------|:--------|:---------------------|
|0x00   |IICCON   |iic control registers |
|0x01   |IICCLKDIV|iic clock divider     |
|0x02   |IICTX    |TX register           |
|0x03   |IICRX    |RX register           |

## IICCON
|Bit|Name     |about                   |
|:-:|:--------|:-----------------------|
|7  |reserved |                        |
|6  |reserved |                        |
|5  |reserved |                        |
|4  |stop     |generate stop condition |
|3  |start    |generate start condigion|
|2  |rw       |1:read, 0:write         |
|1  |sending  |in transaction          |
|0  |busy     |iic is busy             |
