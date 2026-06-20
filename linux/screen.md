---
layout: record
title: "screen/tmux"
tags:
  - linux
daily: false
create: "2025/07/12"
date: "2026/06/21"
---

## 概要

sshでログインして作業し始めたけど、思ってたより時間がかかるコマンドがあって、ああでもログオフして次の機会にどうなったか確認したい、みたいな状況はしばしばある。  
Raspberry PiでSSHログインしてビルドし始めたけど1時間以上終わらない、とか。

## screen

いま、`cargo`でビルドしているのだが1時間以上経っても終わらない。
幸いなことにCtrl+Cで中断しても、再度`cargo build`すると続きからやってくれる。

まず`screen`を実行する。

```shell
$ screen
```

returnキーを押すと、一旦その状態から抜ける。  
見た目は分からないが`screen`実行中の状態である。

![image](images/screen1.png)

キーボードから`Ctrl+A,d`と入力するとデタッチして元のコンソールに戻る。

![image](images/screen2.png)

このままSSHはクローズできる。  

### screenに復帰

次にSSHでログインした後、デタッチしたものが1つだけなら`screen -r`コマンドで戻してくれる。

## tmux

`screen`と同じようなコマンドだが、もうちょっとわかりやすい(かもしれない)。

実行するとステータスバーが表示されて、今がtmux側？にいることがわかる。  
この状態で実行に長くかかるコマンドを実行するとよい。

```shell
$ tmux
```

![image](images/tmux.png)

元のシェルに戻る(デタッチ)は、`Ctrl+b`を押した後にCtrlを外して`d`だけ押す。

### tmuxに復帰

デタッチした状態からtmuxに戻るには`tmux attach`を実行する。  
そうするとステータスバーが表示された画面に戻る。

```shell
$ tmux attach
```
