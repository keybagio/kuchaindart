# Kuchain Dart Library 

Convert from [kuchainjs@0.0.9](https://www.npmjs.com/package/kuchainjs)

This library supports kuchain address generation and verification. It enables you to create an offline signature functions of different types of transaction messages. 

**[WARNING] This library is under ACTIVE DEVELOPMENT and should be treated as alpha version. We will remove this warning when we have a release that is stable, secure, and propoerly tested** 

## Import 
```dart
import 'package:kuchaindart/kuchaindart.dart';
```

## Usage
- Kuchain: Generate Kuchain address from mnemonic 

```dart
import 'package:kuchaindart/kuchaindart.dart';

const chainId = 'testing';
const url = 'http://127.0.0.1:1317';
Kuchain kuchain = Kuchain(
  url: url,
  chainId: chainId,
);

const mnemonic = '...'
final address = kuchain.getAddress(mnemonic);
final ecpairPriv = kuchain.getECPairPriv(mnemonic);
```

- Kuchain: Generate Kuchain address from base64 

```dart
import 'package:kuchaindart/kuchaindart.dart';

const chainId = 'testing';
const url = 'http://127.0.0.1:1317';
Kuchain kuchain = Kuchain(
  url: url,
  chainId: chainId,
);

const priBase64 = '...';
final prikey = kuchain.importPriKeyBase64(priBase64);
final auth = kuchain.getAddressFromPriKey(prikey);
```

- Create an account with a specialized auth.

```dart
final newCreateAccMsg = await kuchain.newCreateAccMsg(
  'validator',
  'acc1',
  auth,
);
print(newCreateAccMsg);
```

- Sign transaction by using sign and broadcast which use REST API of Kuchain

```dart
final signedTx = await kuchain.sign(msg, ecpairPriv);
final broadcastRes = await kuchain.broadcast(signedTx);
print(broadcastRes);
```

## Supporting Message Types (Updating...)
- If you need more message types, you can commit issues

## Documentation

This library is simple and easy to use. We don't have any formal documentation yet other than examples. Ask for help if our examples aren't enough to guide you

## Contribution

- Contributions, suggestions, improvements, and feature requests are always welcome

## Script
```
// Analyze code
flutter analyze

// Format code
dartfmt -w lib example

// Publish validation
pub publish --dry-run --verbose

// Publish
flutter packages pub publish --verbose --server https://pub.dartlang.org
```