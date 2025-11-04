---
layout: "record"
title: "rust: Result&lt;T, E&gt; と Option&lt;T&gt;"
tags:
  - rust
daily: false
date: "2025/10/22"
---

戻り値が `Result<T, E>` や `Option<T>` の場合について。  

## 例

コンパイルが通るというだけで意味は無い。

だいたい使い方はこんな感じになると思う。

* `Result<T, E>`
  * `T` を取得したいときは `?` か `.unwrap()` 系を使う(`match` もできたはず)
  * `?` を使ったときは伝播するので関数の戻り値も同じ `Result<T, E>` にする
* `Option<T>`
  * `T` を取得したいときは `?` か `match` か `.unwrap()` 系を使う
  * `?` を使ったときは伝播するので関数の戻り値も同じ `Option<T>` にする

```rust
fn func1() -> Result<i32, String> {
    Ok(123)
}

fn func2() -> Result<i32, String> {
    Err("hello".to_string())
}

fn func3() -> Option<i32> {
    return Some(123);
}

fn func4() -> Option<i32> {
    return None;
}

fn func5() -> Option<i32> {
    let a = func3()?;
    let b = if let Some(k) = func3() {
        k * 2
    } else {
        3
    };
    match func4() {
        Some(i) => Some(a * i + b),
        None => None,
    }
}

fn main() -> Result<(), String> {
    let a = func1()?;
    let b = func2()?;
    println!("{} {}", a, b);

    let c = match func5() {
        Some(i) => format!("{}", i),
        None => "None".to_string(),
    };
    println!("{}", c);

    Ok(())
}
```

## .unwrap()

[doc.rust-lang.org で検索](https://doc.rust-lang.org/std/result/enum.Result.html?search=unwrap#method.unwrap)すると、単語一致で "unwrap" を持っているのは `Result::unwrap` と `Option::unwrap` だけだった。

値が取得できないときは panic するのであまり下の方の関数で使うのはよろしくないと思う。
まったく想定していない異常ならありかもしれない。

### Result<T, E>

[Result<T, E>.unwrap()](https://doc.rust-lang.org/std/result/enum.Result.html#method.unwrap) は `T` か `E` しか返さないのでわかりやすい。  
`T` は `Ok(T)` に、`E` は `Err(E)` になる。  
`Ok()` や `Err()` に何か実装があるわけではなく、そういう意味づけがある enum値というだけのようだ。

`.unwrap()` には `where` があるので `E` が何でもよいわけでは無くデバッグ出力っぽいことができないとダメそうだ。
そういうときでも探せばよいのがあるだろう。  
`Return<>` を使いたいだけであればそういう制約はない。

```rust
pub enum Result<T, E> {
    /// Contains the success value
    #[lang = "Ok"]
    #[stable(feature = "rust1", since = "1.0.0")]
    Ok(#[stable(feature = "rust1", since = "1.0.0")] T),

    /// Contains the error value
    #[lang = "Err"]
    #[stable(feature = "rust1", since = "1.0.0")]
    Err(#[stable(feature = "rust1", since = "1.0.0")] E),
}

......

    pub fn unwrap(self) -> T
    where
        E: fmt::Debug,
    {
        match self {
            Ok(t) => t,
            Err(e) => unwrap_failed("called `Result::unwrap()` on an `Err` value", &e),
        }
    }

......
```

### Option<T>

[Option<T>.unwrap()](https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap) も `enum` なので `Result` と同じ系統なのだが、`None` と `Some(T)` がわかりづらい。

* [Option enumとNull値に勝る利点](https://doc.rust-jp.rs/book-ja/ch06-01-defining-an-enum.html?highlight=some%28T%29#option-enum%E3%81%A8null%E5%80%A4%E3%81%AB%E5%8B%9D%E3%82%8B%E5%88%A9%E7%82%B9)

Rust には言語として `null` 的な定義は無い。その代わりになる `enum Option` を標準ライブラリに用意した。
言語としてではなくライブラリとして最初からあるというだけなので、自分で同じようなことをやってもよいということだ。  
Rust として `null` を組み入れたくはないけど便利だよねということらしい。

`.unwrap()` は `None` 側で panic するので `Result` のような制約はない。
その分、なんで panic したのかはわかりづらいかもしれん。

```rust
pub enum Option<T> {
    /// No value.
    #[lang = "None"]
    #[stable(feature = "rust1", since = "1.0.0")]
    None,
    /// Some value of type `T`.
    #[lang = "Some"]
    #[stable(feature = "rust1", since = "1.0.0")]
    Some(#[stable(feature = "rust1", since = "1.0.0")] T),
}

......

    pub const fn unwrap(self) -> T {
        match self {
            Some(val) => val,
            None => unwrap_failed(),
        }
    }

......
```

## `?` が使えるところ

演算子の表の最後に `?` があり「エラー委譲」とある。英文では "Error propagation"。  
propagation は委譲というよりは伝播っていう感じがする。

* [表B-1: 演算子](https://doc.rust-jp.rs/book-ja/appendix-02-operators.html?search=%E5%A7%94%E8%AD%B2)

`?` は、`Ok(T)` なら `T` が戻されて続く。`Err(E)` なら `E` が戻されるが `return E` になる。  
正常時は `.unwrap()` と同じで、エラーの場合は呼び元にエラーが戻される。

* [エラー委譲のショートカット: ?演算子](https://doc.rust-jp.rs/book-ja/ch09-02-recoverable-errors-with-result.html#%E3%82%A8%E3%83%A9%E3%83%BC%E5%A7%94%E8%AD%B2%E3%81%AE%E3%82%B7%E3%83%A7%E3%83%BC%E3%83%88%E3%82%AB%E3%83%83%E3%83%88-%E6%BC%94%E7%AE%97%E5%AD%90)

標準ライブラリにあるからといって `?` が `Err()` 専用になっているわけではなくオーバーロードするしくみがある。

* [演算子のオーバーロード](https://doc.rust-jp.rs/rust-by-example-ja/trait/ops.html#%E6%BC%94%E7%AE%97%E5%AD%90%E3%81%AE%E3%82%AA%E3%83%BC%E3%83%90%E3%83%BC%E3%83%AD%E3%83%BC%E3%83%89)
  * [core::ops](https://doc.rust-lang.org/core/ops/)
    * [Try](https://doc.rust-lang.org/core/ops/trait.Try.html)

"Experimental" となっているが `?` になりそうなのがこれしかない。  
`branch()` は `?` が使われたときに値を返す(`Continue`)か呼び出し元に伝播させるか(`Break`)を判定する処理、`from_output()` が `?` で正常系だったときに返す値だそうだ。

`Result` にあった `Try` はこれ。

```rust
impl<T, E> const ops::Try for Result<T, E> {
    type Output = T;
    type Residual = Result<convert::Infallible, E>;

    #[inline]
    fn from_output(output: Self::Output) -> Self {
        Ok(output)
    }

    #[inline]
    fn branch(self) -> ControlFlow<Self::Residual, Self::Output> {
        match self {
            Ok(v) => ControlFlow::Continue(v),
            Err(e) => ControlFlow::Break(Err(e)),
        }
    }
}
```

`Option` にあった `Try` はこれ。

```rust
impl<T> const ops::Try for Option<T> {
    type Output = T;
    type Residual = Option<convert::Infallible>;

    #[inline]
    fn from_output(output: Self::Output) -> Self {
        Some(output)
    }

    #[inline]
    fn branch(self) -> ControlFlow<Self::Residual, Self::Output> {
        match self {
            Some(v) => ControlFlow::Continue(v),
            None => ControlFlow::Break(None),
        }
    }
}
```

## anyhow

`Result<T, E>` とすると `E` が固定の型になっていろいろなエラーを受け付ける可能性がある関数では使いづらい。  
`anyhow::Result` を使って `Result<T, anyhow::Error>` とすることで「いろいろ」を受け付けられるようになる。  
戻り値が `Result<T>` だけになっている場合はほぼ `anyhow::Result<T>` のことでこの形式になっていると思って良いだろう。

* [use anyhow::{Context, Result};](https://docs.rs/anyhow/latest/anyhow/)

「いろいろ」といっても `anyhow::Error` に合致する必要はある。  
単にエラー文字列を返したいときは `return Err(anyhow!(msg))` や `anyhow::bail!(msg)` 

`anyhow` で便利なのは `?` でエラーを返すときにメッセージを付与する `.context(msg)?` という書き方ができるところだ。  


## Option を anyhow::Result にしたい

全体的に `Result<T, E>` でエラーを伝播させていたのだが、`Option<T>` を返すメソッドもある。  
そういう場合はどちらの戻り値(ここでは `Result`)に一本化したいだろう。

今やっている例を挙げると、下側からどういう `E` が来るのかわからないので `anyhow::Result` を使っている。
`Result<()>` を返すメソッドの中で `Option<u32>` を返すメソッドがあるので何とかしたい。  
`?` を使ったらうまいことやってくれないかと期待したが、さすがにダメそうだった。

Gemini か Copilot にやってもらうと `match` のアームで `None => { return Err(anyhow::anyhow!("エラーが起きた")); },` のようにしていた。  
文字列型のエラーを返したいだけにしては大げさ気がするが、`anyhow` だからこうなるんだろうか。

ネットで検索すると `Option` を `Result` にする例として `.ok_or(値)` や `.ok_or_else(関数)` などを使うそうだ。  
こんな感じで変換できそうだ。  
`.ok_or()` で `.to_owned()` を使っているのは extension で修正候補が出たから使っただけだ。  
[to_owned()](https://doc.rust-lang.org/std/borrow/trait.ToOwned.html#tymethod.to_owned) は借用データから所有データを作り出すものだそうだ。  
なら `.clone()` でいいんじゃないのと思ったがダメだったが `.to_string()` は通る。

```rust
use std::process;

fn ldl_hdl(msg: &str) -> Option<String> {
    Some(format!("Your {} is too high.", msg))
    // None
}

fn cholesterol(msg: &str) -> Result<String, String> {
    ldl_hdl(msg).ok_or("None!!!".to_owned())
}

fn main() {
    let ret = match cholesterol("LDL") {
        Ok(s) => s,
        Err(e) => {
            eprintln!("cholesterol() error: {}", e.to_string());
            process::exit(1)
        },
    };
    println!("{}", ret);
}
```
