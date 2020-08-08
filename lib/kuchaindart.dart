import 'dart:convert';
import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
import 'package:meta/meta.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:http/http.dart';
import 'json_rpc.dart';
import 'utils/bech32_encoder.dart';
import 'utils/tx_signer.dart';

class Kuchain with JsonRPC {
  final String url;
  final String chainId;
  final Client client = Client();

  // m/purpse'/coin_type'/account'/change/address_index
  String path = "m/44'/23808'/0'/0/0";
  String bech32MainPrefix = 'kuchain';
  String mainCoinDenom = 'kuchain/kcs';
  
  Kuchain({
    @required this.url,
    @required this.chainId,
  });

  /// Get address from a mnemonic
  ///
  /// [mnemonic] BIP39 mnemonic seed
  ///
  /// Returns the address derived from the provided mnemonic
  String getAddress(String mnemonic) {
    // Convert the mnemonic to a seed
    final seed = bip39.mnemonicToSeed(mnemonic);

    // Convert the seed to a BIP32 instance
    final node = bip32.BIP32.fromSeed(seed);

    // Get the child from the derivation path
    final child = node.derivePath(path);

    // Get a Hash160 from the public key
    final words = child.identifier;

    // Bech32 encode
    final address = Bech32Encoder.encode(bech32MainPrefix, words);

    return address;
  }

  /// Get address from private key which in hex format
  ///
  /// [privateKeyHex] private key in hex format
  ///
  /// Returns the address derived from the private key
  String getAddressFromPrivateKeyHex(String privateKeyHex) {
    // Get the curve data
    final secp256k1 = ECCurve_secp256k1();
    final point = secp256k1.G;

    // Compute the curve point associated to the private key
    final bigInt = BigInt.parse(privateKeyHex, radix: 16);
    final curvePoint = point * bigInt;

    // Get the public key
    final publicKeyBytes = curvePoint.getEncoded();

    // Get the address
    final sha256Digest = SHA256Digest().process(publicKeyBytes);
    final address = RIPEMD160Digest().process(sha256Digest);

    return Bech32Encoder.encode(bech32MainPrefix, address);
  }

  /// Get private key from a mnemonic
  ///
  /// [mnemonic] BIP39 mnemonic seed
  ///
  /// Returns the private key derived from the provided mnemonic
  Uint8List getECPairPriv(String mnemonic) {
    // Convert the mnemonic to a seed
    final seed = bip39.mnemonicToSeed(mnemonic);

    // Convert the seed to a BIP32 instance
    final node = bip32.BIP32.fromSeed(seed);

    // Get the child from the derivation path
    final child = node.derivePath(path);

    return child.privateKey;
  }

  /// generate public key from ecpairPriv in base64
  ///
  /// [ecpairPriv] private key
  ///
  /// Returns string pubkey in base64
  String getPubKeyBase64(Uint8List ecpairPriv) {
    final ecPrivateKey = _getECPrivateKey(ecpairPriv);
    final ecPublicKey = _getECPublicKey(ecPrivateKey);
    final pubKeyBase64 = base64.encode(ecPublicKey.Q.getEncoded(true));
    return pubKeyBase64;
  }

  /// Generate public key from ecpairPriv
  ///
  /// [ecpairPriv] private key
  ///
  /// Returns Uint8List pubkey
  Uint8List getPubKey(Uint8List ecpairPriv) {
    final ecPrivateKey = _getECPrivateKey(ecpairPriv);
    final ecPublicKey = _getECPublicKey(ecPrivateKey);
    return ecPublicKey.Q.getEncoded(true);
  }

  /// Set bech32 main prefix
  /// [bech32MainPrefix] bech32 main prefix
  void setBech32MainPrefix(String bech32MainPrefix) {
    this.bech32MainPrefix = bech32MainPrefix;

    if (this.bech32MainPrefix == null || this.bech32MainPrefix.isEmpty) {
      throw Exception('bech32MainPrefix object was not set or invalid');
    }
  }

  /// Set path
  /// [path] path - m/purpse'/coin_type'/account'/change/address_index
  void setPath(String path) {
    this.path = path;

    if (this.path == null || this.path.isEmpty) {
      throw Exception('path object was not set or invalid');
    }
  }

  /// Set mainCoinDenom
  /// [mainCoinDenom] mainCoinDenom - main coin denom
  void setMainCoinDenom(String mainCoinDenom) {
    this.mainCoinDenom = mainCoinDenom;

    if (this.mainCoinDenom == null || this.mainCoinDenom.isEmpty) {
      throw Exception('mainCoinDenom object was not set or invalid');
    }
  }

  /// sign a transaction with stdMsg and private key
  ///
  /// [stdSignMsg] standard object of a message
  ///
  /// [ecpairPriv] private key of transaction sender
  ///
  /// [modeType] broadcast type
  Future<Map<String, dynamic>> sign(
      Map<String, dynamic> stdSignMsg, Uint8List ecpairPriv,
      [String modeType = 'sync']) async {
    // Get standard sign message
    final rsp = await getStdSignMsg(stdSignMsg);
    var signMsg = json.decode(rsp.body);

    if (signMsg["error"] != null && signMsg["error"].isNotEmpty) {
      throw Exception("Get SignMsg From Cli Error: " + json.encode(signMsg));
    }

    // Decode message as base64
    final msgData = base64Decode(signMsg['msg'] as String);

    // Convert message to a SHA-256 hash
    final hash = SHA256Digest().process(msgData);

    // Sign transaction
    final ecPrivateKey = _getECPrivateKey(ecpairPriv);
    final ecPublicKey = _getECPublicKey(ecPrivateKey);

    final signObj =
        TransactionSigner.deriveFrom(hash, ecPrivateKey, ecPublicKey);

    final signatureBase64 = base64Encode(signObj);

    return {
      'tx': {
        'msg': stdSignMsg['msg'],
        'fee': stdSignMsg['fee'],
        'signatures': [
          {
            'signature': signatureBase64,
            'pub_key': {
              'type': 'tendermint/PubKeySecp256k1',
              'value': getPubKeyBase64(ecpairPriv)
            }
          }
        ],
        'memo': stdSignMsg['memo']
      },
      'mode': modeType
    };
  }

  /// Returns the associated private key as an [ECPrivateKey] instance.
  ECPrivateKey _getECPrivateKey(Uint8List privateKey) {
    final privateKeyInt = BigInt.parse(HEX.encode(privateKey), radix: 16);
    return ECPrivateKey(privateKeyInt, ECCurve_secp256k1());
  }

  /// Returns the associated public key from the [ecPrivateKey].
  ECPublicKey _getECPublicKey(ECPrivateKey ecPrivateKey) {
    final secp256k1 = ECCurve_secp256k1();
    final point = secp256k1.G;
    final curvePoint = point * ecPrivateKey.d;
    return ECPublicKey(curvePoint, ECCurve_secp256k1());
  }
}
