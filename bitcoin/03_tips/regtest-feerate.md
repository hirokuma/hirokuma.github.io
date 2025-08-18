---
layout: record
title: "Regtest環境でfee rateを得たい"
tags:
  - bitcoin
  - tips
daily: false
date: "2025/08/07"
---

Regtest環境をそのまま使うと `bitconi-cli estimatesmartfee` などがエラーになる。  
値は何でもよいので取得できれば良かったので、ChatGPT氏に訊いてスクリプトを作った。

## bashスクリプト

Regtestの `bitcoind` が停止した状態で起動する想定になっている。  
まだ初期ブロックがないからか[getblockchaininfoの監視](./initialdownloaded.md)ではうまくいかなかったので違う方式にしている。

* regtest のデータディレクトリ( `$HOME/.bitcoin/regtest` )以下を削除
* `bitcoind -daemon`
* `bitcoin-cli getblockcount` が成功するまでループ
* ウォレット作成
* 150ブロック生成
* 30トランザクションほど fee rate を変更して適当に送信
* 20ブロックほど生成

[gist](https://gist.github.com/4feb14eea9ccccd0e2d42e8c90d434c6.git)

```bash
#!/bin/bash

# トランザクション数と生成回数の設定
TX_COUNT=30
BLOCKS=20

rm -rf $HOME/.bitcoin/regtest
bitcoind -daemon

while :
do
	bitcoin-cli getblockcount > /dev/null 2>&1
	if [ "$?" -eq 0 ]; then
		break
	fi
	echo -n "."
	sleep 1
done
echo

bitcoin-cli createwallet ""
./generate.sh 150

# 複数のfeeレベルを作成（1〜30 sat/vB 相当）
echo "Sending $TX_COUNT transactions with varying fees..."
for i in $(seq 1 $TX_COUNT); do
  DEST=$(bitcoin-cli getnewaddress)
  TXID=$(bitcoin-cli -named sendtoaddress address="$DEST" amount=0.0001 fee_rate="$i")
  echo "Sent $i $TXID"
done

# 少し時間を置く（mempoolに反映されるまでのため）
sleep 2

# ブロックを複数生成してTXを順次承認
echo "Mining $BLOCKS blocks..."
for i in $(seq 1 $BLOCKS); do
  echo "generate block $i"
  ./generate.sh
  sleep 0.2
done

# estimatesmartfee を試す
echo "Estimating fee for confirmation within 2 blocks..."
bitcoin-cli estimatesmartfee 2
```

30トランザクションや20ブロックはChatGPT氏が言ってた数をそのまま使っただけである。

最初の150ブロックも適当だが、最低は101ブロックになる(残高がもらえるようになる)。
101ブロックでは UTXO が足りない感じがしたので150にした。

### bitcoin.conf

```conf
server=1
txindex=1
regtest=1

zmqpubrawblock=tcp://127.0.0.1:28332
zmqpubrawtx=tcp://127.0.0.1:28333

[regtest]
#rpcuser=testuser
#rpcpassword=testpass
rpcauth=testuser:90d538109436dcea4d3da67f65d6aa00$21214960fe9d1bbd9d5f40ab16212fe9aa3d87a59e2cfef91232729c5de00657
fallbackfee=0.000001

# SPV
blockfilterindex=1
peerblockfilters=1
```
