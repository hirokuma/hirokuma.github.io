---
layout: "record"
title: "値の表現"
tags:
  - bitcoin
daily: false
date: "2024/12/11"
---

数値は 2の補数の little endian で表す。  
固定長の場合はそのバイト数のデータ型、可変長は Compact Size型が使われている。

* [CompactSize Unsigned Integers](https://developer.bitcoin.org/reference/transactions.html#compactsize-unsigned-integers)
* [Variable length integer](https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer)

Compact Size型はあまり見慣れないと思う。  
例えば `0xfc` までなら 1バイトでそのまま表現できるが、`0xfd` は `0xfdfd00`(little endian)になる。  
データ長を表すのに使われることがほとんどだと思う。

* `0x00 - 0xfc`
  * 長さ: `0x00` - `0xfc`
  * 変換: そのまま `uint8_t` にする
* `0xfdfd00 - 0xfdffff`
  * 長さ: `0xfd` - `0xffff`
  * 変換: 先頭の `fd` は捨て、残り 2byte を `uint16_t` にする
* `0xfe00000100 - 0xfeffffffff`
  * 長さ: `0x010000` - `0xffffffff`
  * 変換: 先頭の `fe` は捨て、残り 4byte を `uint32_t` にする
* `0xff0000000001000000 - 0xffffffffffffffffff`
  * 長さ: `0x0100000000` - `0xffffffffffffffff`
  * 変換: 先頭の `ff` は捨て、残り 8byte を `uint64_t` にする

[gist](https://gist.github.com/hirokuma/fc5476f1bcf310863428883c1d47c7d5)

```c
uint64_t varint(const uint8_t *p_varint)
{
    uint64_t val;
    if (p_varint[0] < 0xfd) {
        val = p_varint[0];
    } else if (p_varint[0] == 0xfd) {
        val = ((uint16_t)p_varint[2] << 8) | (uint16_t)p_varint[1];
    } else if (p_varint[0] == 0xfe) {
        val = ((uint32_t)p_varint[4] << 24) |
              ((uint32_t)p_varint[3] << 16) |
              ((uint32_t)p_varint[2] <<  8) |
               (uint32_t)p_varint[1];
    } else {
        val = ((uint64_t)p_varint[8] << 56) |
              ((uint64_t)p_varint[7] << 48) |
              ((uint64_t)p_varint[6] << 40) |
              ((uint64_t)p_varint[5] << 32) |
              ((uint64_t)p_varint[4] << 24) |
              ((uint64_t)p_varint[3] << 16) |
              ((uint64_t)p_varint[2] <<  8) |
               (uint64_t)p_varint[1];
    }
    return val;
}
```

## `VarInt`, `varint`, `var_int`

Compact Size型という名称だが、BIP には `VarInt` や `varint` もあれば `var_int` として書かれているところもある。  
[GitHub の BIP](https://github.com/bitcoin/bips) を検索したところこういう状況だった。  
あまり区別されていないようなので、Bitcoin 関連でこれらの型が出てきたらだいたい Compact Size型だと思ってよいのではなかろうか。

* `var_int` が使われている BIP
  * [BIP-36](https://github.com/bitcoin/bips/blob/7420c04e841ec6617029ed0df316a52d78116b27/bip-0036.mediawiki#L29)
  * [BIP-141](https://github.com/bitcoin/bips/blob/7420c04e841ec6617029ed0df316a52d78116b27/bip-0141.mediawiki#L59)
  * [BIP-144](https://github.com/bitcoin/bips/blob/7420c04e841ec6617029ed0df316a52d78116b27/bip-0144.mediawiki#L51)
* `VarInt`/`varint` が使われている BIP
  * BIP-10
  * BIP-23
  * BIP-37
  * BIP-98
  * BIP-154
  * BIP-180
  * BIP-337

スクリプトの中に数値が使われる場合は命令と組み合わせて使うため Compact Size型とは別の表現になる([Constants](https://en.bitcoin.it/wiki/Script#Constants))。  
LevelDBに[VarInt](https://learnmeabitcoin.com/technical/general/compact-size/#varint)があるが、あれとは関係ない。

## 関連ページ

* [トランザクション](./transactions.md)
* [スクリプト](./script.md)
