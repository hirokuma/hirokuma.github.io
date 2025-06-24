---
layout: post
title: "WSL2のファイアウォール設定"
tags:
  - wsl2
date: 2024/05/11
---

WSL2のネットワークモードをmirroredにして、WSL2でサーバを立てて外部からアクセスできるようになった。  
外部といってもLANの中でしか試していないのだが、今のところそれで良いのだ。  

気になったのは、オープンしているポートがホスト側、つまりWindows側からわからないことだ。
`netstat -nat`としてもLISTENしているポートが出てこない。  
そういえばファイアウォールの通知も出ていなかった。どうなってるのだろう？

[ASCII.jp：Windows Subsytem for Linux（WSL）が昨年9月のアップデートでファイアウォール対応になった](https://ascii.jp/elem/000/004/179/4179292/)

* 今はデフォルトで有効になっている
* Hyper-Vファイアウォールという別設定になっている

ということだが、今回何もせずに動いている。

[WSL を使用したネットワーク アプリケーションへのアクセス - Microsoft Learn](https://learn.microsoft.com/ja-jp/windows/wsl/networking#mirrored-mode-networking)

「注意」のところに書いてある。

* `Set-NetFirewallHyperVVMSetting`で`Allow`する
* `NetFirewallHyperVRule`でルールを追加する

「または」と書いてあるので前者だけ設定していた。後者は`80`とあるのでポート番号ごとにやらんといかんように思えたからだ。
これをやっているのでアクセスできたのだろう。  
WSL2でサーバを立ててそれを外部に公開することはほぼないだろうから、それなら今のままで良いな。
