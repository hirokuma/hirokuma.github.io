# 開発環境インストール

2024/06/08時点での内容となる。

## nRF Connect SDK

[install](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/installation/install_ncs.html)

Visual Studio Codeを使う場合とコマンドラインで使う場合の両方が書かれているが、ここではVisual Studio Codeを使う場合だけ書く。
Visual Studio Codeは事前にインストールしておくこと。

* [Visual Studio Codeを使う準備](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/installation/install_ncs.html#install_prerequisites)
  * [nRF Commandline Tools](https://www.nordicsemi.com/Software-and-Tools/Development-Tools/nRF-Command-Line-Tools) nrf-command-line-tools-10.24.2-x64.exe
  * [nRF Connect for VS Code Extension Pack](https://marketplace.visualstudio.com/items?itemName=nordic-semiconductor.nrf-connect-extension-pack)
* 以下は Visual Studio Code の nRF Connect for VS Code Extension Pack の「Install Toolchain」でインストールする
  * [Toolchain](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/installation/install_ncs.html#install_the_nrf_connect_sdk_toolchain) v2.6.1
  * [SDK](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/installation/install_ncs.html#get_the_nrf_connect_sdk_code) v2.6.1
  * Windowsの場合 `c:\ncs` 以下にインストールされた

必要に応じてJ-Linkもインストールする。

* [SEGGER JLink](https://www.segger.com/downloads/jlink/)

### 参照

* [nRF Connect SDKによるBluetooth LE 簡単スタートアップ - 加賀デバイス株式会社](https://www.kgdev.co.jp/column/nordic-column0025/)
