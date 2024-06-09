# 01 はじめに

Nordic Semiconductor社のnRFシリーズでBLE開発をする個人開発者向けの資料を作ることを目的としている。  
これを書いている人は、2015年くらいまでBLE開発をしていたが8年ほどBLEどころか組み込み開発からも遠ざかっていたという経緯を持っている。

## ターゲット

* チップ
  * nRF51822
  * nRF52832
* 開発環境
  * Windows11
  * SEGGER J-Link LITE Cortex-M v8(nRF53は対応していない)

## nRF52

nRF52シリーズは主力のようだ。
nRF53よりもスペックは下がるが価格と機能で釣り合いやすいのだと思う。  
[nRF52832](https://www.nordicsemi.com/Products/nRF52832)が入手しやすいと思う。
Cortex-M4 64MHzとなかなかの高スペックである。FPUも積んでいるので浮動小数点演算はハードウェアで実行できる。
IoT機器としては積み過ぎなんじゃないだろうか。

nRF52からは"nRF5 SDK"だけでなく["nRF Connect SDK"](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/nrf/index.html)も使えるようになる([比較](https://devzone.nordicsemi.com/nordic/nordic-blog/b/blog/posts/nrf-connect-sdk-and-nrf5-sdk-statement))。  
nRF5 SDKはメンテナンスのみとなっているので、新しく覚えるならnRF Connect SDKがよいだろう。  
Nordicのサイトがメンテナンスをしている最中なのか、サイトが docs.nordicsemi.com なのか developer.nordicsemi.com なのかよくわからない。

## nRF51

nRF51シリーズはCortex-M0 16MHzを持つBLEチップである。  
[nRF51822](https://www.nordicsemi.com/Products/nRF51822)が入手しやすいだろう。
CPUスペックがそれほど高くないので、nRF Connect SDKのようなOSを載せるのは難しい。Nordicとしてももう積極的な開発は行っていないようだ。

[nRF5 SDK](https://www.nordicsemi.com/Products/Development-software/nRF5-SDK)というSDKを使う。他は使えない。
"SoftDevice"という名前で`S～`というシリーズ名が付いているが、ほぼ`S110`を使うことになるのではなかろうか。
`S110`はBLE peripheral専用である。

"SoftDevice"というのはOSと思っておけば良いだろう。
BLE機能を優先しつつユーザが作ったアプリコードを必要に応じて呼び出すような動作をしていたように思う。
つまりアプリはBLEを邪魔しないくらいの動作にするか、邪魔になって後回しにされてもよいような作りにするしかないということになる。
面倒と言えば面倒なのかもしれないが、nRF51を使うのだったらそれくらいで十分な気がする。

## nRF Connect for Visual Studio Code

[nRF Connect for Visual Studio Code](https://docs.nordicsemi.com/bundle/nrf-connect-vscode/page/index.html)を使用する前提で書いていくため、nRF51については触れることが少ないと思う。
