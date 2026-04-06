---
layout: record
title: "rust: タプル構造体"
tags:
  - rust
daily: false
create: "2026/04/06"
date: "2026/04/06"
draft: true
---

しばしば登場するのがタプル構造体である。

## 構造体のラッパー

構造体定義なのだが、丸括弧の中に型が書いてある。  
これはもうコンストラクタだろうと思ってしまうが、タプル構造体である。

```rust
struct MyString(String);
```

### 値を持つenumは「タプルバリアント(tuple variant)」らしい

* [Enumを定義する - The Rust Programming Language 日本語版](https://doc.rust-jp.rs/book-ja/ch06-01-defining-an-enum.html#enum%E3%81%AE%E5%80%A4)
  * List 6-2

List 6-2 に出てくる `Write` と `ChangeColor` はタプル構造体のように見える。  
しかしこれはタプルバリアントという分類になるそうだ。  
関数の引数のように見えるので、関数呼び出しの結果を使っているのだろうかとか、コンストラクタなんだろうかと一瞬思ってしまうが、タプルバリアントである。
もしかすると「enumの」と付けないといけないのかもしれない。

```rust
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String), // ★タプル構造体?
    ChangeColor(i32, i32, i32), // ★タプル構造体?
}
```

動かしてみよう。

```rust
#[derive(Debug)]
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}

fn main() {
    let m = Message::Quit;
    println!("m={:?}", m);

    let m = Message::Move { x: 12, y: 34 };
    println!("m={:?}", m);

    let m = Message::Write("Hello".to_owned());
    println!("m={:?}", m);

    let m = Message::ChangeColor(12, 34, 56);
    println!("m={:?}", m);
}
```

実行するとこうなるのでだいたい意図通りに動いているのだが、Rustとしては値が入ったパラメータにアクセスしていないのでwarningが出ている。

```log
m=Quit
m=Move { x: 12, y: 34 }
m=Write("Hello")
m=ChangeColor(12, 34, 56)
```

## 使い方
