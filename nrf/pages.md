# Nordic Semiconductor 調査 > よく使うページ

_最終更新日: 2024/11/06_

## Nordic Semiconductor

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
* Development
  * [Bluetooth](https://docs.nordicsemi.com/bundle/ncs-latest/page/zephyr/connectivity/bluetooth/index.html)
  * [Bluetooth libraries and services](https://docs.nordicsemi.com/bundle/ncs-2.6.1/page/nrf/libraries/bluetooth_services/index.html)

### リポジトリ

* [nRF Connect](https://github.com/nrfconnect)
  * [nrfconnect/sdk-zephyr: NCS downstream of https://github.com/zephyrproject-rtos/zephyr](https://github.com/nrfconnect/sdk-zephyr)
  * [nrfconnect/sdk-nrf: nRF Connect SDK main repository](https://github.com/nrfconnect/sdk-nrf)
  * [nrfconnect/sdk-nrfxlib: Nordic common libraries](https://github.com/nrfconnect/sdk-nrfxlib)
  * [nrfconnect/sdk-mcuboot: NCS downstream of https://github.com/zephyrproject-rtos/mcuboot](https://github.com/nrfconnect/sdk-mcuboot)
* [DevAcademy](https://github.com/NordicDeveloperAcademy)

#### west で checkout される tags

* [v2.7.0](https://github.com/nrfconnect/sdk-nrf/blob/v2.7.0/west.yml)
* [v2.8.0](https://github.com/nrfconnect/sdk-nrf/blob/v2.8.0/west.yml)

### Nordicページ検索

Nordicのページを検索する。  
ncs のバージョンによって違うことがあるので、最新でない ncs を使っている場合はバージョンを指定するのが無難。

* [Introduction: latest](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/index.html)
  * [Introduction: ncs-v2.6.1](https://docs.nordicsemi.com/bundle/ncs-2.6.1/page/nrf/index.html)
  * [Introduction: ncs-v2.7.0](https://docs.nordicsemi.com/bundle/ncs-2.7.0/page/nrf/index.html)
  * [Introduction: ncs-v2.8.0](https://docs.nordicsemi.com/bundle/ncs-2.8.0/page/nrf/index.html)

### Kconfig

Kconfig の検索はちょっと特殊で、正規表現で記載するのがよい。  
全部の項目名が決まっている場合は「`^CONFIG_GPIO$`」のように前後に挟み、プレフィクス一致の場合は「`^CONFIG_GPIO`」のように頭だけ指定すると良いだろう。  
ページの読み込みに時間がかかるのか、そうやって打ち込んでも出てこないことがある。

* [Kconfig search: latest](https://docs.nordicsemi.com/bundle/ncs-latest/page/kconfig/index.html)

### MCUboot

DFU を載せないなら[MCUboot](https://docs.mcuboot.com/)はなくてもよいのかもしれない(調査中)。  
`sysbuild.conf`に `SB_CONFIG_BOOTLOADER_MCUBOOT=y`(sysbuild) か `prj.conf` に `CONFIG_BOOTLOADER_MCUBOOT=y`(multi-image build) が必要。

nRF53 は外部に Flash を持たないと DFU に手間がかかる。
詳しくは DevAcademy Intermediate [Lesson 8 – Bootloaders and DFU/FOTA](https://academy.nordicsemi.com/courses/nrf-connect-sdk-intermediate/lessons/lesson-8-bootloaders-and-dfu-fota/)を参照。

* [MCUboot documentation](https://docs.nordicsemi.com/bundle/ncs-latest/page/mcuboot/wrapper.html)

## Zephyr

* [Zephyr API Documentation: Error numbers](https://docs.zephyrproject.org/apidoc/latest/group__system__errno.html)

## SEGGER

* [J-Link](https://www.segger.com/products/debug-probes/j-link/?mtm_campaign=kb&mtm_kwd=debugtraceprobes)
* [Wiki](https://wiki.segger.com/Debug_Probes_-_J-Link_%26_J-Trace)

## Bluetooth SIG

* [Core仕様書](https://www.bluetooth.com/specifications/specs/)
  * [v5.1](https://www.bluetooth.com/specifications/specs/core-specification-amended-5-1/)
* [Core仕様書補足(CSS)](https://www.bluetooth.com/specifications/specs/core-specification-supplement/)
  * [v12](https://www.bluetooth.com/specifications/specs/css-12-html/)
    * 昔はPDFだったが今はHTMLになったようだ
* [Assigned Numbers](https://www.bluetooth.com/specifications/assigned-numbers/)
  * [AD Type](https://bitbucket.org/bluetooth-SIG/public/src/main/assigned_numbers/core/ad_types.yaml)
  * [URI schemes](https://bitbucket.org/bluetooth-SIG/public/src/main/assigned_numbers/core/uri_schemes.yaml)
