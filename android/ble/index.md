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
`status`の値は [ATT Error Codes](/nrf/gatt_error_codes.html) の値になっていると思われる。

[BluetoothGattCallback.onConnectionStateChange](https://developer.android.com/reference/android/bluetooth/BluetoothGattCallback#onConnectionStateChange(android.bluetooth.BluetoothGatt,%20int,%20int))

```java
public void onConnectionStateChange (BluetoothGatt gatt, 
                int status, 
                int newState)
```

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
