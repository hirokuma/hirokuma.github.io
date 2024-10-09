# トランザクション

<i>最終更新日: 2024/10/08</i>

## はじめに

Bitcoinトランザクションには署名の方法などによる違いはあるが、データの構成は決まっている。

### 構成

* 参照
  * [Raw Transaction Format](https://developer.bitcoin.org/reference/transactions.html#raw-transaction-format)
  * [BIP-144 Serialization](https://github.com/bitcoin/bips/blob/83a1afd9859848628645c7fa200beb0dc0aea4f5/bip-0144.mediawiki#user-content-Serialization)

Bitcoinトランザクションはバイナリデータである。  
以下はバイナリデータを構成している要素の名前である。
この名前は解説しているサイトによって多少違う(`version`が`nVersion`だったり`lock_time`が`LockTime`だったり)が、

* `version`
* `marker`, `flag` (存在しない場合あり)
* `txin_count`
* `txins[]`
  * `txid:index`(out_point)
  * `scriptSig`
  * `sequence`
* `txout_count`
* `txouts[]`
  * `value`
  * `scriptPubKey`
* `script_witnesses[]` (存在しない場合あり)
* `lock_time`

先頭から 5byte目のデータで見分ける。  
segwit(witness)のトランザクションの場合、その位置に`0x00`が入っている。その場合は `maker(0x00)`と`flag(0x01)`が並んでいる。  
それ以外の場合は segwit非対応のトランザクションで、`marker`と`flag`がなく 5byte 目から`txin_count`のデータが入っている。

[Serialization](https://github.com/bitcoin/bips/blob/83a1afd9859848628645c7fa200beb0dc0aea4f5/bip-0144.mediawiki#user-content-Serialization)の表に "Type" 列があるが、これがそれぞれのデータタイプである。  
`txins[]`, `txouts[]`, `script_witnesses[]` はさらにデータ構造がある。  

下に例としていくつか raw transaction(生のトランザクションバイナリデータ)を分解する。  
"`<script～>`" となっている項目は、先頭がデータ長でその後ろにデータ長分のデータが続いている。  
"`<script_witnesses>`" は少し特殊で、全体の数は `<txin_count>`で、それぞれスクリプトの個数とスクリプトが続いている。

#### 値の表現

値については 2の補数の little endian。  
固定長の場合はそのバイト数のデータ型、可変長は Compact Size型が使われている。

[Compact Size型](https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer)はあまり見慣れないと思う。  
例えば `0xfc` までなら 1バイトでそのまま表現できるが、`0xfd` は `0xfdfd00`(little endian)になる。
`var_int`, `VarInt` と呼ばれることもあるが[厳密には異なる](https://learnmeabitcoin.com/technical/general/compact-size/#varint)とのこと。  

ちなみにスクリプトの中に数値が使われる場合は命令と組み合わせて使うため別の表現になる([Constants](https://en.bitcoin.it/wiki/Script#Constants))。

#### 例1: 非segwit

[a1d0efa306442b1b7b82535e3531407ab5916f9adb0761afc5b83bfdbbdcda70](https://mempool.space/ja/testnet/tx/a1d0efa306442b1b7b82535e3531407ab5916f9adb0761afc5b83bfdbbdcda70)

```bin
<全 raw transaction データ>
01000000016e74e6814a1e0eafc9a80c8589b705f8d6791cd7a401e6046d53c38f75daae5d01000000fdfd000047304402205c97e03a51c148a15e444578e0efce7b39731f0672f5bd7ecc473810e1e1e5ec02207ca1ea0b93fd7a9a61966ab37bb3ae2d29240ee79eeb70df3660d3f47c371c5901483045022100c02f853575468daf9fbc667d1331aea792f2709ed576b6a9fe416ecb27bc0dc70220519884f5a2c39c03eab6f073a5dde4a08ef6090908a0ed14a068e30ca90c62c9014c695221021edb59dffb17e9cc4c70cc68890125216ad5a8062879be20430600138c87e0422102bae72de833cc5914d0f19a959836245d7e1b8dc0b168f289a01acdcffc02a73e2103af0b0289d979fca04aa1bb1eef1325d4dd8fbddc690297d81811c5282841f1d453aeffffffff0200911c500200000017a91401e2f991b1d8d904eea641d7971c9eee6a4e72588740420f000000000017a914e031febb6904a7e7b8192b78ab1fc6572e8d585b8700000000
--------------------------
<version>
01000000

<txin_count>
01

<txins[0]>
  <txid:index>
  6e74e6814a1e0eafc9a80c8589b705f8d6791cd7a401e6046d53c38f75daae5d01000000
  <scriptSig>
  fdfd000047304402205c97e03a51c148a15e444578e0efce7b39731f0672f5bd7ecc473810e1e1e5ec02207ca1ea0b93fd7a9a61966ab37bb3ae2d29240ee79eeb70df3660d3f47c371c5901483045022100c02f853575468daf9fbc667d1331aea792f2709ed576b6a9fe416ecb27bc0dc70220519884f5a2c39c03eab6f073a5dde4a08ef6090908a0ed14a068e30ca90c62c9014c695221021edb59dffb17e9cc4c70cc68890125216ad5a8062879be20430600138c87e0422102bae72de833cc5914d0f19a959836245d7e1b8dc0b168f289a01acdcffc02a73e2103af0b0289d979fca04aa1bb1eef1325d4dd8fbddc690297d81811c5282841f1d453aeff
  <sequence>
  ffffff

<txout_count>
02

<txouts[0]>
  <value>
  00911c5002000000
  <scriptPubkey>
  17a91401e2f991b1d8d904eea641d7971c9eee6a4e725887

<txouts[1]>
  <value>
  40420f0000000000
  <scriptPubkey>
  17a914e031febb6904a7e7b8192b78ab1fc6572e8d585b87

<lock_time>
00000000
```

#### 例2: segwit

[0931d995f2e84b610bfcc6e5a960dea3baee16229c156518d7fbaee4141d14ef](https://mempool.space/ja/testnet/tx/0931d995f2e84b610bfcc6e5a960dea3baee16229c156518d7fbaee4141d14ef)

```bin
<全 raw transaction データ>
01000000000101064c370388c7bb573fb574983e8f5740f697f45dba4dc96a16b2e31ea9034a070100000000ffffffff02314a0d00000000001600144c6a32c4a3344daf0fdc12e9202287786e5ac882e09304000000000016001468a211ede685d089ce170065948aa80790e00f9e0247304402201b3913c5ee01d6ceff87a861f8554ced9e99e281884530fd7828a50099cedad202204b641d827fcfb7c1cfd5cb7bbc4379b50f75531f063b814f4998b3507eea3033012103ec5f3495edf84da8d308bb59802a25baebab382a3c1fdccdc3462685ab09b73200000000
--------------------------
<version>
01000000

<marker, flag>
0001

<txin_count>
01

<txin[0]>
  <txid:index>
  064c370388c7bb573fb574983e8f5740f697f45dba4dc96a16b2e31ea9034a0701000000
  <scriptSig>
  00
  <sequence>
  ffffffff

<txout_count>
02

<txouts[0]>
  <value>
  314a0d0000000000
  <scriptPubkey>
  1600144c6a32c4a3344daf0fdc12e9202287786e5ac882

<txouts[1]>
  <value>
  e093040000000000
  <scriptPubkey>
  16001468a211ede685d089ce170065948aa80790e00f9e

<script_witnesses>
  <txins[0]>
    <witness_count>
    02
    <witness[0]>
    47304402201b3913c5ee01d6ceff87a861f8554ced9e99e281884530fd7828a50099cedad202204b641d827fcfb7c1cfd5cb7bbc4379b50f75531f063b814f4998b3507eea303301
    <witness[1]>
    2103ec5f3495edf84da8d308bb59802a25baebab382a3c1fdccdc3462685ab09b732

<lock_time>
00000000
```

#### 例3: segwit

[026a8f0c6e6050cf237f42a7f2ed27efffead6c8750d991f746cef44448f3e2e](https://mempool.space/ja/testnet4/tx/026a8f0c6e6050cf237f42a7f2ed27efffead6c8750d991f746cef44448f3e2e)

```bin
<全 raw transaction データ>
010000000001020ae960ef2054fd508f59b52e0ef3c19f7d2e865927f9059ec3779e568d30e9bf0100000000ffffffffb4e0d2298e0413cdb98cce33f22b240affbbd6c6eff7e9ec6eae5e70855e25bf0100000000ffffffff01bbb00100000000002251205779bec9d3f59f7b7bbefa606a81f171b3996659642bdf83a3fee52149d25e7901408893d9c6381da9984762b7bdb89427c154da5906e07678da2f8f15de292b40858fa0065170e7bca5e72cf3ce623c64533a4229527c6565d41cfb1ba411f5c1f70140093c5d8bdfdc06e33cab1f1a76bfaf93f8b5bc0a8e7d8075a7f2443772ebf648d39cac8f7bcd545c0ddfa08e62146f3079dabb284a3d47dd11280509d5cc88da00000000
--------------------------
<version>
01000000

<marker, flag>
0001

<txin_count>
02

<txins[0]>
  <txid:index>
  0ae960ef2054fd508f59b52e0ef3c19f7d2e865927f9059ec3779e568d30e9bf01000000
  <scriptSig>
  00
  <sequence>
  ffffffff

<txins[1]>
  <txid:index>
  b4e0d2298e0413cdb98cce33f22b240affbbd6c6eff7e9ec6eae5e70855e25bf01000000
  <scriptSig>
  00
  <sequence>
  ffffffff

<txout_count>
01

<txouts[0]>
  <value>
  bbb0010000000000
  <scriptPubkey>
  2251205779bec9d3f59f7b7bbefa606a81f171b3996659642bdf83a3fee52149d25e79

<script_witnesses>
  <txins[0]>
    <witness_count>
    01
    <witness[0]>
    408893d9c6381da9984762b7bdb89427c154da5906e07678da2f8f15de292b40858fa0065170e7bca5e72cf3ce623c64533a4229527c6565d41cfb1ba411f5c1f7

  <txins[1]>
    <witness_count>
    01
    <witness[0]>
    40093c5d8bdfdc06e33cab1f1a76bfaf93f8b5bc0a8e7d8075a7f2443772ebf648d39cac8f7bcd545c0ddfa08e62146f3079dabb284a3d47dd11280509d5cc88da

<lock_time>
00000000
```

### TXID

個別のトランザクションを指し示すとき、通常は TXID(Transaction ID)を使う。  
データを SHA256 で 2回計算する。
データはトランザクションデータそのものではなく[こちら](https://github.com/bitcoin/bips/blob/83a1afd9859848628645c7fa200beb0dc0aea4f5/bip-0144.mediawiki#hashes)のようにデータを組む(非segwitの場合はそのまま使うことになる)。
図に出ている "Witness ID" はブロックデータを作る際に使われる。それ以外ではほぼ使われていないと思う。

計算すると 32byte のデータになる。  
例1に上げたトランザクションデータを使うと、こういう計算になる。  
[chiphereditor](https://ciphereditor.com/share#blueprint=eyJ0eXBlIjoiYmx1ZXByaW50IiwicHJvZ3JhbSI6eyJ0eXBlIjoicHJvZ3JhbSIsIm9mZnNldCI6eyJ4IjowLCJ5IjotMTAwfSwiZnJhbWUiOnsieCI6LTE2MCwieSI6LTk2LCJ3aWR0aCI6MzIwLCJoZWlnaHQiOjE5Mn0sImNoaWxkcmVuIjpbeyJ0eXBlIjoib3BlcmF0aW9uIiwibmFtZSI6IkBjaXBoZXJlZGl0b3IvZXh0ZW5zaW9uLWhhc2gvaGFzaCIsImV4dGVuc2lvblVybCI6Imh0dHBzOi8vY2RuLmNpcGhlcmVkaXRvci5jb20vZXh0ZW5zaW9ucy9AY2lwaGVyZWRpdG9yL2V4dGVuc2lvbi1oYXNoLzEuMC4wLWFscGhhLjEvZXh0ZW5zaW9uLmpzIiwicHJpb3JpdHlDb250cm9sTmFtZXMiOlsibWVzc2FnZSIsImFsZ29yaXRobSIsImhhc2giXSwiZnJhbWUiOnsieCI6LTE1NywieSI6LTQ3MCwid2lkdGgiOjMyMCwiaGVpZ2h0IjoyMzh9LCJjb250cm9scyI6eyJtZXNzYWdlIjp7InZhbHVlIjp7InR5cGUiOiJieXRlcyIsImRhdGEiOiJBUUFBQUFGdWRPYUJTaDRPcjhtb0RJV0p0d1g0MW5rYzE2UUI1Z1J0VThPUGRkcXVYUUVBQUFEOS9RQUFSekJFQWlCY2wrQTZVY0ZJb1Y1RVJYamc3ODU3T1hNZkJuTDF2WDdNUnpnUTRlSGw3QUlnZktIcUM1UDllcHBobG1xemU3T3VMU2trRHVlZTYzRGZObURUOUh3M0hGa0JTREJGQWlFQXdDK0ZOWFZHamErZnZHWjlFekd1cDVMeWNKN1ZkcmFwL2tGdXl5ZThEY2NDSUZHWWhQV2l3NXdENnJid2M2WGQ1S0NPOWdrSkNLRHRGS0JvNHd5cERHTEpBVXhwVWlFQ0h0dFozL3NYNmN4TWNNeG9pUUVsSVdyVnFBWW9lYjRnUXdZQUU0eUg0RUloQXJybkxlZ3p6RmtVMFBHYWxaZzJKRjErRzQzQXNXanlpYUFhemMvOEFxYytJUU92Q3dLSjJYbjhvRXFodXg3dkV5WFUzWSs5M0drQ2w5Z1lFY1VvS0VIeDFGT3UvLy8vL3dJQWtSeFFBZ0FBQUJlcEZBSGkrWkd4Mk5rRTdxWkIxNWNjbnU1cVRuSlloMEJDRHdBQUFBQUFGNmtVNERIK3Uya0VwK2U0R1N0NHF4L0dWeTZOV0Z1SEFBQUFBQT09In19LCJhbGdvcml0aG0iOnsidmFsdWUiOiJzaGEyNTYiLCJ2aXNpYmlsaXR5IjoiZXhwYW5kZWQifSwiaGFzaCI6eyJpZCI6IjUiLCJ2YWx1ZSI6eyJ0eXBlIjoiYnl0ZXMiLCJkYXRhIjoiZ3JoYUFKZUVydFBTUW1tR3p2Yjk0bGZDNitKL2ljS0IwbnVnOS8rTTFHaz0ifX19fSx7InR5cGUiOiJvcGVyYXRpb24iLCJuYW1lIjoiQGNpcGhlcmVkaXRvci9leHRlbnNpb24taGFzaC9oYXNoIiwiZXh0ZW5zaW9uVXJsIjoiaHR0cHM6Ly9jZG4uY2lwaGVyZWRpdG9yLmNvbS9leHRlbnNpb25zL0BjaXBoZXJlZGl0b3IvZXh0ZW5zaW9uLWhhc2gvMS4wLjAtYWxwaGEuMS9leHRlbnNpb24uanMiLCJwcmlvcml0eUNvbnRyb2xOYW1lcyI6WyJhbGdvcml0aG0iLCJtZXNzYWdlIiwiaGFzaCJdLCJmcmFtZSI6eyJ4IjotMTUwLCJ5IjotMjA0LCJ3aWR0aCI6MzIwLCJoZWlnaHQiOjIzOH0sImNvbnRyb2xzIjp7Im1lc3NhZ2UiOnsiaWQiOiI3IiwidmFsdWUiOnsidHlwZSI6ImJ5dGVzIiwiZGF0YSI6ImdyaGFBSmVFcnRQU1FtbUd6dmI5NGxmQzYrSi9pY0tCMG51ZzkvK00xR2s9In19LCJhbGdvcml0aG0iOnsidmFsdWUiOiJzaGEyNTYiLCJ2aXNpYmlsaXR5IjoiZXhwYW5kZWQifSwiaGFzaCI6eyJ2YWx1ZSI6eyJ0eXBlIjoiYnl0ZXMiLCJkYXRhIjoiY05yY3UvMDd1TVd2WVFmYm1tK1J0WHBBTVRWZVU0SjdHeXRFQnFQdjBLRT0ifX19fSx7InR5cGUiOiJ2YXJpYWJsZSIsImF0dGFjaG1lbnRzIjpbIjUiLCI3Il19XX19)

計算結果はこうで、[このTXID](https://mempool.space/ja/testnet/tx/a1d0efa306442b1b7b82535e3531407ab5916f9adb0761afc5b83bfdbbdcda70)の逆順になっている。

```
70dadcbbfd3bb8c5af6107db9a6f91b57a4031355e53827b1b2b4406a3efd0a1
```

計算結果そのものの並びを "internal byte order"、逆順にした並びを "RPC byte order" と呼ばれている([用語集](https://developer.bitcoin.org/glossary.html))。  

## おわりに

