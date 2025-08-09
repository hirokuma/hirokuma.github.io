---
layout: record
title: "Public KeyからscriptPubKeyを得る"
tags:
  - bitcoin
  - tips
daily: false
date: "2025/07/31"
---

あまりないケースだが、33byteのPublic KeyからscriptPubKeyを計算したいことがあった。  
今回はP2TRの場合である。

`02c73b6ff93a7ed7305105d8077a697b860af48012528935d7b2132dfa85491ffb`

## Xonly Public Key

33byteのPublic Keyは先頭の `02` か `03` を外せばXonly Public Keyになる。

`c73b6ff93a7ed7305105d8077a697b860af48012528935d7b2132dfa85491ffb`

## deriveaddresses

`bitconi-cli deriveaddresses` コマンドでアドレスを得ることができる。  
descriptorを使うが、チェックサムが必要である。  
わからないので `#checksum` のように `#` に続けて8文字打ち込んでおくと計算してくれる。

```console
$ bitcoin-cli deriveaddresses "tr(c73b6ff93a7ed7305105d8077a697b860af48012528935d7b2132dfa85491ffb)#checksum"
error code: -5
error message:
Provided checksum 'checksum' does not match computed checksum '8g3hlp8x'
```

`#checksum` を計算してくれたチェックサムに置き換えるとアドレスが出力される。

```console
$ bitcoin-cli deriveaddresses "tr(c73b6ff93a7ed7305105d8077a697b860af48012528935d7b2132dfa85491ffb)#8g3hlp8x"
[
  "bcrt1pcxxf3yxr8wrjr7ukxvp68dkaycrwqrlrat3z3pegygl6v2g2jk0qzalk3t"
]
```

## validateaddress

`validateaddress` の出力の中にscriptPubKeyがある。

```console
$ bitcoin-cli validateaddress bcrt1pcxxf3yxr8wrjr7ukxvp68dkaycrwqrlrat3z3pegygl6v2g2jk0qzalk3t | jq -r .scriptPubKey
5120c18c9890c33b8721fb963303a3b6dd2606e00fe3eae2288728223fa6290a959e
```
