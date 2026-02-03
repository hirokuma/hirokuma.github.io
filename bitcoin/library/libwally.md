---
layout: "record"
title: "Bitcoin library: libwally-core"
tags:
  - bitcoin
  - library
  - clang
daily: false
date: "2026/02/03"
---

[repository](https://github.com/ElementsProject/libwally-core)

_調査日:2026/02/03_: v1.5.2

## ビルド

v1.5.0から `--enable-minimal` と `--with-system-secp256k1` の両方は設定できなくなったようだ。

```console
$ git clone https://github.com/ElementsProject/libwally-core.git
$ cd libwally-core
$ git checkout -b v1.5.2 refs/tags/release_1.5.2
$ ./tools/autogen.sh
# no Elements API, use only standard secp256k1 API
$ ./configure --disable-elements --enable-standard-secp --with-system-secp256k1
$ make
$ sudo make install
```

### 備考

* `pkg-config --cflags --libs wallycore`
    * `export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig`
* `--prefix=$HOME/.local` などとするとインストール先を変更できる。
  * install に `sudo` はいらないので楽だと思うが、それ以外のことが面倒になるので、ここは好みで。
    * include path や library の置き場所が標準ではないのでビルド時などに指定が必要になるなど
      * `-I${HOME}/.local/include -L ${HOME}/.local/lib -lwallycore -lsecp256k1`
      * `export LD_LIBRARY_PATH=$HOME/.local/lib:/usr/local/lib`
      * `export PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig:/usr/local/lib/pkgconfig`
* `--enable-standard-secp --with-system-secp256k1` として Blockstream の libsecp256k1-zkp を使わないようにしている

## 使い方

コードをいくつか載せることがあるが、長くなるのでエラー処理は省いている。

DeepWiki に登録があるので、ひとまず質問してみるのも良いだろう。

* [ElementsProject/libwally-core - DeepWiki](https://deepwiki.com/ElementsProject/libwally-core)

### 引数の順番

だいたい、前半が入力系、後半が出力系になっている。

### エラー

戻り値は `int` 型になっているものが多い。  
種類が少ないし、詳細を取得することもできず、ログを出力するモードもないためデバッグは結構大変である。

```c
/** Return codes */
#define WALLY_OK      0 /** Success */
#define WALLY_ERROR  -1 /** General error */
#define WALLY_EINVAL -2 /** Invalid argument */
#define WALLY_ENOMEM -3 /** malloc() failed */
```

私の場合、わからなかったらライブラリにログ出力を埋め込んでいる。
面倒だが手っ取り早い。

#### written のサイズ不足

API で結果としてバッファに書き込んだ量を返すことがある。仮引数名はだいたい `written` になっている。

たとえば [wally_scriptpubkey_p2tr_from_bytes](https://wally.readthedocs.io/en/latest/script.html#c.wally_scriptpubkey_p2tr_from_bytes)を見てみよう。

```c
int wally_scriptpubkey_p2tr_from_bytes(const unsigned char *bytes, size_t bytes_len,
                                       uint32_t flags,
                                       unsigned char *bytes_out, size_t len,
                                       size_t *written)
```

バッファのサイズは `WALLY_SCRIPTPUBKEY_P2TR_LEN` 以上であることを期待している。

ではそれより小さかった場合はどうなるのかというと、
[コード](https://github.com/ElementsProject/libwally-core/blob/a445157d180c5d67d7f6f0d8abe9c84d956d8dad/src/script.c#L1318-L1322) を見るとこうなっている。

```c
    if (len < WALLY_SCRIPTPUBKEY_P2TR_LEN) {
        /* Tell the caller their buffer is too short */
        *written = WALLY_SCRIPTPUBKEY_P2TR_LEN;
        return WALLY_OK;
    }
```

エラーにはならないが処理を行わず `written` に `WALLY_SCRIPTPUBKEY_P2TR_LEN` を代入している。

これはなかなか難しい。  
わざわざこうしたのは、API によってはバッファサイズが決められないので試行してもらうタイプもあるからだろうか？  
[DeepWikiさん](https://deepwiki.com/search/wallyscriptpubkeyp2trfrombytes_4e3d031a-cd7e-4b02-a898-3961aef28112) によると全体でそうなっているそうだ。  
ともかく、`WALLY_OK` だったとしても `written` が `len` 以下であることも確認する必要があるということだ。

### メモリの解放

いくつかのAPIはメモリを確保して返すものがある。  
そういったメモリは使用後に解放すること。
APIの説明にだいたい書かれていると思う。

私の場合、[valgrind](https://valgrind.org/) で解放漏れをチェックしている。

### 始めと終わり

libwally-core は内部で [secp256k1](./clang.md#libsecp256k1) を使っている。  
secp256k1は使い始めに [secp256k1_context_randomize()](https://github.com/bitcoin-core/secp256k1/blob/f36afb8b3dd7daf9edf4bf15c49fcd540f8ce393/examples/schnorr.c#L40-L43) を使うことを推奨しているので、
[wally_secp_randomize()](https://wally.readthedocs.io/en/latest/core.html#c.wally_secp_randomize) を呼び出しておくのが良い。  
乱数の生成は secp256k1 の[サンプル](https://github.com/bitcoin-core/secp256k1/blob/f36afb8b3dd7daf9edf4bf15c49fcd540f8ce393/examples/examples_util.h#L43)を参照するのは悪くないと思う(secp256k1 の関数は戻り値が OK=1, NG=0 と libwally-core と逆なので注意)。

```c
  wally_init(0);
  wally_secp_randomize(bytes, bytes_len);
  ......
  wally_cleanup(0);
```

[Ask DeepWiki](https://deepwiki.com/search/_0f766924-8af1-48f1-8b01-c0349e1c9ffd)

### ニモニックから BIP32 の seed を作る

ニモニックは [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) である。  
ニモニックのことをパスフレーズと説明しているウォレットもあるのだが、
12単語 や 24単語のあれのことを「ニモニック」と呼ぶ。  
パスフレーズはパスワード的なもので、ニモニックとパスフレーズをセットにしないと正しい seed を得ることができない。

```c
  uint8_t seed[BIP39_SEED_LEN_512];
  size_t written;
  bip39_mnemonic_to_seed(mnemonic, PASSPHRASE, seed, sizeof(seed), &written);
```

### BIP32 Functions による鍵管理

[BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) は HDウォレットなのだが、[BIP32 Functions](https://wally.readthedocs.io/en/latest/bip32.html) では鍵管理のみを取り扱っている。
ネットワークに接続する機能はないので、UTXO 管理をしたいのであれば自分で実装する必要がある。

構造体 `struct ext_key` で管理するのだが、これ自体は BIP32 の鍵 1つ分しかデータを持たない。

```c
/** An extended key */
struct ext_key {
    /** The chain code for this key */
    unsigned char chain_code[32];
    /** The Hash160 of this keys parent */
    unsigned char parent160[20];
    /** The depth of this key */
    uint8_t depth;
    unsigned char pad1[10];
    /** The private key with prefix byte 0 */
    unsigned char priv_key[33];
    /** The child number of the parent key that this key represents */
    uint32_t child_num;
    /** The Hash160 of this key */
    unsigned char hash160[20];
    /** The version code for this key indicating main/testnet and private/public */
    uint32_t version;
    unsigned char pad2[3];
    /** The public key with prefix byte 0x2 or 0x3 */
    unsigned char pub_key[33];
#ifndef WALLY_ABI_NO_ELEMENTS
    unsigned char pub_key_tweak_sum[32];
#endif /* WALLY_ABI_NO_ELEMENTS */
};
```

```c
  struct ext_key hdkey;
  bip32_key_from_seed(seed, sizeof(seed), BIP32_VER_TEST_PRIVATE, 0, &hdkey);
```

#### 階層

BIP-44 に従う場合、master 以下は深度が 5つまである([HDウォレット参照](../01_basics/wallet.md))。

```
m / purpose' / coin_type' / account' / change / address_index
```

これを `struct ext_key` に反映させるためにいくつかの API がある。  
[`bip32_key_from_parent()`](https://wally.readthedocs.io/en/latest/bip32.html#c.bip32_key_from_parent) や [`bip32_key_from_parent_path_str()`](https://wally.readthedocs.io/en/latest/bip32.html#c.bip32_key_from_parent_path_str) のような bip32_key_from_parent系を使うことになる。  
これらは階層を下に降りる API である。  
他の階層はともかく `address_index` は一番下でインクリメント横方向に展開するだけである。  
`bip32_key_from_parent_path_str()` のように文字列で `"m/86'/0'/0'/0/1"` のような指定はわかりやすいのだが、それぞれ master から階層を降りていかないと見つけることができない。  
`bip32_key_from_parent()` は相対的に下に降りる
("_str" 系も相対的にできるのかもしれないが調べていない)。  
なので、"_str" 系は階層の分だけ処理を繰り返すことになるので効率があまりよくないはずだ。
`address_index` をインクリメントしてアドレスを作るだけなら `bip32_key_from_parent()` の方が速いだろう。

今の調査段階での感想になるが一般的なウォレットとして使う場合、
`m/purpose'/coin_type'/account'` までは str系で降りていき、次に external と internal に `bip32_key_from_parent()` で分かれ、
あとは別々のインデックス値で `bip32_key_from_parent()` を使って鍵管理をするとよいのではなかろうか。  
つまり、depth=3 で一旦止め、depth=4 で 2つに分け、depth=5 で個別にインデックス管理するのである。

(調査中)

### 秘密鍵からP2TRアドレスを取得

[アドレス系API](https://wally.readthedocs.io/en/latest/address.html) に [`wally_bip32_key_to_addr_segwit()`](https://wally.readthedocs.io/en/latest/address.html#c.wally_bip32_key_to_addr_segwit) があるのだが、これは P2WPKH 用である。  
おそらく [`wally_scriptpubkey_p2tr_from_bytes()`](https://wally.readthedocs.io/en/latest/script.html#c.wally_scriptpubkey_p2tr_from_bytes) で internal public key から witness program(sciptPubkey) を求め、[`wally_addr_segwit_from_bytes()`](https://wally.readthedocs.io/en/latest/address.html#c.wally_addr_segwit_from_bytes) でアドレス文字列にするのがよいと思う。

```c
    // internal private key --> internal public key
    uint8_t internalPubKey[EC_PUBLIC_KEY_LEN];
    wally_ec_public_key_from_private_key(
        INTERNAL_PRIVKEY, EC_PRIVATE_KEY_LEN,
        internalPubKey, sizeof(internalPubKey));

    // internal public key --> witness program
    uint8_t witnessProgram[WALLY_SCRIPTPUBKEY_P2TR_LEN];
    size_t written;
    wally_scriptpubkey_p2tr_from_bytes(
        internalPubKey, sizeof(internalPubKey),
        0, witnessProgram, sizeof(witnessProgram), &written);

    // witness program --> address
    char *address;
    wally_addr_segwit_from_bytes(
        witnessProgram, sizeof(witnessProgram),
        "bc",
        0,
        &address);
    printf("address: %s\n", address);
    wally_free_string(address);
```

### HDウォレットから秘密鍵/公開鍵を取得

[DeepWikiに質問](https://deepwiki.com/search/bip32-hdkeyprivate-key_276b4809-e481-4d9c-be0b-a14453238029)したのだが、`bip32_key_get_priv_key()` は JavaScript などの他言語向けにしていないと有効にならない。  
[`wally_bip32_key_to_addr_segwit()`](https://wally.readthedocs.io/en/latest/address.html#c.wally_bip32_key_to_addr_segwit) は引数に `struct ext_key` を取るのだが、これは P2WPKH 用である。  
[wally_bip32_key_to_addr_segwit()の実装](https://github.com/ElementsProject/libwally-core/blob/a445157d180c5d67d7f6f0d8abe9c84d956d8dad/src/address.c#L67) を参考にして `struct ext_key` を直接参照するくらいしかなさそうだ。
`priv_key` の先頭の 1バイトは フラグなので注意。  
また、`struct ext_key` は public only の場合もあるのでフラグが `BIP32_FLAG_KEY_PRIVATE` であることを確認すること(もちろん変数が正しく設定されているという前提)。

(調査中)

### テストデータ

* [BIP32 Test Vectors](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#test-vectors)
  * seed と ext pub/prv 
* [BIP39 Test vectors](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki#user-content-Test_vectors)
  * Trezor と bip32JP のテストコード

## リンク

* 開発日記
  * [btc: libwally-core を使う (1) - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250126-btc.html)
  * [btc: libwally-core を使う (2) - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250127-btc.html)
  * [btc: libwally-core を使う (3) - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250128-btc.html)
  * [btc: libwally-core を使う (4) - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250129-btc.html)
  * [btc: libwally-core で script path (1) - hiro99ma blog](https://blog.hirokuma.work/2025/02/20250204-btc.html)
  * [btc: libwally-core で script path (2) - hiro99ma blog](https://blog.hirokuma.work/2025/02/20250205-btc.html)
  * [btc: libwally-core v1.4.0 - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250313-btc.html)

* サンプルコード
  * [hirokuma/wally-sample-keypath: libwally-core sample: keypath spend](https://github.com/hirokuma/wally-sample-keypath)
  * [hirokuma/c-keypath: key path spend with libwally-core](https://github.com/hirokuma/c-keypath)
  * [hirokuma/c-scriptpath: script path spend with libwally-core](https://github.com/hirokuma/c-scriptpath)
  * [hirokuma/c-hdwallet-p2tr: P2TR keypath HD wallet spend with libwally-core](https://github.com/hirokuma/c-hdwallet-p2tr)
  * [hirokuma/c-musig2: MuSig2 spend with libwally-core and libsecp256k1](https://github.com/hirokuma/c-musig2)
  * [hirokuma/cpp-descriptor: descriptor wallet with libwally-core](https://github.com/hirokuma/cpp-descriptor)
