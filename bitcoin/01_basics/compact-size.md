# Compact Size型

固定長の場合はそのバイト数のデータ型、可変長は Compact Size型が使われている。

[Compact Size型](https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer)はあまり見慣れないと思う。  
例えば `0xfc` までなら 1バイトでそのまま表現できるが、`0xfd` は `0xfdfd00`(little endian)になる。
`var_int`, `VarInt` と呼ばれることもあるが[厳密には異なる](https://learnmeabitcoin.com/technical/general/compact-size/#varint)とのこと。  
