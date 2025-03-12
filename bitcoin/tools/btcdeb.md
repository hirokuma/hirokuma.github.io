# tools: btcdeb

[repository](https://github.com/bitcoin-core/btcdeb)

_2025/03/12_: v0.3.20

## 用途

btcdeb は Bitcoinスクリプトのデバッガである。

## インストール

```console
$ sudo apt-get install libtool libssl-dev autoconf pkg-config
$ git clone https://github.com/bitcoin-core/btcdeb.git
$ cd btcdeb
$ ./autogen.sh
$ ./configure --prefix $HOME/.local
$ make
$ make install
```

* Releaseタグが 0.3.20 は 2020年10月と古かったので master 版を使用した(2025年3月現在)
  * 最後の commit は [2024年4月](https://github.com/bitcoin-core/btcdeb/commit/e2c2e7b9fe2ecc0884129b53813a733f93a6e2c7)である
* configure で `--prefix` でインストール先に `$HOME/.local` を指定している
* インストールされる実行ファイルは `btcc`, `btcdeb`, `tap`, `test-btcdeb`

## コマンド

### btcc

OPコードをスクリプトの HEX文字列にコンパイルする。

```console
$ btcc OP_DUP OP_HASH160 '[62e907b15cbf27d5425399ebf6f0fb50ebb88f18]' OP_EQUALVERIFY OP_CHECKSIG
76a9151462e907b15cbf27d5425399ebf6f0fb50ebb88f1888ac
```

クォーテーションで囲む場所を間違えると OPコードではなく文字列を ASCIIコードとして HEX文字列にされてしまう。

```console
$ btcc 'OP_DUP OP_HASH160 [62e907b15cbf27d5425399ebf6f0fb50ebb88f18] OP_EQUALVERIFY OP_CHECKSIG'
warning: opcode-like string was not an opcode: DUP OP_HASH160 [62e907b15cbf27d5425399ebf6f0fb50ebb88f18] OP_EQUALVERIFY OP_CHECKSIG
4c574f505f445550204f505f48415348313630205b363265393037623135636266323764353432353339396562663666306662353065626238386631385d204f505f455155414c564552494659204f505f434845434b534947
```

数値は、10進数になりそうなら10進数、16進数になりそうなら16進数で扱っているようだ。  
`[]` で囲んでいてもそのルールのようであった。

```console
$ btcc 144
029000

$ btcc 0x90
0190

$ btcc '0x90'
0190

$ btcc '[90]'
warning: ambiguous input 90 is interpreted as a numeric value; use 0x90 to force into hexadecimal interpretation
02015a

$ btcc a0
01a0

$ btcc '[a0]'
0201a0
```

桁数が多いと HEXとして扱うようなので HASH値は大丈夫だろう。

```console
$ btcc OP_DUP OP_HASH160 '[112233445566778899]' OP_EQUALVERIFY OP_CHECKSIG
warning: ambiguous input 112233445566778899 is interpreted as a numeric value; use 0x112233445566778899 to force into hexadecimal interpretation
76a90908130eed5eb9bb8e0188ac

$ btcc OP_DUP OP_HASH160 '[00112233445566778899]' OP_EQUALVERIFY OP_CHECKSIG
76a90b0a0011223344556677889988ac
```

### btcdeb

デバッガである。  
基本的な使い方は、引数に Bitcoinスクリプトなどの情報を与え、ステップ実行していくことになる。  
終了コマンドはないので Ctrl+C で終わらせる。

コマンドだけで実行してもエラーにはならない。  
バージョンはよくわからない。以前のバージョン体系が残ったままなのかもしれない。

```console
$ btcdeb
btcdeb 5.0.24 -- type `btcdeb -h` for start up options
LOG: signing segwit taproot
notice: btcdeb has gotten quieter; use --verbose if necessary (this message is temporary)
0 op script loaded. type `help` for usage information
script  |  stack
--------+--------
btcdeb>
```

#### help

```console
btcdeb> help
step     Execute one instruction and iterate in the script.
rewind   Go back in time one instruction.
stack    Print stack content.
altstack Print altstack content.
vfexec   Print vfexec content.
exec     Execute command.
tf       Transform a value using a given function.
print    Print script.
help     Show help information.
btcdeb>
```

#### 引数

最初の `'[]'` で囲んだ 1まとまりが Bitcoinスクリプト、それ以降はスペース区切りごとにスタックに積まれるようだ。
`''` で囲まなかったり `[]` で囲まなかったりするとエラーになった。

第2引数以降は順番にスタックに積まれていく。
[ドキュメント](https://github.com/bitcoin-core/btcdeb/blob/master/doc/btcdeb.md)の最初にあるサンプルを実行するとこうなる。

![image](btcdeb-1.png)

この状態でステップ実行すると `OP_DUP` が行われ、一番上の `03b0...` のデータがスタックに積まれる。

![image](btcdeb-2.png)

#### ステップ実行の様子

ステップ実行はこのようになる。

<video controls>
  <source src="btcdeb-1.mp4" type="video/mp4" />
</video>

ステップ実行前に単語をダブルクリックして反転させているのは、見る場所を指しているだけで操作としての意味は無い。
秘密鍵は伝えていないので `OP_CHECKSIG` でエラーになって終わる。  
なお、"step" を "s" のような省略はできないが、Enter だけ入力すると前回と同じコマンドが実行される。

#### Raw Transaction データを使う

raw transaction がわかる場合は、そのデータを使うのが簡単である。

```console
$ txin="input transactionのHEXデータ"
$ tx="transactionのHEXデータ"
$ btcdeb --txin=$txin --tx=$tx
```

もし `$tx` のトランザクションに vin が複数ある場合は `-s` でどれなのかを指定する(デフォルトは `0`)。

#### print

表示されている "script" には現在の状況が出力されている。  
最初からどこまで進んだのか確認したい場合は "print" コマンドを使う。

```console
btcdeb> print
    #0000 OP_DUP
 -> #0001 OP_HASH160
    #0002 e1b85f2f9d795d7c84871330d1640314264e5f3a
    #0003 OP_EQUALVERIFY
    #0004 OP_CHECKSIG
```

この場合、次に "step" と入力すると `OP_HASH160` が実行される。

### tap

調査中

`tap` は Tapscript で使用することができる。
`btcdeb` でもできるようだが、まずは `tap` を使うことをお勧めされている。

* [Tapscript example using Tap](https://github.com/bitcoin-core/btcdeb/blob/master/doc/tapscript-example-with-tap.md)
* [Tapscript example](https://github.com/bitcoin-core/btcdeb/blob/master/doc/tapscript-example.md)

## リンク

* 開発日記
  * [btc: btcdebを使う - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250119-btc.html)
  * [btc: btcdebを使う (2) - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250120-btc.html)
  * [btc: btcdebを使う (3) - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250121-btc.html)
