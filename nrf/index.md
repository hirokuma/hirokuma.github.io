# Nordic Semiconductor 調査

_最終更新日: 2024/12/08_

Nordic Semiconductor 社の製品、主に BLE 向けについて

## 近況

_2024/12/01_

2024年11月だったと思うが ncs v2.8.0 がリリースされた。

* [nRF Connect SDK v2.8.0 Release Notes](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/releases_and_maturity/releases/release-notes-2.8.0.html)

Zephyr OS が更新されたようで、ビルド方法が sysbuild というものがデフォルトになった。  
`child_image/` での multi-image build はそのうち使えなくなると思うので ncs のバージョンを上げていくプロジェクトは対応しておくとよいだろう。

ボード定義ファイルなども変更されたため、v2.6 以前はもとより Devicetree v2 に対応した v2.7 であっても変更が発生した。  
開発ボードが自作の場合はそちらの改造も発生する。  
私が使用している [nRF5340 MDBT53-1Mモジュールピッチ変換基板](https://www.switch-science.com/products/8658?_pos=3&_sid=0c8c07a88&_ss=r) 用に作っているリポジトリも対応中である。

* [commit - v2.8](https://github.com/hirokuma/ncs-custom-board/commits/raytac-base-v2_8/)

## 調査

* [よく使うページ](pages.md)
* [BLEプロジェクトのはじめ方](startup/index.md)
* [Devicetree](devicetree/index.md)
* [GATT Error Codes](gatt_error_codes.md)
* [ビルドについて](build.md)
* [DFU](dfu/index.md)
* [Zephyr OS](zephyr/index.md)
* 私の作業リポジトリ
  * [テンプレートコード生成](https://github.com/hirokuma/js-ncs-service-gen)
  * [github.com/hirokuma/ncs-fund](https://github.com/hirokuma/ncs-fund)
  * [github.com/hirokuma/ncs-bt-fund](https://github.com/hirokuma/ncs-bt-fund)
