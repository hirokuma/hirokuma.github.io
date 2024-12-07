# Nordic Semiconductor 調査 > Device Firmware Update(DFU)


## DFU の種類

* イメージの取得ルート別
  * DFU over UART
    * UART ポート
  * DFU over USB
    * USB CDC-ACM(Virtual COM port)
  * FOTA over BLE
* イメージの取得タイミング別
  * MCUboot
  * アプリ

![image](images/pattern.png)

## DFU over UART

### from MCUboot

#### via hardware UART (*1)

DFU over UART from MCUboot

#### via virtual COM port (*2)

DFU over USB from MCUboot

### from the application

#### via hardware UART (*3)

DFU over UART from the application

#### via virtual COM port (*4)

DFU over USB from the application

### via BLE (*5)

FOTA over BLE

## 署名の検証

* 鍵の指定方法
* 検証に失敗するとどうなるか
