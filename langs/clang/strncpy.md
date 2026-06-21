---
layout: record
title: "clang: strncpy"
tags:
  - clang
daily: false
create: "2026/06/21"
date: "2026/06/21"
---

X/Twitterを見ているとこういうのがあった。

* [Xユーザーの情報の灯台さん: 「362コミット、70人、6年。 Linuxカーネルからstrncpyが完全に削除された。 C言語の標準関数でありながら文字列の終端を保証しないこの関数は、長年バグの温床だった。 全体の6割近い211コミットを一人のGoogle社員が担った。 関数ひとつ消すのに6年。 この地味さが、カーネルの安全を支えている。 https://t.co/6sv8GfGQzO」 / X](https://x.com/joho_no_todai/status/2068488785164419567)

C言語の中でもワナが多い気がする文字列系。  
最近コードを書いていないが`strn-`系は標準関数なのに扱いづらかった記憶がある。

## C言語の文字列

C言語では`\0`で終わるデータを文字列とみなすことができる、くらいの扱いだ。  
文字列コピーの擬似コードはこんな感じじゃなかっただろうか。
`\0`の書き込みをわざわざやらずに、書き込んだ後で`\0`だったかどうか判定すれば一手減らせるかもしれない。アセンブラでやったほうがわかりやすいかも。

```c
void string_copy(char *dst, const char *src)
{
  while (*src) {
    *dst++ = *src++
  }
  *dst = '\0';
}
```

`sizeof`でサイズが分かるのは配列の時くらいで、`strlen()`を使っても`\0`までのバイト数を数えるコードだったように思う。

`malloc()`で動的なメモリ管理をするようなものだと思って良いと思う。
確保するときに管理側はサイズが分かっているがプログラムは把握してないので、
オーバーフローしたくなかったら自分でサイズを管理するようにコードを書くことになる。  
自分で書くのが面倒だったら[ccan/tal](https://ccodearchive.net/info/tal.html)や[ccan/tal/str](https://ccodearchive.net/info/tal/str.html)を使うのもよいだろう。

* [clang: ccan/tal (1) - hiro99ma blog](https://blog.hirokuma.work/2025/04/20250430-clang.html)
* [clang: ccan/tal (2) - hiro99ma blog](https://blog.hirokuma.work/2025/05/20250501-clang.html)

## 私が思う間違えやすいポイント

* `\0`のための1バイトを忘れやすい
  * ASCII8文字確保するためには9バイト以上のメモリがいる
* `#define`で文字列定義すると`0`が入っているので`sizeof`もその分が含まれる
  * "Hello"は5文字だが`sizeof`すると6バイト
* 間違って`\0`を消してしまう

## strncpy

`strn-`と"n"が関数は、無理やりnバイトで打ち切る仕様のほうが優先されて文字列のほうがないがしろにされている感じがする。  

```c
char* strncpy(char* restrict dest, const char* restrict src, size_t n);
```

`strncpy`は`src`の先頭から最大`n`文字を`dst`にコピーする。  
それまでに`src`に`\0`が見つかると`dst`の残りは`\0`で埋める。  
仕様はそのくらいのようだ。

では`dst`の終わりまで`src`の中に`\0`がなかったら？

```c
#include <stdio.h>
#include <string.h>

#define MOJI "HELLO"

int main(void)
{
    char dummy[13];
    char a[3];

    memset(dummy, '@', sizeof(dummy));
    strncpy(a, MOJI, sizeof(a));
    printf("[%s]\n", a);
    for (size_t n = 0; n < sizeof(a); n++) {
        printf("%02x ", a[n]);
    }
    printf("\n");

    return 0;
}
```

コンパイルと実行。  
今回はコンパイラがwarningを出力しているが、これは`src`がコンパイル時にわかる内容だったからというだけで動的なサイズであれば指摘できない。  
実行結果は最適化の仕方やスタックの配置で違うかもしれない。

```shell
$ gcc -Wall -o tst main.c
main.c: In function ‘main’:
main.c:12:5: warning: ‘strncpy’ output truncated copying 3 bytes from a string of length 5 [-Wstringop-truncation]
   12 |     strncpy(a, MOJI, sizeof(a));
      |     ^~~~~~~~~~~~~~~~~~~~~~~~~~~
$ ./tst
[HEL@@@@@@@@@@@@@]
48 45 4c 
```

スタック上に`dummy[13]`を確保し、次に`a[3]`する環境だと`a`と`dummy`が連続して配置され、`a[3]`の中に`\0`がなかったら`dummy[13]`も続けて`printf`が出力しようとしてしまう。
`@`の出力が13個で止まっているのは、メモリの境目とかでゼロになっているだけじゃなかろうか。調べてない。  

このように範囲を超えてしまうと、`dest`に書き込むサイズは`n`でとどめてくれるのだが、`dest`が`\0`で終わらないことになる。  
バッファオーバーフローはしないもののC言語の文字列にはならないかもしれないのだった。  
そういう関数仕様だから仕方ないのだが、文字列として返してくれるだろうという期待とは異なるだろう。

だいたいの場合で`strncpy`を使いつつ期待する結果を得られるようにするには、呼び出した後で`dest`の終わりに`\0`を書き込むことだろう。

```c
  strncpy(dest, src, dest_len);
  dst[dest_len - 1] = '\0';
```

`strncpy`側で自動的に`\0`を書き込むようにすればよさそうだが、関数仕様にないのでやらない。  
使い慣れている人からすると、むしろ勝手にそういうことをされる方が困ってしまうのだ。

## strncpy_sはオプション

最近のC言語にはセキュア系の関数もあり、`strncpy`には`strncpy_s`がある。  
これはC11標準附属書Kで導入されたもので、それをサポートするのはオプションだそうだ。gccはサポートしないらしい。

```c
errno_t strncpy_s(char* restrict dest, rsize_t destmax, const char* restrict src, rsize_t n);
```
