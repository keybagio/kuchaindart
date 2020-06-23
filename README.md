# Kuchain Dart Library 

Convert from [testkuchainjs@0.1.4](https://www.npmjs.com/package/testkuchainjs)

This library supports kuchain address generation and verification. It enables you to create an offline signature functions of different types of transaction messages. 

**[WARNING] This library is under ACTIVE DEVELOPMENT and should be treated as alpha version. We will remove this warning when we have a release that is stable, secure, and propoerly tested** 

## Usage

```dart
import 'package:kuchaindart/kuchaindart.dart';

const chainId = "testing";
const url = "http://127.0.0.1:1317";
Kuchain kuchain = Kuchain(
  url: url,
  chainId: chainId,
);

const mnemonic = "..."
String address = kuchain.getAddress(mnemonic);
final ecpairPriv = kuchain.getECPairPriv(mnemonic);
```

- Create an account with a specialized auth.

```dart
// TODO kuchain.newCreateAccMsg
```

- Sign transaction by using sign and broadcast which use REST API of Kuchain

```dart
final signedTx = await kuchain.sign(msg, ecpairPriv);
// TODO kuchain.broadcast
```

## Supporting Message Types (Updating...)
- If you need more message types, you can commit issues

## Documentation

This library is simple and easy to use. We don't have any formal documentation yet other than examples. Ask for help if our examples aren't enough to guide you

## Contribution

- Contributions, suggestions, improvements, and feature requests are always welcome

## Script
```
// Format code
dartfmt -w lib example

// Publish validation
 pub publish --dry-run --verbose
```