---
layout: record
title: "rust: rusqlite"
tags:
  - rust
daily: false
create: "2026/07/12"
date: "2026/07/12"
---

## rusqlite

Rust用のSQLite APIラッパー。
[SQLite](https://sqlite.org/index.html)自体はC言語で書かれた組み込み型データベースだ。  

* [rusqlite/rusqlite: Ergonomic bindings to SQLite for Rust](https://github.com/rusqlite/rusqlite)

"SQL"と付いているが、SQLを書かなくてもアクセスできたような？  
記憶が曖昧だ。。。  
ともかく[関数やマクロが多い](https://sqlite.org/keyword_index.html)。

### サンプルコード

[Usage](https://github.com/rusqlite/rusqlite#usage)に書いてあるコードをそのまま動かした。
[redb](./db_redb.md)は使ったことがあったがrusqliteは今回が初めてなのだ。

```toml
[dependencies]
rusqlite = "0.40.1"
```

```rust
use rusqlite::{Connection, Result};

#[derive(Debug)]
struct Person {
    id: i32,
    name: String,
    data: Option<Vec<u8>>,
}

fn main() -> Result<()> {
    let conn = Connection::open_in_memory()?;

    conn.execute(
        "CREATE TABLE person (
            id    INTEGER PRIMARY KEY,
            name  TEXT NOT NULL,
            data  BLOB
        )",
        (), // empty list of parameters.
    )?;
    let me = Person {
        id: 0,
        name: "Steven".to_string(),
        data: None,
    };
    conn.execute(
        "INSERT INTO person (name, data) VALUES (?1, ?2)",
        (&me.name, &me.data),
    )?;

    let mut stmt = conn.prepare("SELECT id, name, data FROM person")?;
    let person_iter = stmt.query_map([], |row| {
        Ok(Person {
            id: row.get(0)?,
            name: row.get(1)?,
            data: row.get(2)?,
        })
    })?;

    for person in person_iter {
        println!("Found person {:?}", person.unwrap());
    }
    Ok(())
}
```

実行

```log
Found person Person { id: 1, name: "Steven", data: None }
```

`open_in_memory`なのでファイルは作らずRAMだけ。
`conn.execute()`と`conn.prepare()`だけでだいたいなんとかしている。  
[オリジナル](https://sqlite.org/quickstart.html)が[sqlite3_exec](https://sqlite.org/c3ref/exec.html)と[sqlite3_prepare](https://sqlite.org/c3ref/prepare.html)をよく使うのと同じようなものか。  
まあ、ラッパーだから隠蔽されたとしても使い方はそうは変わらないと思われるが
`[dependencies]`は多いのでいろいろ使っていろいろ便利になっているのだろう。

### rusqlite以外もいろいろある

DOCS.RSを[sqliteで検索](https://docs.rs/releases/search?query=sqlite)すると"rusqlite"以外にもいろいろ出てくる。
今回rusqliteにしたのはBitcoin関係の[bdk_wallet](https://docs.rs/crate/bdk_wallet/latest/features)が(bdk_chainが)使っているからだ。  
GitHubのstarも4.3kついているしね。

### マルチスレッド？

マルチスレッドに耐えられるのかは気になるかもしれない。

* [(6) Is SQLite threadsafe?](https://sqlite.org/faq.html#q6)

スレッドセーフかどうかはコンパイルの段階で決まる。
[ここ](https://github.com/rusqlite/rusqlite/blob/39ea888b6bbe1df9a64f671892852c5124c62379/libsqlite3-sys/build.rs#L143)に`-DSQLITE_THREADSAFE=1`はある(`-D`はgccの`#define`)。
が、[こちら](https://github.com/rusqlite/rusqlite/blob/39ea888b6bbe1df9a64f671892852c5124c62379/libsqlite3-sys/build.rs#L259-L260)には`#undef`して`-DSQLITE_THREADSAFE=0`されている。  
"wasm32-wasi"の場合は打ち消しているということだろう。
[wasm32対応](https://github.com/rusqlite/rusqlite/issues/603)でビルドエラーになるので外したのかな。

[SqliteSingleThreadedMode](https://docs.rs/rusqlite/latest/rusqlite/enum.Error.html#variant.SqliteSingleThreadedMode)というエラーはopen時に出るようなので、
これは複数オープンか複数接続しようとしたときのエラーか。

確かめてないのでなんとも言えんが、マルチプロセスだろうとマルチスレッドだろうと、
資源が1つしか使えないのであれば入口を絞ってmutexなどで排他制御すればよかろう。  
`Arc<Mutex<rusqlite::Connection>>`みたいなので固めれば良さそうな気がする。試してないのだがね。

