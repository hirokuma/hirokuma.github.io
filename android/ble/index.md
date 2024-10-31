# BLE 操作(Jetpack Compose)

_2024/10/31_

Android の API としては Peripheral として動作させる機能もありそうだが、
ここでは Central のみ扱う。  
今の段階では Peripheral に接続して Characteristic の操作をするところまでしかやっていない。

記事が API 34 にアップデートされているので、ここに書いてあって不足する内容は以下を読んでもらう方がよいだろう。

* [The Ultimate Guide to Android Bluetooth Low Energy - Punch Through](https://punchthrough.com/android-ble-guide/)

## Permissions

通信するためアプリに permission の設定が必要である。  
これは Android OS のバージョンでいろいろ変遷している。  
現在は API 34 までサポートしないと Google Play にアップロードできない

```xml
    <uses-permission android:name="android.permission.BLUETOOTH"
        android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"
        android:maxSdkVersion="30" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"
        android:maxSdkVersion="30"
        tools:ignore="CoarseFineLocation" />

    <uses-permission android:name="android.permission.BLUETOOTH_SCAN"
        android:usesPermissionFlags="neverForLocation"
        tools:targetApi="s" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

    <uses-feature android:name="android.hardware.bluetooth_le" android:required="true"/>
```

`AndroidManifest.xml` に書くだけでなく、アプリを実行した後に許可を得るコードを書いておくことも忘れないように。  
本体の Bluetooth機能が有効になっていることも確認しよう。

## スキャン

機器のスキャンには `BluetoothLeScanner` のインスタンスを使う。  
`Context` は `Activity` でもよかったがアプリ全体なので `Application` でよいかもしれない。

```kotlin
val bluetoothManager = context.getSystemService(BluetoothManager::class.java)
val bluetoothAdapter = bluetoothManager.adapter
bluetoothLeScanner = bluetoothAdapter.bluetoothLeScanner
```

本体の Bluetooth機能がオフになっていると `bluetoothLeScanner` は `null` だった。

スキャンは `BluetoothLeScanner.startScan(callback)` で開始する。  
停止は `BluetoothLeScanner.stopScan()` である。  
`stopScan()`もコールバック関数を指定するのだが、これは停止時の失敗を受け取るためだろうか？

見つかったデバイスはコールバックされる。
同じデバイスが定期的にコールバックされるので、リストを作る場合は重複に注意しておく。

コールバックでは`ScanResult`が返され、その中に`BluetoothDevice`があり、接続にはそれを使う。

## 接続

スキャンで見つかった`BluetoothDevice` に対して`.connectGatt()`で接続を要求する。  
以降、接続後に行った要求についてはパラメータで渡した `BluetoothGattCallback` に通知される。

API は API18 から追加されたものと API33 からパラメータ違いで追加されて API18 の同名メソッドが deprecated になったものがある。  
同名のメソッドがあるよく使いそうな API は以下。

* `BluetoothGattCallback`
  * `onCharacteristicChanged`
  * `onCharacteristicRead`
  * `onDescriptorRead`
* `BluetoothGatt`
  * `writeCharacteristic`
  * `writeDescriptor`

`BluetoothGattCallback` では例えば以下のような違いがある。  
API33 からは値も引数で戻ってくるのでアクセスする手間が省ける。

```kotlin
// API 18
override fun onCharacteristicRead(
    gatt: BluetoothGatt?,
    characteristic: BluetoothGattCharacteristic?,
    status: Int
)

// API 33
override fun onCharacteristicRead(
    gatt: BluetoothGatt,
    characteristic: BluetoothGattCharacteristic,
    value: ByteArray,
    status: Int
)
```

コールバックでどちらの API が呼ばれるかは実行環境次第である。  
試したところ、API 33 以降は両方とも呼ばれていた。  
Read の結果で挙動を起こす場合は 2回実行しないように実装で気をつける必要がある。

`BluetoothGatt` の API も同じような違いで手間が少しだけ省略できる。

```kotlin
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
    gatt.writeDescriptor(descriptor, BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)
} else {
    descriptor.value = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
    gatt.writeDescriptor(descriptor)
}
```

### Service / Characteristic

接続が成功すると`onConnectionStateChange()`で`BluetoothProfile.STATE_CONNECTED`が通知される。  
操作する Service や Characteristic が決まっているなら、接続時に確認すると良いだろう。

Characteristic を操作する API は上記参照。  
API 別に呼び分けが必要なのと、コールバックで複数回処理しないようにするという点を守ること。

#### Notification / Indication

Notification や Indication を受け入れるのであれば `BluetoothGatt.setCharacteristicNotification()` で有効にするのと、
CCCD に `BluetoothGatt.writeDescriptor()` で Notification/Indication のフラグを立てる。

変化があった場合は `BluetoothGattCallback.onCharacteristicChanged()` が呼ばれる。

### status

`BluetoothGattCallback`のコールバック関数で引数に`status`を返すものがある。  
`status`の値は ATT Error Codes の値になっていると思われる。

[BluetoothGattCallback.onConnectionStateChange](https://developer.android.com/reference/android/bluetooth/BluetoothGattCallback#onConnectionStateChange(android.bluetooth.BluetoothGatt,%20int,%20int))

```java
public void onConnectionStateChange (BluetoothGatt gatt, 
                int status, 
                int newState)
```

### ATT Error Codes

#### Core v5.1, Vol.3, Part F "3.4.1.1 Error Response"

| Name | Error Code | Description |
|---|---|---|
| Invalid Handle | 0x01 | The attribute handle given was not valid on this server. |
| Read Not Permitted | 0x02 | The attribute cannot be read. |
| Write Not Permitted | 0x03 | The attribute cannot be written. |
| Invalid PDU | 0x04 | The attribute PDU was invalid. |
| Insufficient Authentication | 0x05 | The attribute requires authentication before it can be read or written. |
| Request Not Supported | 0x06 | Attribute server does not support the request received from the client. |
| Invalid Offset | 0x07 | Offset specified was past the end of the attribute. |
| Insufficient Authorization | 0x08 | The attribute requires authorization before it can be read or written. |
| Prepare Queue Full | 0x09 | Too many prepare writes have been queued. |
| Attribute Not Found | 0x0A | No attribute found within the given attri-bute handle range. |
| Attribute Not Long | 0x0B | The attribute cannot be read using the Read Blob Request. |
| Insufficient Encryption Key Size | 0x0C | The Encryption Key Size used for encrypting this link is insufficient. |
| Invalid Attribute Value Length | 0x0D | The attribute value length is invalid for the operation. |
| Unlikely Error | 0x0E | The attribute request that was requested has encountered an error that was unlikely, and therefore could not be completed as requested. |
| Insufficient Encryption | 0x0F | The attribute requires encryption before it can be read or written. |
| Unsupported Group Type | 0x10 | The attribute type is not a supported grouping attribute as defined by a higher layer specification. |
| Insufficient Resources | 0x11 | Insufficient Resources to complete the request. |
| Database Out Of Sync | 0x12 | The server requests the client to redis-cover the database. |
| Value Not Allowed | 0x13 | The attribute parameter value was not allowed. |
| Application Error | 0x80 – 0x9F | Application error code defined by a higher layer specification. |
| Common Profile and Service Error Codes | 0xE0 – 0xFF | Common profile and service error codes defined in [Core Specification Supplement], Part B. |
| Reserved for future use | All other values | Reserved for future use. |

#### [gatt_api.h](https://android.googlesource.com/platform/external/bluetooth/bluedroid/+/master/stack/include/gatt_api.h)

| #define | value |
|---|---|
| GATT_SUCCESS | 0x00 |
| GATT_INVALID_HANDLE | 0x01 |
| GATT_READ_NOT_PERMIT | 0x02 |
| GATT_WRITE_NOT_PERMIT | 0x03 |
| GATT_INVALID_PDU | 0x04 |
| GATT_INSUF_AUTHENTICATION | 0x05 |
| GATT_REQ_NOT_SUPPORTED | 0x06 |
| GATT_INVALID_OFFSET | 0x07 |
| GATT_INSUF_AUTHORIZATION | 0x08 |
| GATT_PREPARE_Q_FULL | 0x09 |
| GATT_NOT_FOUND | 0x0a |
| GATT_NOT_LONG | 0x0b |
| GATT_INSUF_KEY_SIZE | 0x0c |
| GATT_INVALID_ATTR_LEN | 0x0d |
| GATT_ERR_UNLIKELY | 0x0e |
| GATT_INSUF_ENCRYPTION | 0x0f |
| GATT_UNSUPPORT_GRP_TYPE | 0x10 |
| GATT_INSUF_RESOURCE | 0x11 |
| GATT_ILLEGAL_PARAMETER | 0x87 |
| GATT_NO_RESOURCES | 0x80 |
| GATT_INTERNAL_ERROR | 0x81 |
| GATT_WRONG_STATE | 0x82 |
| GATT_DB_FULL | 0x83 |
| GATT_BUSY | 0x84 |
| GATT_ERROR | 0x85 |
| GATT_CMD_STARTED | 0x86 |
| GATT_PENDING | 0x88 |
| GATT_AUTH_FAIL | 0x89 |
| GATT_MORE | 0x8a |
| GATT_INVALID_CFG | 0x8b |
| GATT_SERVICE_STARTED | 0x8c |
| GATT_ENCRYPED_MITM | GATT_SUCCESS |
| GATT_ENCRYPED_NO_MITM | 0x8d |
| GATT_NOT_ENCRYPTED | 0x8e |
| GATT_CONGESTED | 0x8f |
| RFU | 0xE0 ~ 0xFC |
| GATT_CCC_CFG_ERR | 0xFD |
| GATT_PRC_IN_PROGRESS | 0xFE |
| GATT_OUT_OF_RANGE | 0xFF |

## メモ

Android Studio でプロジェクトを作るとデフォルトで API 24(Android 7)から対応したアプリになる。  
手元に Android 7.0 の実機があったので動かしたのだが、BLE 接続を行うと失敗した。  
`status=133`で`GATT_ERROR`だった。

```log
bt_btif                 com.android.bluetooth                W  bta_gattc_conn_cback() - cif=3 connected=0 conn_id=3 reason=0x003e
bt_btif                 com.android.bluetooth                W  bta_gattc_conn_cback() - cif=4 connected=0 conn_id=4 reason=0x003e
bt_btif                 com.android.bluetooth                W  bta_gattc_conn_cback() - cif=5 connected=0 conn_id=5 reason=0x003e
bt_btif                 com.android.bluetooth                W  bta_gattc_conn_cback() - cif=6 connected=0 conn_id=6 reason=0x003e
bt_btm_sec              com.android.bluetooth                I  btm_sec_disconnected clearing pending flag handle:2 reason:62
BtGatt.GattService      com.android.bluetooth                D  onConnected() - clientIf=6, connId=0, address=75:0D:12:BD:96:F1
BluetoothGatt           work.hirokuma.bleledcontrol          D  onClientConnectionState() - status=133 clientIf=6 device=75:0D:12:BD:96:F1
```
