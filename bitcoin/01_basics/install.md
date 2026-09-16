---
layout: "record"
title: "Bitcoin Core(bitcoind) のインストール"
tags:
  - bitcoin
daily: false
create: "2026/01/14"
date: "2026/09/16"
---

## はじめに

フルノード実装の1つである Bitcoin Core(bitcoind) のインストールについて説明する。

Bitcoin Core のウェブサイトは[https://bitcoincore.org/](https://bitcoincore.org/)である。  
`https://bitcoincore.com/`や`https://www.bitcoin.com/`などではないことに注意が必要だ。  
Bitcoin財団のような団体があっても、それはBitcoin Coreとは関係がない。

実行ファイルを配布しているのも、
本当はソースコードだけ配布したいのだがそうすると偽の実行ファイルが出回る可能性があるので
自分たちで配布するようにしたのだと思う。

公式での Docker コンテナも存在しない。  
今後はどうなるかわからないので絶対にないとは言いきれないが、公式のように見える配布であるほど注意が必要です。

## 入手方法

### その1: ソースコードからビルドする

[ビルド](./build.md)を参照。

### その2: 実行ファイルをダウンロードする

[https://bitcoincore.org/en/download/](https://bitcoincore.org/en/download/)からダウンロードする。  
このページには最新のリリースがダウンロードできるようになっている。  
URL がわからない場合は [GitHub bitcoin](https://github.com/bitcoin/bitcoin)の About に URL が載っている。

[GitHub の Releaseページ](https://github.com/bitcoin/bitcoin/releases)にはバイナリはないが、ダウンロード先は載っているのでそちらでもよい。  
[https://bitcoincore.org/bin/](https://bitcoincore.org/bin/)には過去バージョンやリリース前のファイルもある。

バイナリファイルが本当に期待するものかどうかをチェックする。  
[https://bitcoincore.org/en/download/](https://bitcoincore.org/en/download/)の下の方にある 「Verify your download」 にプラットフォームごとの確認方法が記載されている。

Linuxの場合は、まず`SHA256SUMS`をダウンロードして`sha256sum`でチェックする。  
他のファイルのチェックサムも載っていてチェックしようとするので`--ignore-missing`を付けて存在しないファイルは出力しないようにする。  
チェックしたいファイルは Linux 向けでなくてもよい。例えば Windows の exeファイルでもチェックできる。

```shell
$ sha256sum --ignore-missing --check SHA256SUMS
bitcoin-28.1-win64-setup.exe: OK
```

偽のバイナリファイルと偽の`SHA256SUMS`がセットで存在しているとチェックサムを確認しても意味が無い。  
同じページからダウンロードできる`SHA256SUMS.asc`は`SHA256SUMS`のデジタル署名である。  
デジタル署名の検証には署名した公開鍵が必要だが、偽の公開鍵で検証しても意味が無い。  
Bitcoin Core のビルドは[https://github.com/bitcoin/bitcoin](https://github.com/bitcoin)ではなく[https://github.com/bitcoin-core](https://github.com/bitcoin-core)が担当している。  
ビルドした人の公開鍵は[https://github.com/bitcoin-core/guix.sigs/tree/main/builder-keys](https://github.com/bitcoin-core/guix.sigs/tree/main/builder-keys)にあるのでダウンロードする。  
ブラウザで表示している URL だと HTML でダウンロードされるので RAW にするのを忘れないように。

* 誤: `https://github.com/bitcoin-core/guix.sigs/blob/main/builder-keys/sipa.gpg`
* 正: `https://raw.githubusercontent.com/bitcoin-core/guix.sigs/refs/heads/main/builder-keys/sipa.gpg`

```shell
$ wget https://raw.githubusercontent.com/bitcoin-core/guix.sigs/refs/heads/main/builder-keys/sipa.gpg
$ gpg --import sipa.gpg
gpg: key 860FEB804E669320: 65 signatures not checked due to missing keys
gpg: key 860FEB804E669320: public key "Pieter Wuille <pieter@wuille.net>" imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg: no ultimately trusted keys found
$ rm sipa.gpg
```

そして署名の検証だが、「Verify your download」に書いてある "gpg: Good signature" は出力されていない。  
`SHA256SUMS.asc` には複数の署名が入っているが、その中に `sipa.gpg` が含まれていないからである。

```shell
$ gpg --verify SHA256SUMS.asc
gpg: assuming signed data in 'SHA256SUMS'
gpg: Signature made Thu Jan  9 20:34:20 2025 JST
gpg:                using RSA key 101598DC823C1B5F9A6624ABA5E0907A0380E6C3
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 09:31:33 2025 JST
gpg:                using RSA key 152812300785C96444D3334D17565732E08E5E41
gpg:                issuer "me@achow101.com"
gpg: Can't check signature: No public key
gpg: Signature made Thu Jan  9 01:29:18 2025 JST
gpg:                using RSA key E61773CD6E01040E2F1BD78CE7E2984B6289C93A
gpg:                issuer "pinheadmz@gmail.com"
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 16:57:51 2025 JST
gpg:                using RSA key 9DEAE0DC7063249FB05474681E4AED62986CD25D
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 09:39:24 2025 JST
gpg:                using ECDSA key C388F6961FB972A95678E327F62711DBDCA8AE56
gpg:                issuer "kvaciral@protonmail.com"
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 17:19:28 2025 JST
gpg:                using RSA key 9D3CC86A72F8494342EA5FD10A41BDC3F4FAFF1C
gpg:                issuer "aaron@sipsorcery.com"
gpg: Can't check signature: No public key
gpg: Signature made Thu Jan  9 00:42:36 2025 JST
gpg:                using RSA key 637DB1E23370F84AFF88CCE03152347D07DA627C
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 17:25:10 2025 JST
gpg:                using RSA key F2CFC4ABD0B99D837EEBB7D09B79B45691DB4173
gpg:                issuer "seb.kung@gmail.com"
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 21:14:52 2025 JST
gpg:                using EDDSA key E86AE73439625BBEE306AAE6B66D427F873CB1A3
gpg:                issuer "me@maxedwards.me"
gpg: Can't check signature: No public key
gpg: Signature made Thu Jan  9 01:01:38 2025 JST
gpg:                using RSA key F19F5FF2B0589EC341220045BA03F4DBE0C63FB4
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 20:19:23 2025 JST
gpg:                using RSA key F4FC70F07310028424EFC20A8E4256593F177720
gpg:                issuer "gugger@gmail.com"
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 19:20:41 2025 JST
gpg:                using RSA key A0083660F235A27000CD3C81CE6EC49945C17EA6
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 23:17:43 2025 JST
gpg:                using RSA key 0CCBAAFD76A2ECE2CCD3141DE2FFD5B1D88CA97D
gpg: Can't check signature: No public key
```

そういうこともあって gpg は 1ファイルではなくそのディレクトリ全部を import することを推奨している。  
今回はエラー出力の中にあった `issuer "me@achow101.com"` だけで試す。  
一応 "Good signature" は出力された。

```shell
$ wget https://raw.githubusercontent.com/bitcoin-core/guix.sigs/refs/heads/main/builder-keys/achow101.gpg
$ gpg --import achow101.gpg
gpg: key 17565732E08E5E41: 3 signatures not checked due to missing keys
gpg: key 17565732E08E5E41: public key "Ava Chow <me@achow101.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg: no ultimately trusted keys found
$ gpg --verify SHA256SUMS.asc
gpg: assuming signed data in 'SHA256SUMS'
gpg: Signature made Thu Jan  9 20:34:20 2025 JST
gpg:                using RSA key 101598DC823C1B5F9A6624ABA5E0907A0380E6C3
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 09:31:33 2025 JST
gpg:                using RSA key 152812300785C96444D3334D17565732E08E5E41
gpg:                issuer "me@achow101.com"
gpg: Good signature from "Ava Chow <me@achow101.com>" [unknown]
gpg:                 aka "Ava Chow <github@achow101.com>" [unknown]
gpg:                 aka "Ava Chow <achow101@pm.me>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 1528 1230 0785 C964 44D3  334D 1756 5732 E08E 5E41
gpg: Signature made Thu Jan  9 01:29:18 2025 JST
gpg:                using RSA key E61773CD6E01040E2F1BD78CE7E2984B6289C93A
gpg:                issuer "pinheadmz@gmail.com"
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 16:57:51 2025 JST
gpg:                using RSA key 9DEAE0DC7063249FB05474681E4AED62986CD25D
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 09:39:24 2025 JST
gpg:                using ECDSA key C388F6961FB972A95678E327F62711DBDCA8AE56
gpg:                issuer "kvaciral@protonmail.com"
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 17:19:28 2025 JST
gpg:                using RSA key 9D3CC86A72F8494342EA5FD10A41BDC3F4FAFF1C
gpg:                issuer "aaron@sipsorcery.com"
gpg: Can't check signature: No public key
gpg: Signature made Thu Jan  9 00:42:36 2025 JST
gpg:                using RSA key 637DB1E23370F84AFF88CCE03152347D07DA627C
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 17:25:10 2025 JST
gpg:                using RSA key F2CFC4ABD0B99D837EEBB7D09B79B45691DB4173
gpg:                issuer "seb.kung@gmail.com"
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 21:14:52 2025 JST
gpg:                using EDDSA key E86AE73439625BBEE306AAE6B66D427F873CB1A3
gpg:                issuer "me@maxedwards.me"
gpg: Can't check signature: No public key
gpg: Signature made Thu Jan  9 01:01:38 2025 JST
gpg:                using RSA key F19F5FF2B0589EC341220045BA03F4DBE0C63FB4
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 20:19:23 2025 JST
gpg:                using RSA key F4FC70F07310028424EFC20A8E4256593F177720
gpg:                issuer "gugger@gmail.com"
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 19:20:41 2025 JST
gpg:                using RSA key A0083660F235A27000CD3C81CE6EC49945C17EA6
gpg: Can't check signature: No public key
gpg: Signature made Wed Jan  8 23:17:43 2025 JST
gpg:                using RSA key 0CCBAAFD76A2ECE2CCD3141DE2FFD5B1D88CA97D
gpg: Can't check signature: No public key
```

#### `verify.py` を使ったダウンロード

`SHA256SUMS` のチェックなどをいちいちやるのは面倒だ。  
ダウンロードと検証を行うスクリプトがある。こちらの方がビルドした人の公開鍵でチェックすることもあって厳しそうだ。

* [bitcoin/contrib/verify-binaries at master · bitcoin/bitcoin](https://github.com/bitcoin/bitcoin/tree/master/contrib/verify-binaries)
  * [masterブランチのverify.py履歴](https://github.com/bitcoin/bitcoin/commits/master/contrib/verify-binaries/verify.py)

`verify.py`を実行すると、鍵がインポートされていればダウンロードして`/tmp/`にディレクトリを作ってダウンロードする。

2026/09/16時点でリリースされているものではv31.1が最新なのでそれで試す。  
`verify.py`だけダウンロードして実行したところエラーになった。

```shell
$ python verify.py pub 31.1-x86_64-linux
[INFO] got file https://bitcoincore.org/bin/bitcoin-core-31.1/SHA256SUMS.asc as SHA256SUMS.asc
[WARNING] https://bitcoin.org failed to provide file (https://bitcoin.org/bin/bitcoin-core-31.1/SHA256SUMS.asc). Continuing based solely upon https://bitcoincore.org.
[INFO] got file https://bitcoincore.org/bin/bitcoin-core-31.1/SHA256SUMS as SHA256SUMS
[WARNING] https://bitcoin.org failed to provide file (https://bitcoin.org/bin/bitcoin-core-31.1/SHA256SUMS). Continuing based solely upon https://bitcoincore.org.
[INFO] got 2 good signatures
[INFO] Maybe you need to import (`gpg --keyserver hkps://keys.openpgp.org --recv-keys <key-id>`) some of the following keys:
[INFO]
[INFO]     17565732E08E5E41 (me@achow101.com)
[INFO]     410108112E7EA81F (hebasto@gmail.com)
[INFO]     D7CC770B81FD22A8 (benthecarman@live.com)
[INFO]     BF131C2D0536F8AC ()
[INFO]     E7E2984B6289C93A (pinheadmz@gmail.com)
[INFO]     3152347D07DA627C ()
[INFO]     CE6EC49945C17EA6 ()
[INFO]     57FF9BDBCC301009 ()
[INFO]     9B79B45691DB4173 (seb.kung@gmail.com)
[INFO]
[ERROR] not enough trusted sigs to meet threshold (2 vs. 3)
```

guix.sigからビルドした人たちのGPG公開鍵を持ってきてインストールする。  
commit-idは`a7b8e98d71c374dd77c93777988cc0a77c6b46ca`である。

```shell
$ git clone https://github.com/bitcoin-core/guix.sigs.git
$ cd guix.sigs/builder-keys/
$ gpg --import *.gpg
gpg: key 188CBB2648416AD5: 6 signatures not checked due to missing keys
gpg: key 188CBB2648416AD5: ".0xB10C <b10c@b10c.me>" 9 new signatures
gpg: key A5E0907A0380E6C3: public key "CoinForensics (SigningKey) <59567284+coinforensics@users.noreply.github.com>" imported
gpg: key 2EBB056FD847F8A7: 12 signatures not checked due to missing keys
gpg: key 2EBB056FD847F8A7: public key "Stephan Oeste (it) <it@oeste.de>" imported
gpg: key 57FF9BDBCC301009: 53 signatures not checked due to missing keys
gpg: key 57FF9BDBCC301009: public key "Sjors Provoost <sjors@sprovoost.nl>" imported
gpg: key 9303B33A305224CB: 15 signatures not checked due to missing keys
gpg: key 9303B33A305224CB: public key "Sebastian Kung (TheCharlatan) <seb.kung@gmail.com>" imported
gpg: key 17565732E08E5E41: public key "Ava Chow <me@achow101.com>" imported
gpg: key D7CC770B81FD22A8: 2 signatures not checked due to missing keys
gpg: key D7CC770B81FD22A8: public key "Ben Carman <benthecarman@live.com>" imported
gpg: key 1C2491FFEB0EF770: 2 signatures not checked due to missing keys
gpg: key 1C2491FFEB0EF770: public key "Cory Fields <cfields@bitcoinfoundation.org>" imported
gpg: key E13FC145CD3F4304: 15 signatures not checked due to missing keys
gpg: key E13FC145CD3F4304: public key "Antoine Poinsot <darosior@protonmail.com>" imported
gpg: key 10F2A3D26839321E: public key "davidgumberg <davidzgumberg@gmail.com>" imported
gpg: key C37B1C1D44C786EE: public key "Duncan Dean <duncangleeddean@gmail.com>" imported
gpg: key 944D35F9AC3DB76A: 18 signatures not checked due to missing keys
gpg: key 944D35F9AC3DB76A: "Michael Ford (bitcoin-otc) <fanquake@gmail.com>" 20 new signatures
gpg: key 8F617F1200A6D25C: 8 signatures not checked due to missing keys
gpg: key 8F617F1200A6D25C: public key "Gloria Zhao <gloriazhao@berkeley.edu>" imported
gpg: key 8E4256593F177720: 1 signature not checked due to a missing key
gpg: key 8E4256593F177720: "Oliver Gugger <gugger@gmail.com>" 4 new signatures
gpg: key 410108112E7EA81F: public key "Hennadii Stepanov (GitHub key) <32963518+hebasto@users.noreply.github.com>" imported
gpg: key 0E3908F364989888: public key "Abubakar Sadiq Ismail <abubakarsadiqismail@proton.me>"
imported
gpg: key D11BD4F33F1DB499: public key "jackielove4u <jackielove4u@hotmail.com>" imported
gpg: key 8ADCB558C4F33D65: public key "josibake@protonmail.com <josibake@protonmail.com>" imported
gpg: key F62711DBDCA8AE56: public key "Dimitri <kvaciral@protonmail.com>" imported
gpg: key 74810B012346C9A6: 104 signatures not checked due to missing keys
gpg: key 74810B012346C9A6: public key "Wladimir J. van der Laan <laanwj@protonmail.com>" imported
gpg: key A291A2C45D0C504A: public key "Luke Dashjr (Codesigning) <luke-jr+git@utopios.org>" imported
gpg: key B66D427F873CB1A3: public key "m3dwards <me@maxedwards.me>" imported
gpg: key F9C5154E44D75DF8: public key "maflcko <*~=`'#}+{/-|&$^_@721217.xyz>" imported
gpg: key BF131C2D0536F8AC: public key "marcofleon <marleo23@proton.me>" imported
gpg: key D5DBABC9625AB5BE: public key "Nkatha <nkathakaburu0@gmail.com>" imported
gpg: key E7E2984B6289C93A: 1 signature not checked due to a missing key
gpg: key E7E2984B6289C93A: public key "Matthew Zipkin (GitHub Signing Key) <pinheadmz@gmail.com>" imported
gpg: key 747A7AE2FB0FD25B: public key "satsie <staciewaleyko@gmail.com>" imported
gpg: key 9303B33A305224CB: "Sebastian Kung (TheCharlatan) <seb.kung@gmail.com>" 1 new user ID
gpg: key 9303B33A305224CB: "Sebastian Kung (TheCharlatan) <seb.kung@gmail.com>" 4 new signatures
gpg: key 860FEB804E669320: 59 signatures not checked due to missing keys
gpg: key 860FEB804E669320: public key "Pieter Wuille <pieter@wuille.net>" imported
gpg: key 0A41BDC3F4FAFF1C: public key "Aaron Clauson (sipsorcery) <aaron@sipsorcery.com>" imported
gpg: key CFB2C83C66CD792A: public key "Sebastian van Staa <sebastian.van.staa@gmail.com>" imported
gpg: key 7B18557E3AF1CDA5: public key "tapcrafter <tapcrafter@proton.me>" imported
gpg: key C2371D91CB716EA7: public key "Sebastian Falbesoner (theStack) <sebastian.falbesoner@gmail.com>" imported
gpg: key A7BEB2621678D37D: public key "vertion <vertion@protonmail.com>" imported
gpg: key 3B8F814A784218F8: 1 signature not checked due to a missing key
gpg: key 3B8F814A784218F8: public key "Will Clark <will@256k1.dev>" imported
gpg: key 8E3A8F3247DBCBBF: public key "Willy Ko <willyk@syscoin.org>" imported
gpg: key 9F81364FD4AF0DF6: public key "xyephy <ziphyr.xyeag@gmail.com>" imported
gpg: key EB562DE99F42B3D1: public key "xyzconstant <263061129+xyzconstant@users.noreply.github.com>" imported
gpg: key CA247AC78DF0509C: public key "yuvicc (yuvicc-sign-release) <yuvichh01@gmail.com>" imported
gpg: Total number processed: 39
gpg:               imported: 35
gpg:           new user IDs: 1
gpg:         new signatures: 37
gpg: no ultimately trusted keys found
```

改めて実行。

```shell
$ python verify.py pub 31.1-x86_64-linux
[INFO] got file https://bitcoincore.org/bin/bitcoin-core-31.1/SHA256SUMS.asc as SHA256SUMS.asc
[WARNING] https://bitcoin.org failed to provide file (https://bitcoin.org/bin/bitcoin-core-31.1/SHA256SUMS.asc). Continuing based solely upon https://bitcoincore.org.
[INFO] got file https://bitcoincore.org/bin/bitcoin-core-31.1/SHA256SUMS as SHA256SUMS
[WARNING] https://bitcoin.org failed to provide file (https://bitcoin.org/bin/bitcoin-core-31.1/SHA256SUMS). Continuing based solely upon https://bitcoincore.org.
[INFO] got 11 good signatures
[INFO] GOOD SIGNATURE (untrusted): SigData('17565732E08E5E41', 'Ava Chow <me@achow101.com>', trusted=False, status='')
[INFO] GOOD SIGNATURE (untrusted): SigData('2EEB9F5CC09526C1', 'Michael Ford (bitcoin-otc) <fanquake@gmail.com>', trusted=False, status='')
[INFO] GOOD SIGNATURE (untrusted): SigData('410108112E7EA81F', 'Hennadii Stepanov (GitHub key) <32963518+hebasto@users.noreply.github.com>', trusted=False, status='')
[INFO] GOOD SIGNATURE (untrusted): SigData('D7CC770B81FD22A8', 'Ben Carman <benthecarman@live.com>', trusted=False, status='')
[INFO] GOOD SIGNATURE (untrusted): SigData('8E4256593F177720', 'Oliver Gugger <gugger@gmail.com>', trusted=False, status='')
[INFO] GOOD SIGNATURE (untrusted): SigData('BF131C2D0536F8AC', 'marcofleon <marleo23@proton.me>', trusted=False, status='')
[INFO] GOOD SIGNATURE (untrusted): SigData('E7E2984B6289C93A', 'Matthew Zipkin (GitHub Signing Key) <pinheadmz@gmail.com>', trusted=False, status='')
[INFO] GOOD SIGNATURE (untrusted): SigData('3152347D07DA627C', 'Stephan Oeste (it) <it@oeste.de>', trusted=False, status='')
[INFO] GOOD SIGNATURE (untrusted): SigData('CE6EC49945C17EA6', 'Will Clark <will@256k1.dev>',
trusted=False, status='')
[INFO] GOOD SIGNATURE (untrusted): SigData('57FF9BDBCC301009', 'Sjors Provoost <sjors@sprovoost.nl>', trusted=False, status='')
[INFO] GOOD SIGNATURE (untrusted): SigData('9B79B45691DB4173', 'sedited <seb.kung@gmail.com>', trusted=False, status='')
[INFO] removing *-debug binaries (bitcoin-31.1-x86_64-linux-gnu-debug.tar.gz) from verification since https://bitcoincore.org does not host *-debug binaries
[INFO] downloading bitcoin-31.1-x86_64-linux-gnu.tar.gz to /tmp/bitcoin_verify_binaries.31.1-x86_64-linux
[INFO] did not clean up /tmp/bitcoin_verify_binaries.31.1-x86_64-linux
VERIFIED: bitcoin-31.1-x86_64-linux-gnu.tar.gz
```

### その3: Dockerコンテナ

はじめに書いたように、Bitcoin Core チームは Docker コンテナを提供していない。  
これは怠慢だとかそういうのではなく、基本的に Bitcoin Core は自分で立ち上げるものだからだ。  
ビルド済みのバイナリを提供するのがギリギリな線というところだろう。
おそらく、不正なバイナリがはびこるくらいなら公式で提供するようにした方がよいという判断だと思う。

その代わり、Bitcoin サービスを提供しているプロジェクトが提供していることがある。
ちゃんとした`bitcoind`を提供しているのか確認するのは難しいだろうので使用は自己判断になる。

見たところDocker Hubで`bitcoin/bitcoin`という名前があったのだが、
Bitcoin Coreチームから提供しているものではない。

## mainnet で必要となるストレージサイズ

Raspberry Pi 4 で動かしている Bitcoin Core mainnet でのストレージサイズは 814 GB くらいである(2025/11/09時点)。  
1 TB の HDD に置いているが、chainstate は速度に影響がありそうなので SSD に配置している(11 GB)。  


サイズに影響しそうなオプションはこれらである。

* txindex=1
* blockfilterindex=1
* peerblockfilters=1

Bitcoin Core のバイナリサイズも含んでいるが誤差のようなものだろう。

```txt
Filesystem      Size  Used Avail Use%
/dev/sdb1       916G  814G   56G  94%
```

```shell
$ du -h
61G     ./indexes/txindex
103M    ./indexes/blockfilter/basic/db
12G     ./indexes/blockfilter/basic
12G     ./indexes/blockfilter
73G     ./indexes
142M    ./blocks/index
742G    ./blocks
814G    .
```

1 TB ではそのうち足りなくなりそうだ。  
`chainstate/`, `indexes/`を別のドライブに置くくらいしか思いつかない。

`blocks/`は 1ディレクトリなので、やるなら各ファイルをシンボリックリンクにするか。
それで運用していたのだが、ドライブの調子が悪かったので別のドライブに移動させるときに操作ミスでファイルを消してしまって復旧がひどく大変だった。  
スクリプトで自動化するべきだったな、とミスした後から手順をそうするようにした私だった。

## 関連ページ

* [ウォレット](./wallet.md)
* [ブロック](./blocks.md)
* [トランザクション](./transactions.md)
* [アドレス](./address.md)
* [スクリプト](./script.md)
