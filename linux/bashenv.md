---
layout: record
title: "bashの環境変数"
tags:
  - linux
daily: false
create: "2026/10/11"
date: "2026/10/11"
---

## -nと-z

どっちがどっちか覚えられない。  
"non-zero"と"zero"か。

```shell
$ [ -n "$PATH" ] && echo "1"
1
$ [ -z "$PATH" ] && echo "1"
$
```

ただし！ 対象の環境変数をダブルクォーテーションで囲まないと正しく判定されない。
うっかりしやすい。

```shell
$ ABC=""
$ [ -n "$ABC" ] && echo "1"
$ [ -n $ABC ] && echo "1"
1
$ [ -z "$ABC" ] && echo "1"
1
$ [ -z $ABC ] && echo "1"
1
```

ダブルクォーテーションを忘れてもエラーにならないのは、`[ ]` 自体がテストコマンドだから。
中に文字列があれば正(`0`)、なければ偽(`1`)となるそうだ。

```shell
~$ [ a ]
~$ echo $?
0
~$ [ ]
~$ echo $?
1
```
