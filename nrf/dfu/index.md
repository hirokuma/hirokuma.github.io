# Nordic Semiconductor 調査 > Device Firmware Update(DFU)


## DFU の種類

* イメージの取得ルート別
  * DFU over UART
    * UART ポート
    * USB CDC-ACM(Virtual COM port)
  * DFU over BLE
* イメージの取得タイミング別
  * MCUboot
  * アプリ

![image](images/pattern.png)

## DFU over UART

### to MCUboot

#### via hardware UART (*1)

#### via virtual COM port (*2)


### to Application

#### via hardware UART (*3)

#### via virtual COM port (*4)

#### via BLE (*5)

## 署名の検証

* 鍵の指定方法
* 検証に失敗するとどうなるか
