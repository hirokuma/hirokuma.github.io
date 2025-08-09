---
layout: record
title: "Miniscript"
tags:
  - bitcoin
  - tools
daily: false
date: "2025/08/09"
draft: true
---

(書きかけ)

Miniscriptという、Bitcoinスクリプトを構造的に書くための言語が[BIP-0379](https://github.com/bitcoin/bips/blob/master/bip-0379.md)にある。
ここではその仕様とデモ実装を紹介する。  
この実装を使った[サイト](https://bitcoin.sipa.be/miniscript/)では最初に"policy"というものが出てくるので混乱するかもしれないが、構成はこうなっている。

* Introduction
* Policy to Miniscript compiler
  * "policy" は BIP-379 に出てこない
* Analyze a Miniscript
  * Miniscriptを解析する
* Miniscript reference
  * [BIP-379 Specification](https://github.com/bitcoin/bips/blob/master/bip-0379.md#specification)と同じような内容
* Satisfactions and malleability

Miniscriptで書くことによって自分で直接Bitcoinスクリプトを書くよりも間違いを減らしやすい。  
また解析もできるため最適化したり動的にスクリプトを解くウォレットにできるかもしれない。

## サイト

* [Miniscript](https://bitcoin.sipa.be/miniscript/)
* [repository: github.com/sipa/miniscript](https://github.com/sipa/miniscript)

## 仕様

[demoサイト](https://bitcoin.sipa.be/miniscript/)の"Miniscript reference"を見ていく。

### P2WSH / TapScript

P2WSHとTapScriptで使用できる命令が異なるところがある。
ここで関係するのはMultiSigのところで、P2WSHまでは `OP_CHECKMULTISIG` のようなMultiSig専用の命令がいくつかあったが、
TapScriptではそれらは使用できなくなって代わりに [`OP_CHECKSIGADD`](https://opcodeexplained.com/opcodes/OP_CHECKSIGADD.html#op-checksigadd) が使えるようになった。
署名と公開鍵のチェックをする `OP_CHECKSIG` にカウント値をインクリメントする機能が加わったような命令である。  
Miniscriptでは `multi()` がP2WSH用、`multi_a()` がTapScript用となっている。

### 変換テーブル

"translation table"という表が載っている。  
左列から順に、表記の意味、Miniscriptでの表記(fragment)、対応するBitcoinスクリプトとなっている。
Bitcoinスクリプトで使用できるものにすべて割り当てがあるわけではないが、よほど複雑なことをしようとしなければ事足りると思われる。

`pk(key)` など関数のように表記する fragment と、その前にコロンで区切って `s:pk(key)` のように表記する wrapper がある。  
wrapper が複数ある場合は `tar` コマンドのオプションのようにつなげて書く。

"key" に相当するデータは、P2WSH では 33バイト(`02` か `03` で始まる)、TapScript では 32バイト(x-only表現)として扱う。

真ん中の列にイコールの表記があるものはシンタックスシュガーだそうだ。
ここから下にも表がいくつか出てくるが、シンタックスシュガーの方は省略するとのこと。
わざわざそう書いているのは、記載がないからシンタックスシュガーだと対象外になるのでは？という心配をさせないためだろう。

ハッシュのpreimage、つまり元値は 32バイトのみとする。
いろいろ理由は書いてあるが、ちょっと英語が難しい。。。不正なことをしやすくなるからだと読み取った。  
Merkleツリーの時のように `SHA256(A || B)` なんかはあり得そうだが、そういうのをやりたかったら自分でBitcoinスクリプトを書けば良いだけだろう。

## ビルド

```console
$ git clone https://github.com/sipa/miniscript.git
$ cd miniscript
$ make

$ echo "pk(key_1)" | ./miniscript
X    108.0000000000    35 pk(key_1) pk(key_1)
```

オリジナルをビルドしたコマンドで出力が少ないので、forkして[サイト](https://bitcoin.sipa.be/miniscript/)で出力している項目を追加した。  
policy のコンパイルと Miniscript のコンパイルのコマンドも分けた。

```console
$ git clone https://github.com/hirokuma/miniscript.git
$ cd miniscript
$ make

#
# policy to miniscript and asm
#
$ echo "or(99@pk(key_likely),pk(key_unlikely))" | ./policy
<<Spending cost>>
script_size=   63
input_size=    73.3500000000
total_cost=   136.3500000000

<<miniscript output>>
or_d(pk(key_likely),pkh(key_unlikely))

<<Resulting script structure>>
<key_likely> OP_CHECKSIG OP_IFDUP OP_NOTIF
  OP_DUP OP_HASH160 <HASH160(key_unlikely)> OP_EQUALVERIFY OP_CHECKSIG
OP_ENDIF

<<Resulting script (hex)>>
2102504b626b65795f6c696b656c7900000000000000000000000000000000000000ac736476a914504b686b65795f756e6c696b656c79000000000088ac68

#
# miniscript to asm
#
$ echo "or_d(pk(key_likely),pkh(key_unlikely))" | ./miniscript
count=0
scriptlen=63
maxops=8
type=B
safe=yes
nonmal=yes
dissat=unique
input=-
output=1
timelock_mix=no
miniscript=or_d(pk(key_likely),pkh(key_unlikely))

<<Resulting script structure>>
<key_likely> OP_CHECKSIG OP_IFDUP OP_NOTIF
  OP_DUP OP_HASH160 <HASH160(key_unlikely)> OP_EQUALVERIFY OP_CHECKSIG
OP_ENDIF

<<Resulting script (hex)>>
2102504b626b65795f6c696b656c7900000000000000000000000000000000000000ac736476a914504b686b65795f756e6c696b656c79000000000088ac68
```

### JavaScript/WASM

JavaScriptとWASMのコードも生成できる。

```console
$ sudo apt install emscripten
$ make miniscript.js
```

これらのファイルが生成された後であれば、ローカルのブラウザで `index.html` を開くと[サイト](https://bitcoin.sipa.be/miniscript/)と同じことができた。

## Policy の例

"policy" は BIP-379 

### A single key

公開鍵 `key_1` による署名を要求する。

```
# Policy
pk(key_1)

# Miniscript
pk(key_1)
```

Bitcoinスクリプトで解くときはこうなる(未確認)。
`<<～>>` は redeem する witness スタックである。

```
<<signature with key_1>>
<key_1>
OP_CHECKSIG
```

### One of two keys

#### equally likely

公開鍵 `key_1` か `key_2` による署名を要求する。
1-of-2 MultiSig のように見えるが、witness のデータは2つ必要である。

面白いのは「鍵の確率は等しい(equally likely)」の記述だ。

```
# Policy
or(pk(key_1),pk(key_2))

# Miniscript
or_b(pk(key_1),s:pk(key_2))
```

Bitcoinスクリプトで解くときはこうなる(未確認)。
`<<～>>` は redeem する witness スタックである。

```
<<signature A>>
<<signature B>>
<key_1> OP_CHECKSIG OP_SWAP <key_2> OP_CHECKSIG OP_BOOLOR
```

まず `<<signature B>>` と `<key_1>` で `OP_CHECKSIG` され、結果 true/false がスタックに載る(`<<signature B>>` と `<key_1>` は消える)。  
`OP_SWAP` することでスタック上の `<<signature A>>` と結果を入れ替えて `<<signature A>>` を上にする。  
`<<signature A>>` と `<key_2>` で `OP_CHECKSIG` され、結果 true/false がスタックに載る(`<<signature A>>` と `<key_2>` は消える)。  
スタックにはそれぞれの `OP_CHECKSIG` の結果 2つが載っている。  
[`OP_BOOLER`](https://opcodeexplained.com/opcodes/OP_BOOLOR.html#op-boolor) はスタック上の2つを取り除いて OR した結果をスタックに載せる。  
これでスタック上には `<<signature B>>` と `<key_1>` か `<<signature A>>` と `<key_2>` かのどちらか片方でも署名チェックが成功していれば true、どちらも失敗していれば false が載っている。

書く順番が `key_1`、`key_2` なのでスタックする署名もその順番と考えそうだがそうではないことに注意しよう。

TapScript ならそれぞれの script path にしてしまえばよいと思う。
いや、P2WSH でもこういうスクリプトを使うことはないような？ まあ、サンプルにあれこれいうのは野暮だろう。

#### one likely, one unlikely

こちらは確率が高い鍵とそうでない鍵があるパターン。  
Policy の `N@` は、そちらの Policy の方がデフォルトよりも `N` 倍高い確率で選択されるという意味である。

2倍までだとどちらでもよいからなのか等確率と同じMiniscriptになった。

```
# Policy
or(99@pk(key_likely),pk(key_unlikely))

# Miniscript
or_d(pk(key_likely),pkh(key_unlikely))
```

Bitcoinスクリプトで解くときはこうなる(未確認)。
`<<～>>` は redeem する witness スタックである。

```
<<signature A>>
<<key_unlikely>>
<<signature B>>
<key_likely> OP_CHECKSIG OP_IFDUP OP_NOTIF
  OP_DUP OP_HASH160 <HASH160(key_unlikely)> OP_EQUALVERIFY OP_CHECKSIG
OP_ENDIF
```

最初の `OP_CHECKSIG` までは同じである。  
違いはその次で、`<key_likely>` の署名である確率が高いから、もしその署名チェックに失敗したときだけ続きを行うよう `OP_NOTIF` で囲んでいる。  
[`OP_IFDUP`](https://opcodeexplained.com/opcodes/OP_IFDUP.html#op-ifdup) は、スタック最上部が非ゼロならそれを複製、そうでなければ何もしない命令。
なので、

* 最初の署名チェックが成功したら、成功値を複製、`OP_NOTIF` でそれを取り除き、`OP_ENDIF`までスキップして最終的に true だけが残る
* 署名チェックに失敗したら、失敗値はそのまま、`OP_NOTIF` でそれを取り除いて分岐内の処理をする

となる。

しかしこのスクリプトは `<key_unlikely>` をスタックに載せるようになっていないので witness スタックの方で載せることになる。
`<<key_unlikely>>` を `OP_DUP` で複製し、`OP_HASH160` で SHA256 + riepmd160 し(複製したデータは消える)、スクリプトに埋め込んであった`<HASH160(key_unlikely)>` をスタックに載せ、`OP_EQUALVERIFY` で `<HASH160(key_unlikely)>` とを `OP_EQUALVERIFY` で比較する(両方ともスタックから消える)。
[`OP_EQUALVERIFY`](https://opcodeexplained.com/opcodes/OP_EQUALVERIFY.html#op-equalverify) は不一致なら即座にスクリプトが失敗終了する。  
成功したらその結果はスタックに載せずに続けるので、`<<signature A>>` と `<key_unlikely>` で署名チェックする。  
その結果がそのままスクリプトの結果になる。

なぜスクリプトに `<key_unlikely>` を直接埋め込まないかというと、おそらくそちらの方が確率が高い方の鍵だった場合のサイズが小さくなるからだ。

### A user and a 2FA service need to sign off, but after 90 days the user alone is enough

### A 3-of-3 that turns into a 2-of-3 after 90 days

### The BOLT #3 to_local policy

### The BOLT #3 offered HTLC policy

### The BOLT #3 received HTLC policy

## miniscriptコンパイラの内部動作

* 名前はおそらく17文字まで([compiler.h](https://github.com/sipa/miniscript/blob/6806dfb15a1fafabf7dd28aae3c9d2bc49db01f1/compiler.h#L19))
  * 説明文には16文字とあるのだが...
* 公開鍵は `0x02` + `PKb` + 名前([compiler.h](https://github.com/sipa/miniscript/blob/6806dfb15a1fafabf7dd28aae3c9d2bc49db01f1/compiler.h#L23-L28))
  * `"pk(key_1)"` ==> `21`(データ長) + `02504b626b65795f31000000000000000000000000000000000000000000000000`(公開鍵) + `ac`(`OP_CHECKSIG`)
* PubKeyHash は ``PKh` + 名前([compiler.h](https://github.com/sipa/miniscript/blob/6806dfb15a1fafabf7dd28aae3c9d2bc49db01f1/compiler.h#L30-L35))

## その他

P2WSH と TaspScript で大きい違いがあるのは MultiSig の扱いで、TapScript には `OP_CHECKMULTISIG` のような MultiSig 関係の命令がない。
その代わりに `CHECKSIGADD` で公開鍵に対して署名チェックが正常だったらインクリメントする命令が追加され、チェックが成功した数を比較するスクリプトを書く。


## リンク

* [Miniscript - Bitcoin Optech](https://bitcoinops.org/en/topics/miniscript/)
* [rust-bitcoin/rust-miniscript: Support for Miniscript and Output Descriptors for rust-bitcoin](https://github.com/rust-bitcoin/rust-miniscript)
* 開発日記
  * [btc: miniscript - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250307-btc.html)
  * [btc: miniscript (2) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250308-btc.html)
  * [btc: miniscript (3) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250311-btc.html)
  * [btc: Output Descriptors - hiro99ma blog](https://blog.hirokuma.work/2025/02/20250224-btc.html)
  * [btc: Output Descriptors (2) - hiro99ma blog](https://blog.hirokuma.work/2025/02/20250225-btc2.html)
  * [btc: Output Descriptors (3) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250301-btc.html)
  * [btc: Output Descriptors (4) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250302-btc.html)
  * [btc: Output Descriptors (5) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250303-btc.html)
