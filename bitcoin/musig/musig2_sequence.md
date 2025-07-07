---
layout: "record"
title: "MuSig2 Sequence"
tags:
  - bitcoin
daily: false
date: "2025/03/01"
---

## Generate MultiSig pubkey

libsecp256k1 library returns `secp256k1_musig_keyagg_cache` when calculating public key aggregation. 
This value is used when calculating partial signatures.

```mermaid
sequenceDiagram
  participant Alice
  participant coordinator
  participant Bob

  Alice->>coordinator: internal pubkey(pubA)
  Bob->>coordinator: internal pubkey(pubB)
  Note over coordinator: aggregate pubA and pubB
  coordinator-->>Alice: pubB
  Note over Alice: aggregate pubA and pubB
  coordinator-->>Bob: pubA
  Note over Bob: aggregate pubA and pubB
```

## Sign

In libsecp256k1 library, calling `secp256k1_musig_nonce_process()` returns `secp256k1_musig_session`. 
This value is used when calculating partial signatures and aggregate signatures.

```mermaid
sequenceDiagram
  participant Alice
  participant coordinator
  participant Bob

  Note over Alice,Bob: round 1
  Note over Alice: create secNonceA/pubNonceA
  Alice->>coordinator: pubNonceA
  Note over Bob: create secNonceB/pubNonceB
  Bob->>coordinator: pubNonceB
  Note over coordinator: aggregate pubNonceA and pubNonceB-->aggNonce
  coordinator-->>Alice: aggNonce
  coordinator-->>Bob: aggNonce

  Note over Alice,Bob: round 2
  Note over Alice: partial sign(sigA)
  Alice->>coordinator: sigA
  Note over coordinator: verify SigA
  Note over Bob: partial sign(sigB)
  Bob->>coordinator: sigB
  Note over coordinator: verify SigB
  Note over coordinator: aggregate sigA and sigB
  Note over coordinator: broadcast signed transaction
```
