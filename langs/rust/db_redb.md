---
layout: record
title: "rust: redb"
tags:
  - rust
daily: false
create: "2026/07/12"
date: "2026/07/12"
---

## redb

redbは組み込み型のKVSデータベースである。  
lmdbなどを参考にしているそうだ。

* [cberner/redb: An embedded key-value database in pure Rust](https://github.com/cberner/redb)

### サンプルコード

[元のサンプルコード](https://docs.rs/redb/latest/redb/#example)にちょっと足した。  
`table.insert("my_key", &123)?;`のようにわざわざ参照にしているのは、redbが参照で受け取る(zero-copy)からだそうだ。
`123`にしても動作するのは、数値型はCopyトレイトがあってうまいことやるからだそうだ。

```toml
[dependencies]
redb = "4.1.0"
```

```rust
use redb::{Database, Error, ReadableDatabase, TableDefinition};

const STR_U64_TABLE: TableDefinition<&str, u64> = TableDefinition::new("str_u64");
const STR_AU8_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("str_&[u8]");

fn main() -> Result<(), Error> {
    // create()は生成とオープンを兼ねる。open()はオープンのみ。
    let db = Database::create("my_db.redb")?;
    let write_txn = db.begin_write()?;
    {
        let mut table = write_txn.open_table(STR_U64_TABLE)?;
        table.insert("my_key", &123)?;
    }
    {
        let mut table = write_txn.open_table(STR_AU8_TABLE)?;
        table.insert("my_key2", "hello".as_bytes())?;
    }
    write_txn.commit()?;

    let read_txn = db.begin_read()?;
    {
        let table = read_txn.open_table(STR_U64_TABLE)?;
        assert_eq!(table.get("my_key")?.unwrap().value(), 123);
    }
    {
        let table = read_txn.open_table(STR_AU8_TABLE)?;
        assert_eq!(table.get("my_key2")?.unwrap().value(), "hello".as_bytes());
    }

    Ok(())
}
```

table定義には実際に保存する形式を書くので、こちらは`&u64`ではなく`u64`。
じゃあkey側の`&str`はなんなんだよってなるのだが、これは特別扱いらしい。

構造体を保存するときはサイズが分からないので、これまた特別扱いな`&[u8]`を使う。
[wincode](https://docs.rs/wincode/latest/wincode/index.html)などを使ってバイナリ化するのだとか。
自動で変換してもらうためにマクロを作ったりすると便利。。。なはず。  
手元のコードにはマクロがあったのだが、たぶんAIに作ってもらったやつだろう。

### テーブル定義が増える

key-valueごとにテーブルがいるので、組を増やすごとにテーブルが増えてしまう。
特に良い方法はないが、key-valueを型の組として扱えば同じ方の組についてはテーブル定義を流用できるはずだ。

あまりいい案が思いつかない。

### プリミティブ値以外は面倒かも

サイズが決まった型か、`&str`か`&[u8]`か。  
それ以外の型をそのまま扱おうとしたら自分でなにかしないといけない。  
まだRustを扱いだして慣れていなかったためというのもあろうが、なんかひどく面倒だった。

redb-deriveクレートまで使って対応したのだが、コンパイルエラーを見ても何を修正すればよいかわからんかった。
今だとAIにお任せでもっと簡単なのかもしれない。

あまり気にしないなら、構造体はserdeでJSONなどにして扱うのが楽かもしれない。

### 1つのキーにVecを入れる

私はあまり考えずにシリアライズした。

Multimapとついた構造体があるので、そういうのをうまく使うとよいかも。
