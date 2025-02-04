# MuSig2 Sequence

## Generate MultiSig pubkey

libsecp256k1 library returns `secp256k1_musig_keyagg_cache` when calculating public key aggregation. 
This value is used when calculating partial signatures.

```mermaid
sequenceDiagram
  participant Alice
  participant coodinator
  participant Bob

  Alice->>coodinator: internal pubkey(pubA)
  Bob->>coodinator: internal pubkey(pubB)
  Note over coodinator: aggregate pubA and pubB
  coodinator-->>Alice: pubB
  Note over Alice: aggregate pubA and pubB
  coodinator-->>Bob: pubA
  Note over Bob: aggregate pubA and pubB
```

## Sign

In libsecp256k1 library, calling `secp256k1_musig_nonce_process()` returns `secp256k1_musig_session`. 
This value is used when calculating partial signatures and aggregate signatures.

```mermaid
sequenceDiagram
  participant Alice
  participant coodinator
  participant Bob

  Note over Alice,Bob: round 1
  Note over Alice: create secNonceA/pubNonceA
  Alice->>coodinator: pubNonceA
  Note over Bob: create secNonceB/pubNonceB
  Bob->>coodinator: pubNonceB
  Note over coodinator: aggregate pubNonceA and pubNonceB-->aggNonce
  coodinator-->>Alice: aggNonce
  coodinator-->>Bob: aggNonce

  Note over Alice,Bob: round 2
  Note over Alice: partial sign(sigA)
  Alice->>coodinator: sigA
  Note over coodinator: verify SigA
  Note over Bob: partial sign(sigB)
  Bob->>coodinator: sigB
  Note over coodinator: verify SigB
  Note over coodinator: aggregate sigA and sigB
  Note over coodinator: broadcast signed transaction
```
