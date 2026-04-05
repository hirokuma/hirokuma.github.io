---
layout: record
title: "bdk: confirmation数の取得"
tags:
  - bitcoin
  - rust
daily: false
create: "2026/04/05"
date: "2026/04/05"
---

特定のTXIDのconfirmation数を取得したいことはしばしばあるだろう。

## bdk_wallet

bdk_wallet を使っているなら `get_tx()` でトランザクション情報を取得するのが簡単である。  
ネックとなるのは `get_tx()` は内蔵する TxGraph のデータを走査するので場合によっては時間がかかるということである。

```rust
let tx = wallet.get_tx(txid)?;
let confs = match tx.chain_position {
    ChainPosition::Confirmed { anchor, .. } => {
        let current_height = wallet.local_chain().tip().height();
        current_height.saturating_sub(anchor.block_id.height) + 1
    }
    ChainPosition::Unconfirmed { .. } => 0,
};
```

トランザクションが承認されたブロックがconfirmation数 1 なので足し忘れに注意しよう。

## bdk_esplora

bdk_esplora は [get_tx_status()](https://docs.rs/esplora-client/0.12.3/esplora_client/async/struct.AsyncClient.html#method.get_tx_status) で [TxStatus](https://docs.rs/esplora-client/0.12.3/esplora_client/api/struct.TxStatus.html) が取得でき、
そこからconfirmation数を計算することができる。

```rust
## 動作未確認
let tx_status = client.get_tx_status(txid)?;
let confs = if let Some(height) = tx_status.block_height {
  let current_height = wallet.local_chain().tip().height();
  current_height.saturating_sub(height) + 1
} else {
  0
};
```

Esploraの標準実装ではconfirmationなどは返すそうだ([DeepWiki](https://deepwiki.com/search/bdkesploratxstatusblockheight_bb4a5f44-ed4d-4fa4-bedd-9fe58ae4e1fe?mode=fast))。

## bdk_electrum

残念ながらElectrum Serverにはconfirmation数を取得するメソッドがない。  
[blockchain.transaction.get](https://electrum-protocol.readthedocs.io/en/latest/protocol-methods.html#blockchain-transaction-get)で `verbose=true` で詳細を返してもらえば載っているのだが、
この `verbose=true` のサポートはオプショナルで、Electrum Server次第なのだ。  
私がよく使っている Blockstream/electrs はサポートしていない。
[Pull Request](https://github.com/Blockstream/electrs/pull/36)はあるのだが `txindex=1` がいると言われると確かに悩ましい(ストレージのサイズ的に)。

[DeepWiki](https://deepwiki.com/search/txidconfirmation_1a1633c5-fa80-4242-b256-154489c49fe0?mode=fast)で提案されたのは、`script_get_history` を使った方法である。
その代わり、scriptPubKey のデータがないと使用できない。

```rust
let history = client.script_get_history(script)?;
let tx = history.iter().find(|tx| tx.tx_hash == txid);
if let Some(tx) = tx {
  let confs = if tx.height > 0 {  
    let current_height = wallet.local_chain().tip().height();
    current_height.saturating_sub(tx.height) + 1
  } else {
    0
  }
}
```

自分のウォレットに関するUTXOであればアドレスが分かるのだが、内部で管理していなかったら結構面倒になる。  
bdk_wallet で情報を取ってくるなら最初からそちらを使ったほうが楽だろう。
Electrum Serverをバックエンドにするなら内部もアドレスやscriptPubKeyをキーにして考えていったほうが良いのかもしれない。
