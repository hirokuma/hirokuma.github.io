---
layout: record
title: "初期ブロックダウンロードが終わったかどうか"
tags:
  - bitcoin
  - tips
daily: false
date: "2025/07/30"
---

`bitcoind` を起動してしばらくは初期ブロックダウンロード(Initial Block Download、IBD)が行われる。  
Regtestで前回からブロックが進んでいなかったとしても、データベースから読み込んで整合性のチェックなどが行われ、それもIBD中ということになっている。  
IBD中は使用できないRPCコマンドがあるので、気にしておくとよいだろう。

## getblockchaininfo

`getblockchaininfo` の `"initialblockdownload"` が `true` の間は「ダウンロード中」である。  
なんとなくダウンロード完了フラグと思ってしまいそうだが、ダウンロードしていなければ`false`になる。

```console
bitcoin-cli getblockchaininfo | jq .initialblockdownload
```

## bash例

`"initialblockdownload"` が `true` の間はループさせている。  
Regtestの場合はすぐに終わるのでスリープを3秒程度にしているが必要に応じて変更しよう。

```bash
while :
do
  dl=`bitcoin-cli getblockchaininfo | jq .initialblockdownload`
  if [ "$dl" == "false" ]; then
    break
  fi
  sleep 3
done
```
