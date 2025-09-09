---
layout: record
title: "scriptPubKey"
tags:
  - bitcoin
daily: false
date: "2025/09/09"
---

scriptPubKey 全体のデータ長は含まない

| type | scriptPubKey | length |
| -- | -- |
| P2PKH | `DUP` `HASH160` `14` `<20-byte pubkeyhash>` `EQUALVERIFY` `CHECKSIG` | 25 |
| P2SH | `HASH160` `14` `<20-byte scripthash>` `EQUAL` | 23 |
| P2WPKH | `0014` `<20-byte pubkeyhash>` | 22 |
| P2WSH | `0020` `<32-byte scripthash>` | 34 |
| P2TR | `5120` `<32-byte tweaked pubkey>` | 34 |
