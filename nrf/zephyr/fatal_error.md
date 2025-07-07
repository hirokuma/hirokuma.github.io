---
layout: "record"
title: "Zephyr OS: Fatal Error Handling"
tags:
  - ble
  - ncs
daily: false
date: "2024/11/08"
---

[k_panic()](https://docs.nordicsemi.com/bundle/zephyr-apis-latest/page/kernel_8h.html#aedd541f707b1463aaac15c7798340329) などによってシステム復帰ができない場合は `k_sys_fatal_error_handler()` が呼び出される。

* [Kernel Panic](https://docs.nordicsemi.com/bundle/ncs-latest/page/zephyr/kernel/services/other/fatal.html)
* [k_sys_fatal_error_handler()](https://docs.zephyrproject.org/apidoc/latest/group__fatal__apis.html#ga255cc816d227f0a5c0e80e61bfba11fa)

`k_sys_fatal_error_handler()` は weak symbol なのでオーバーライド可能である。

* [sdk-nrf/lib/fatal_error/fatal_error.c at v2.8.0 · nrfconnect/sdk-nrf](https://github.com/nrfconnect/sdk-nrf/blob/v2.8.0/lib/fatal_error/fatal_error.c#L16-L27)
* [sdk-nrf/applications/ipc_radio/src/bt_hci_ipc.c at v2.8.0 · nrfconnect/sdk-nrf](https://github.com/nrfconnect/sdk-nrf/blob/v2.8.0/applications/ipc_radio/src/bt_hci_ipc.c#L317-L340)
* [sdk-nrf/applications/nrf5340_audio/src/utils/error_handler.c at v2.8.0 · nrfconnect/sdk-nrf](https://github.com/nrfconnect/sdk-nrf/blob/v2.8.0/applications/nrf5340_audio/src/utils/error_handler.c#L54-L57)
