# ビルドについて

_最終更新日: 2024/11/08_

## よく参照するビルド済みファイル

ビルドしないと生成されないため、それまでは vscode でマクロを参照してもエラー表示になる。

* Kconfig
  * `<build>/zephyr/include/generated/autoconf.h`
  * `CONFIG_` が実際に展開されたヘッダファイルになっている
* Devicetree
  * `<build>/zephyr/include/generated/devicetree_generated.h`
  * エイリアスなどがマクロになって定義されたヘッダファイルになっている

## コンパイルでのマクロ追加

gcc の `-Dマクロ` の代わりに `prj.conf` に自分のマクロを書いてもビルドでエラーになる。

* Build Configuration の "Extra CMake arguments"
  * `-Dマクロ` を列挙する
  * Build Configuration にしか残らないので、一時的に使いたい場合に向いているだろう
* CMakeLists.txt に追加する
  * [add_definitions](https://cmake.org/cmake/help/latest/command/add_definitions.html)に `-Dマクロ` を列挙する
  * [add_compile_definitions](https://cmake.org/cmake/help/latest/command/add_compile_definitions.html#command:add_compile_definitions)に `VAR=value` の形で列挙する
  * 私があまり CMake 慣れしていないのもあり、設定したのを忘れそうなのであまり使わないようにしている
* Kconfig ファイルを作る
  * ファイルに残るのでわかりやすい
  * リポジトリにそのまま残るので、`prj.conf` を別にした方が良いのかも？
    * Build Configuration で使用する `prj.conf` を指定するので "Extra CMake arguments" とあまり変わらないのか
    * ファイルに残るという点を行かす場合に使うとよいだろう

### Kconfig ファイルを作る場合

例えば `CONFIG_DEBUG_ENABLED`(取り得る値は bool) を追加する場合、プロジェクトのルートディレクトリに `Kconfig` ファイルを作って以下のように記述する。

```kconfig
source "Kconfig.zephyr"

menu "Debug Mode"

config DEBUG_ENABLED
	bool "Debug Enabled"
	default y

endmenu
```

これで `prj.conf` に `CONFIG_DEBUG_ENABLED=y` のように書くことができる。  
確認は Prisitine Build してから `<build>/zephyr/include/generated/autoconf.h` を開いて検索すると良い。
