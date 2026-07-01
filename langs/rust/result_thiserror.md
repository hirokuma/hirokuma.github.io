---
layout: record
title: "rust: anyhow::Resultとthiserror"
tags:
  - rust
daily: false
create: "2026/05/31"
date: "2026/05/31"
---

## anyhow::Result

`anyhow`クレートの`Result`は便利である。

関数を書いていて、自分でエラー処理をできないから呼び元に戻したいとする。
1種類のエラーしかなければ`std::result::Result<T,E>`で`E`のところに該当するエラーを書けば済む。
しかしエラーの種類が複数あるとそれでは型が不一致になってダメだ。  
そういうときに`anyhow::Result<T>`を返すようにしておくとなんかうまいこと処理して返してくれる。

* [https://github.com/dtolnay/anyhow](https://github.com/dtolnay/anyhow)

アプリであれば`anyhow::Result`でよいのだが、ライブラリが`anyhow::Result`を返してきてそれを`match`などで分岐するのがわずらわしい。
`downcast`でできるそうだが、こんな感じの書き方になるようだ。

```rust
use std::{fs::File, io::prelude::*};
use anyhow::Result;

fn read(fname: &str) -> Result<String> {
    let mut abc = String::new();
    let mut f = File::open(fname)?;
    f.read_to_string(&mut abc)?;
    Ok(abc)
}

fn main() -> Result<()> {
    let abc = match read("./abc.txt") {
        Ok(abc) => abc,
        Err(e) => {
            match e.downcast::<std::io::Error>() {
                Ok(io_err) => {
                    io_err.to_string()
                }
                Err(e) => {
                    eprintln!("unknown err: {e}");
                    return Err(e);
                }
            }
        }
    };
    println!("abc={}", abc);

    Ok(())
}
```

それに、ライブラリにはライブラリのエラーを持っていてほしいという気持ちがある(勝手な気持ちだが)。
ライブラリの方でファイルのエラーがあったからといって`std::io::Error`を直接返されるよりは、
いったんそのライブラリのエラーとして返してもらったほうが実装しやすいんじゃないかと思う。

実際、私がライブラリを作るときに何も考えず`anyhow::Result`を返すように作っていて、
じゃあそれをアプリに使ってみようとしたときにダメだなと感じたのだ。  
ライブラリもアプリも自分で作っていて、特にライブラリは流用するつもりもなかったので
ライブラリのエラー＝アプリもエラーであることさえ分かれば良い、ということになっていてなかなか気づかなかったのだ。  
返しているエラーも`anyhow::bail!("～")`で文字列を返すことがほとんどだったので、
アプリ側でエラー対応がほとんどできなかったのだ。

`anyhow::bail!()`は便利だった。  
このマクロ自体がエラーを返すところまでやるので、`return`も`;`もいらない。
エラーが文字列(formatも使える)だけで良いなら難しいことを考えずに済む。

## thiserror

`anyhow`と同じ作者の人が`thiserror`も提供している。  
こちらも`anyhow`とは違う意味でエラーをまとめる機能、だと思う。

* [https://github.com/dtolnay/thiserror](https://github.com/dtolnay/thiserror)
* 開発日記
  * [rust: thiserror で自作のエラー型を作る - hiro99ma blog](https://blog.hirokuma.work/2025/12/20251214-rst.html)
  * [rust: thiserrorでのジェネリックなエラー型 - hiro99ma blog](https://blog.hirokuma.work/2026/04/20260426-rust.html)
  * [rust: thiserrorとの付き合い方 - hiro99ma blog](https://blog.hirokuma.work/2026/06/20260628-rust.html)

私はこういう感じで追加している。
まだ初心者で技がないのだ。

* モジュールごとに`#[derive(thiserror::Error, Debug)]`な`enum XxxError`を用意する
* そのモジュールの中でエラーを返す可能性がある関数は`std::result::Result<T, XxxError>`を返す
* `?`がエラーになっているようだったら`XxxError`に`HogeError(#[from] abc::def::HogeError)`のようなのを追加する
  * メッセージは`#[error(transparent)]`に任せる
* 自分でエラーを返したいなら適当に追加する(`String`か`&'static str`)
* `cargo clippy`で"very large"と言われたらそのエラーを`Box<>`で囲み`?`は`.map_err(Box::new)?`にする

`enum`のそれぞれのvariant名を`AbcError`や`DefError`のように同じサフィックスにしていたら`cargo clippy`で"enum_variant_names"のwarningが出た。
エラーなんやけんお尻にErrorって付いたほうがわかりやすいやん、と思って私は`allow`を付けて無視した。
まあ、`enum`の型名でも`Error`と付けているので冗長といえばそうなんだけど、`#[from]`したものと同じvariant名にするのが楽だからな。

`#[from]`なものとそうでないのとで名前を変えるのはありかもしれんが、
`use`でそのvariantだけにするとわかりづらいかもしれない。
が、逆に言えば`enum`名の方を`use`すると`XxxError::AbcError`となって格好が悪いか。

まだまだ修行が足りないようだ。
技が身についたら追記します。
