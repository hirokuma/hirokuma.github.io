# Nordic Semiconductor調査

<i>最終更新日: 2024/09/10</i>

Nordic Semiconductor社の製品、主に nRF5x 系の調査メモを残すページ

## はじめ方

* [1. 準備](startup/01_prepare.md)
* [2. 実機とデバッガ](startup/02_device.md)
* [3. プロジェクト](startup/03_proj.md)

## よく使うページ

* Nordic Semiconductors
  * Products
    * [Wireless/BLE](https://www.nordicsemi.com/Products/Wireless/Bluetooth-Low-Energy)
      * [Development Hardware](https://www.nordicsemi.com/Products/Wireless/Bluetooth-Low-Energy/Development-hardware?lang=en#infotabs)
        * [nRF5340](https://www.nordicsemi.com/Products/nRF5340)
        * [nRF5340DK](https://www.nordicsemi.com/Products/Development-hardware/nRF5340-DK)
        * [Thingy:53](https://www.nordicsemi.com/Products/Development-hardware/Nordic-Thingy-53)
      * [Development Software](https://www.nordicsemi.com/Products/Wireless/Bluetooth-Low-Energy/Development-software?lang=en#infotabs)
        * [nRF Connect SDK](https://www.nordicsemi.com/Products/Development-software/nRF-Connect-SDK)
  * [DevAcademy](https://academy.nordicsemi.com/)
  * [Blogs](https://devzone.nordicsemi.com/nordic/)
* [SEGGER J-Link](https://www.segger.com/products/debug-probes/j-link/?mtm_campaign=kb&mtm_kwd=debugtraceprobes)
  * [SEGGER wiki](https://wiki.segger.com/Debug_Probes_-_J-Link_%26_J-Trace)

### 検索

#### 全文

Nordicのページを検索する。  
ncs のバージョンによって違うことがあるので、最新でない ncs を使っている場合はバージョンを指定するのが無難。

* [Introduction: latest](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/index.html)
  * [Introduction: ncs-v2.6.1](https://docs.nordicsemi.com/bundle/ncs-2.6.1/page/nrf/index.html)

#### Kconfig

Kconfig の検索はちょっと特殊で、正規表現で記載するのがよい。  
全部の項目名が決まっている場合は「`^CONFIG_GPIO$`」のように前後に挟み、プレフィクス一致の場合は「`^CONFIG_GPIO`」のように頭だけ指定すると良いだろう。  
ページの読み込みに時間がかかるのか、そうやって打ち込んでも出てこないことがある。

* [Kconfig search: latest](https://docs.nordicsemi.com/bundle/ncs-latest/page/kconfig/index.html)

#### Zephyr error

Zephyr API のエラー値を見ても関数の説明には`-EIO`のような記載しかないためどのエラーなのか分からない。  
そういう場合、Zephyr のエラー値から定義名を調べるのが良いだろう。

* [Zephyr API Documentation: Error numbers](https://docs.zephyrproject.org/apidoc/latest/group__system__errno.html)

### MCUboot

DFU を載せないなら[MCUboot](https://docs.mcuboot.com/)はなくてもよいのかもしれない(調査中)。  
`CONFIG_BOOTLOADER_MCUBOOT=y`が必要。

nRF53 は外部に Flash を持たないと DFU に手間がかかる。
詳しくは DevAcademy Intermediate [Lesson 8 – Bootloaders and DFU/FOTA](https://academy.nordicsemi.com/courses/nrf-connect-sdk-intermediate/lessons/lesson-8-bootloaders-and-dfu-fota/)を参照。

* [MCUboot documentation](https://docs.nordicsemi.com/bundle/ncs-latest/page/mcuboot/wrapper.html)

### BLE

(調査中)

* [Bluetooth](https://docs.nordicsemi.com/bundle/ncs-latest/page/zephyr/connectivity/bluetooth/index.html)
* [Bluetooth libraries and services](https://docs.nordicsemi.com/bundle/ncs-2.6.1/page/nrf/libraries/bluetooth_services/index.html)

### リポジトリ

Zephyr も含め [github.com/nrfconnect](https://github.com/nrfconnect) の下にある。  
よく使っているリポジトリだけ載せておく。

* [nrfconnect/sdk-zephyr: NCS downstream of https://github.com/zephyrproject-rtos/zephyr](https://github.com/nrfconnect/sdk-zephyr)
* [nrfconnect/sdk-nrf: nRF Connect SDK main repository](https://github.com/nrfconnect/sdk-nrf)
* [nrfconnect/sdk-nrfxlib: Nordic common libraries](https://github.com/nrfconnect/sdk-nrfxlib)
* [nrfconnect/sdk-mcuboot: NCS downstream of https://github.com/zephyrproject-rtos/mcuboot](https://github.com/nrfconnect/sdk-mcuboot)

### DevAcademy

Developer Academy、略して DevAcademy。  
チュートリアルのようなものである。

* [Nordic Semiconductor Online Learning Platform - Nordic Developer Academy](https://academy.nordicsemi.com/)
* [github.com/NordicDeveloperAcademy](https://github.com/NordicDeveloperAcademy)
* 私の作業メモリポジトリ
  * [github.com/hirokuma/ncs-fund](https://github.com/hirokuma/ncs-fund)
  * [github.com/hirokuma/ncs-bt-fund](https://github.com/hirokuma/ncs-bt-fund)
