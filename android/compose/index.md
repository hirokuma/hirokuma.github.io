# Jetpack Compose

Android Studio の新規プロジェクト作成で作るか、[archtecture-templates/base](https://github.com/android/architecture-templates/tree/base) を元にするのがよい。

## Composable関数

### レイアウト

[Column](https://developer.android.com/reference/kotlin/androidx/compose/foundation/layout/package-summary#Column(androidx.compose.ui.Modifier,androidx.compose.foundation.layout.Arrangement.Vertical,androidx.compose.ui.Alignment.Horizontal,kotlin.Function1))などを組み合わせる。  
これらも Composable 関数なので`Text`などの部品と組み合わせることができる。

* [androidx.compose.foundation.layout](https://developer.android.com/reference/kotlin/androidx/compose/foundation/layout/package-summary)
  * よく使う: `Box`, `Column`, `Row`, `Spacer`

### 部品

これを書いている時点ではマテリアルデザイン3(M3 と略されることもある)である。

[https://m3.material.io/](https://m3.material.io/)

`Text`のような基本部品はマテリアルデザインのバージョンごとに定義されているので注意しよう
(
[M2の`Text`](https://developer.android.com/reference/kotlin/androidx/compose/material/package-summary#Text(kotlin.String,androidx.compose.ui.Modifier,androidx.compose.ui.graphics.Color,androidx.compose.ui.unit.TextUnit,androidx.compose.ui.text.font.FontStyle,androidx.compose.ui.text.font.FontWeight,androidx.compose.ui.text.font.FontFamily,androidx.compose.ui.unit.TextUnit,androidx.compose.ui.text.style.TextDecoration,androidx.compose.ui.text.style.TextAlign,androidx.compose.ui.unit.TextUnit,androidx.compose.ui.text.style.TextOverflow,kotlin.Boolean,kotlin.Int,kotlin.Int,kotlin.Function1,androidx.compose.ui.text.TextStyle)), 
[M3の`Text`](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary#Text(kotlin.String,androidx.compose.ui.Modifier,androidx.compose.ui.graphics.Color,androidx.compose.ui.unit.TextUnit,androidx.compose.ui.text.font.FontStyle,androidx.compose.ui.text.font.FontWeight,androidx.compose.ui.text.font.FontFamily,androidx.compose.ui.unit.TextUnit,androidx.compose.ui.text.style.TextDecoration,androidx.compose.ui.text.style.TextAlign,androidx.compose.ui.unit.TextUnit,androidx.compose.ui.text.style.TextOverflow,kotlin.Boolean,kotlin.Int,kotlin.Int,kotlin.Function1,androidx.compose.ui.text.TextStyle))
)。

* [androidx.compose.material3](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary)
  * よく使う:
    * `Button`, `Card`, `Text`
    * `MaterialTheme`, `Scaffold`, `Surface`
  * (ドキュメントのページが重たい)

`Image` は別のパッケージである。

* [androidx.compose.foundation](https://developer.android.com/reference/kotlin/androidx/compose/foundation/package-summary)
  * よく使う: `Image`

#### Modifier

だいたいの Composable関数で引数に指定できる `Modifier`は調整に使う。  
同じ`Modifier`でも指定する関数によってパラメータにできないものもある。  
また、`Modifier`でも Composable関数でも同じような設定ができるものもある。  
一概にどちらがどうということは言えないので、必要になったときに調べると良いだろう。

* [androidx.compose.ui.Modifier](https://developer.android.com/reference/kotlin/androidx/compose/ui/Modifier)

### テーマ

新規プロジェクトで作成した場合、`ui/theme/Theme.kt`に`プロジェクト名Theme`という Composable関数 が作られている。  
デフォルトではダイナミックカラーが有効になっているので、実機で動作させるとエミュレータと色が異なるかもしれない。  
ダイナミックカラーを無効にしたり実機が未対応だったりすると[デフォルト(baseline)のテーマ](https://m3.material.io/styles/color/static/baseline)で表示される。  
アプリでのテーマを組み込むこともできる。  
自作するのは大変なのでいくつかテーマを作ってくれるサイトがある。  
アプリ名がないため`Theme.kt`のテーマ定義名が違っているくらいである。

* [Material Theme Builder](https://material-foundation.github.io/material-theme-builder/)

## 画面遷移

画面の遷移もアプリ内とアプリ外があるが、ここではアプリ内について記載する。

* [ナビゲーションの原則  -  Android Developers](https://developer.android.com/guide/navigation/principles?hl=ja)
* [ナビゲーション  -  Android Developers](https://developer.android.com/guide/navigation?hl=ja)
* [Compose で画面間を移動する - Codelabs](https://developer.android.com/codelabs/basic-android-kotlin-compose-navigation?hl=ja#0)
  * アプリ内の遷移
  * 別アプリへの遷移(`Intent`)

### 概要

ここでは画面遷移を固定で実装しておく方式について概要を記載する。  
Android Studio でプロジェクトを作った場合は画面遷移のコードはない。  
architecture-templates を使った場合は `NavHost()`は用意してあるが画面が 1枚しかないので遷移しない。  
[codelabs](https://developer.android.com/codelabs/basic-android-kotlin-compose-navigation?hl=ja#0)で一通りやって見るのがよいと思う。

* ライブラリを組み込む
* 画面遷移用の Composable関数を用意する
  * 画面名と対応する Composable関数を決めておく
  * `NavHost()`に、画面名と Composable関数の呼び出し方を定義する(`composable()`)
* Main Activity で呼び出すのは画面の Composable関数ではなく画面遷移の Composable関数に変更する
* 遷移は`rememberNavController()`のインスタンスを使う
  * `.navigate(画面名)`: 指定した画面に遷移
  * `.popBackStack()`: 戻る

画面遷移をするのに`rememberNavController()`のインスタンスがいるので、
それをどこで持ってどうするのがよいのかがまだよくわかっていない(2024/10/30現在)。  
[architecture-samples](https://github.com/android/architecture-samples/blob/130f5dbebd0c7b5ba195cc08f25802ed9f0237e5/app/src/main/java/com/example/android/architecture/blueprints/todoapp/TodoNavGraph.kt) では画面の Composable関数にボタン押下イベント関数として渡しているようだ。
