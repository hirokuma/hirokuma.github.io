---
layout: record
title: "Raspberry Piセットアップでよくやること"
tags:
  - linux
  - raspi
daily: false
date: "2025/07/12"
---

## 本体

うちにあってよく使いそうなものだけリンクを載せておく。

* [Buy a Raspberry Pi – Raspberry Pi](https://www.raspberrypi.com/products/)
  * [Pi4 Model B](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/)
  * [Pi3 Model B+](https://www.raspberrypi.com/products/raspberry-pi-3-model-b-plus/)
  * [Pi3 Model B](https://www.raspberrypi.com/products/raspberry-pi-3-model-b/)

## Pi Imager

Raspbian OSは[Pi Imager](https://www.raspberrypi.com/software/)を使ってSDカードを作るのが楽だろう。  
これを使うと、OSイメージをダウンロードしてSDカードに展開するだけでなく、デフォルトのままにしたくないhostnameやログインアカウント、WiFi設定やSSH設定などのカスタマイズができる。

* <a href="images/imager1.png"><img src="images/imager1.png"  width="50%"></a>
* <a href="images/imager2.png"><img src="images/imager2.png"  width="50%"></a>

私はWindows版のv1.9.4を使ったのだが、いくつかうまくいかなかった。
詳しいことは調べていないのでやり方が悪かっただけかもしれない。

* SSHは有効になったが`authorized_keys`が設定されなかった
  * パスワード認証は設定できた
  * ログインしてから自分で`authorized_keys`や`sshd_config`を書き直した
* WiFiの設定ができていなかった
  * 有線LANで接続した
  * ログインして`wlan0`が無効になっていたので、`rfkill unblock`して`ifconfig up`したあと`raspi-config`で設定した

## ストレージの追加

SDカードではいろいろ足りないので外部ストレージを付けたくなる。  
その場合はUSBを使うことになるだろう。

Raspberry Pi3までは USB2.0のポートだけで、それ以降になるとUSB3.0のポートが加わる。  
なお、USB2.0は480Mbps、USB3.0は5Gbps、USB3.1 Gen2は10Gbpsとなっている。  
今では USB3.0という名称はなく、USB3.1 Gen1ということになっているのだとか。  
正式な情報を見たわけではないので、自分で調べた方がよいだろう。

### デバイス探し

SATA-USBケーブルに接続したSSDをRaspberry Pi3に挿すと`dmesg`にこのようなログが出る。  
Windowsで使っていたNTFSフォーマットのディスクで、ボリューム名は"Free"である。

```dmesg
usb-storage 1-1.2:1.0: USB Mass Storage device detected
usb-storage 1-1.2:1.0: Quirks match for vid 152d pid 0578: 1000000
scsi host0: usb-storage 1-1.2:1.0
scsi 0:0:0:0: Direct-Access     TIMELY                    0801 PQ: 0 ANSI: 6
sd 0:0:0:0: [sda] 234441648 512-byte logical blocks: (120 GB/112 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 47 00 00 08
sd 0:0:0:0: [sda] Disabling FUA
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:0:0: Attached scsi generic sg0 type 0
 sda: sda1
sd 0:0:0:0: [sda] Attached SCSI disk
```

`dmesg`はいろいろなログがあるので`lsblk`の方がわかりやすいか。

```console
 $ lsblk -l
NAME      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda         8:0    0 111.8G  0 disk
sda1        8:1    0 111.8G  0 part
mmcblk0   179:0    0  14.8G  0 disk
mmcblk0p1 179:1    0   512M  0 part /boot/firmware
mmcblk0p2 179:2    0  14.3G  0 part /
```

### フォーマット

`sda`であることがわかるので`fdisk`でパーティションの確認をし、今回はパーティションを削除してLinuxパーティションだけ作る。

```console
$ sudo fdisk -l /dev/sda
Disk /dev/sda: 111.79 GiB, 120034123776 bytes, 234441648 sectors
Disk model:
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x59ac01ea

Device     Boot Start       End   Sectors   Size Id Type
/dev/sda1        2048 234438655 234436608 111.8G  7 HPFS/NTFS/exFAT

...(中略)...

Device     Boot Start       End   Sectors   Size Id Type
/dev/sda1        2048 234441647 234439600 111.8G 83 Linux
```

作ったパーティション`sda1`をext4でフォーマットする。

```console
$ sudo mkfs -t ext4 /dev/sda1
(略)
```

### UUID

`sda`だと物理過ぎてUSB接続の仕方などで名称が変わってしまうかもしれない。  
IDE接続の時はHDDのジャンパ接続で何かやっていたような気がするが、もう記憶にない。

ともかく、今はUUIDでディスクを識別することができるので、そちらにした方がよい。  
`blkid`では2つUUIDが出力されるが、`/etc/fstab`では`PARTUUID`を使っていた。
OSによって違うらしい。

```console
$ sudo blkid | grep sda
/dev/sda1: LABEL="Free" BLOCK_SIZE="512" UUID="CE04E7D004E7BA1B" TYPE="ntfs" PARTUUID="59ac01ea-01"
```

mount先ディレクトリを作っておけば`mount`できる。

```console
$ sudo mount -t ext4 PARTUUID="59ac01ea-01" /mnt/usb
```

ディレクトリのownerは使用するユーザやグループを設定すると良いだろう。  
hogeさんだけが使うならこんな感じでよいと思う。

```console
$ sudo chown hoge:hoge /mnt/usb
```

### fstab

再起動のたびに`mount`するのは面倒ならば`/etc/fstab`に書いておくとよい。 
項目のどれがなんだったかは忘れやすい([fstab](https://www.man7.org/linux/man-pages/man5/fstab.5.html))。  
項目間はタブ文字かスペースなので、特に4番目はコンマで区切るときにスペースをうっかり挟まないこと。

1. fs_spec: デバイス名 or `PARTUUID`
2. fs_file: マウントポイント
3. fs_vfstype: フォーマット
4. fs_mntops: オプション。特になければ`defaults`。USBだと外すことがあるから`defaults,nofail`が無難か？
5. fs_freq: dumpしない(`0`)かする(`1`)か。特になければ`0`。
6. fs_passno: fsckの順番？ rootファイルシステムは`1`、それ以外は`2`。

`/etc/fstab`に書いてあるデバイスに起動時接続できなかったらpanicになるんじゃなかったっけ・・・？  
心配になったが`findmnt`でチェックできるそうだ。

* [/etc/fstab を書き換えたあとはreboot前に必ずfindmntコマンドで検証しよう #Linux - Qiita](https://qiita.com/interu/items/2cb1d699f3afef2e1bb4)

```console
$ sudo findmnt --verify
Success, no errors or warnings detected
```

## Docker

Raspbian OS 64bit の場合は [Debian](https://docs.docker.com/engine/install/debian/)でのインストールを参照する。

インストールは手順通りで良い。

### 保存場所

うちのRaspberry Pi3はMicroSDにOSを焼いて立ち上げている。  
USBストレージからも立ち上げることはできるそうだ。

* [Raspberry pi 3 Model B+ を USB SSD から起動する - Raspberry Pi 備忘録 / Mbedもあるよ！](https://pongsuke.hatenablog.com/entry/2018/08/15/183341)

何を気にしているかというと、MicroSD は容量も大きくないし高頻度なアクセスは心配なので極力SSDに逃がしたいのだ。  
dockerは自分が使う気がなくてもツールが要求するのでインストールするのだが、
お試しで動かしたプロジェクトの残骸が残りっぱなしになったりしやすい。  
面倒ごとを回避するなら、保存場所を容量が大きいストレージにするとよいだろう。速度は落ちるかもしれんが。

* [Dockerイメージの格納場所を変更する方法](https://zenn.dev/karaage0703/articles/46195947629c35)

ここまできれいにしなくても、`/var/lib/docker/`に保存されることが分かるなら、ディレクトリごと移動してシンボリックリンクしておけばよいだろう。

### group

rootではないユーザでも使えるようにしておくと便利だろう。

* [Post-installation steps - Docker Docs](https://docs.docker.com/engine/install/linux-postinstall/)

```console
$ sudo usermod -aG docker $USER
```

## Swap file

Rustのプロジェクトのせいかどうかは分からないが、`cargo build`はかなりメモリを消費すると思っている。  
Raspbian OSをインストールするとSwap file無しになっているのだが、メモリが足りずにビルドに失敗することがある。
そうでなくても、メモリが不足すると全体的に不安定になるので、それくらいだったらSwap fileを設定した法が精神的によろしい。

よくわからないのが"dphys-swapfile"だ。  
`swapon -s`で見ると`/var/swap`だけがある。  
これを`systemctl stop`で止めると、何も出てこない。  
つまり、これでswapファイルの制御ができているはずだ。
ならばこちらのサイトのように`/etc/dphys-swapfile`を書き換えるのが自然な気がする。

* [Raspberry PIにてSWAPファイルのリサイズ #RaspberryPi - Qiita](https://qiita.com/neomi/items/9212885b7c08a17f1572)

ただ、今までのRaspberry Piは`dd`コマンドでswapfileを作る方式の説明が多かったように思う。

* [Raspberry PiにSwapファイルを作成する - 作業中のメモ](https://workspacememory.hatenablog.com/entry/2021/03/27/230512)

```console
$ sudo systemctl stop dphys-swapfile
$ swapon -s
$ sudo vi /etc/dphys-swapfile
```

編集内容
```
CONF_SWAPFILE=/mnt/usb/swapfile
CONF_SWAPSIZE=2048
```

続き

```console
$ sudo dphys-swapfile setup
$ sudo dphys-swapfile swapon
$ sudo systemctl start dphys-swapfile
$ swapon -s
Filename                                Type            Size            Used            Priority
/mnt/usb/swapfile                       file            2097148         1059288         -2
$ sudo rm /var/swap
```

これで見た目上は成り立っている。  
`dphys-swapfile`は以前からあったと思うのだが、なぜこの方式ではなくわざわざ`dd`でファイルを作っていたのだろうか。
単に私が目にした記事がそうだっただけで、設定ファイルを書き換える方式も説明されていたのだろうか。。。

