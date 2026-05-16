---
layout: record
title: "clang: Ceedling / Unity / CMock"
tags:
  - clang
  - tools
daily: false
date: "2025/09/15"
---

## 概要

* [Ceedling — Throw The Switch](https://www.throwtheswitch.org/ceedling)

## インストール

Ruby 3 以降のバージョンが必要。  

* [Getting Started](https://github.com/ThrowTheSwitch/Ceedling/blob/c50ff9dd9a73301f4c930cc37f39123f8aaa2cb8/README.md#-getting-started)

```shell
$ gem install ceedling
```

## HOW CEEDLING WORKS

[Ceedling](https://www.throwtheswitch.org/ceedling) のページにあった内容をやってみる。  
プロジェクトやモジュール名だけ変更している。

### プロジェクト作成

ディレクトリが作成されてディレクトリと設定ファイルが展開される。  
git の設定などは行われない。

```shell
$ ceedling new sample-ceedling1
      create  sample-ceedling1
      create  sample-ceedling1/src
      create  sample-ceedling1/test
      create  sample-ceedling1/test/support
      create  sample-ceedling1/project.yml

🌱 New project 'sample-ceedling1' created at ./sample-ceedling1/
```

### `hello_world`モジュールの追加

```shell
$ ceedling module:create[hello_world]
🚧 Loaded project configuration from working directory.
 > Using: /home/hirokuma/clang/ceeee/sample-ceedling1/project.yml
 > Working directory: /home/hirokuma/clang/ceeee/sample-ceedling1

Ceedling set up completed in 104 milliseconds
File src/hello_world.c created
File src/hello_world.h created
File test/test_hello_world.c created
Generate Complete

Ceedling operations completed in 5 milliseconds
```

### テスト

関数の中身やテストは書いてあるとおりにした。  
テストは Unity だろう。

```shell
$ ceedling test:all
🚧 Loaded project configuration from working directory.
 > Using: /home/hirokuma/clang/ceeee/sample-ceedling1/project.yml
 > Working directory: /home/hirokuma/clang/ceeee/sample-ceedling1

Ceedling set up completed in 71 milliseconds

👟 Preparing Build Paths...

👟 Collecting Test Context
--------------------------
Parsing test_hello_world.c for build directive macros, #includes, and test case names...

👟 Ingesting Test Configurations
--------------------------------
Collecting search paths, flags, and defines test_hello_world.c...

👟 Determining Files to be Generated...

👟 Mocking
----------

👟 Test Runners
---------------
Generating runner for test_hello_world.c...

👟 Determining Artifacts to Be Built...

👟 Building Objects
-------------------
Compiling test_hello_world.c...
Compiling test_hello_world::hello_world.c...
Compiling test_hello_world::test_hello_world_runner.c...
Compiling test_hello_world::unity.c...

👟 Building Test Executables
----------------------------
Linking test_hello_world.out...

👟 Executing
------------
Running test_hello_world.out...

-----------------------
✅ OVERALL TEST SUMMARY
-----------------------
TESTED:  1
PASSED:  1
FAILED:  0
IGNORED: 0


Ceedling operations completed in 288 milliseconds
```

## memo

[Ceedling/docs/CeedlingPacket.md at master · ThrowTheSwitch/Ceedling](https://github.com/ThrowTheSwitch/Ceedling/blob/c50ff9dd9a73301f4c930cc37f39123f8aaa2cb8/docs/CeedlingPacket.md)
