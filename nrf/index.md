---
layout: "record"
title: "Nordic Semiconductor 調査"
tags:
  - ble
  - ncs
daily: false
date: "2025/05/13"
---

Nordic Semiconductor 社の製品、主に BLE 向けについて

## 近況

2025年4月に ncs v3.0.0 がリリースされた。v3.0.1 もリリースされている。

* [nRF Connect SDK v3.0.0 Release Notes](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/releases_and_maturity/releases/release-notes-3.0.0.html)
* [nRF Connect SDK v3.0.1 Release Notes](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/releases_and_maturity/releases/release-notes-3.0.1.html)

Zephyr OS v4.0.0 に更新され、[Bluetooth のアプリに変更](https://docs.nordicsemi.com/bundle/ncs-latest/page/zephyr/releases/migration-guide-4.0.html#bluetooth) が必要になるかもしれない。
わかりやすいところでは、BLE 接続を切断したときに自動で Advertising を再開する機能が deprecated になる。

* [ncs: nRF Connect SDK 3.0.0 - hiro99ma blog](https://blog.hirokuma.work/2025/04/20250426-ncs.html)
* [ncs: nRF Connect SDK 3.0.0 (2) - hiro99ma blog](https://blog.hirokuma.work/2025/04/20250429-ncs.html)

ボード定義については v2.9 から変更しなくても済んだ。

* [commit - v2.9](https://github.com/hirokuma/ncs-custom-board/tree/raytac-base-v2_9)

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
