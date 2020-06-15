import 'dart:convert';
import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

import 'package:kuchaindart/utils/tx_signer.dart';
import 'package:kuchaindart/json_rpc.dart';
import './utils/bech32_encoder.dart';

class Kuchain {
  final String url;
  final String chainId;
  JsonRPC jsonRpc;

  // m/purpse'/coin_type'/account'/change/address_index
  String path = "m/44'/23808'/0'/0/0";
  String bech32MainPrefix = "kuchain";

  Kuchain({this.url, this.chainId}) {
    jsonRpc = JsonRPC(url, http.Client());
  }

  /// get address from a mnemonic
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

    final words = child.identifier;

    // Bech32 encode
    String address = Bech32Encoder.encode(bech32MainPrefix, words);

    return address;
  }

  /// get private key from a mnemonic
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

  /// generate public key from ecpairPriv
  ///
  /// [ecpairPriv] private key
  ///
  /// Returns string pubkey in base64
  String getPubKeyBase64(Uint8List ecpairPriv) {
    ECPrivateKey ecPrivateKey = _getECPrivateKey(ecpairPriv);
    ECPublicKey ecPublicKey = _getECPublicKey(ecPrivateKey);
    final pubKeyBase64 = base64.encode(ecPublicKey.Q.getEncoded(true));
    return pubKeyBase64;
  }

  /// sign a transaction with stdMsg and private key
  ///
  /// [stdSignMsg] standard object of a message
  ///
  /// [ecpairPriv] private key of transaction sender
  ///
  /// [modeType] broadcast type
  Future<dynamic> sign(Map<String, dynamic> stdSignMsg, Uint8List ecpairPriv,
      [String modeType = "sync"]) async {
    // Get standard sign message
    final rsp = await getStdSignMsg(stdSignMsg);
    var signMsg = jsonDecode(rsp.body);

    // Decode message as base64
    final msgData = base64Decode(signMsg['msg'] as String);

    // Convert message to a SHA-256 hash
    final hash = SHA256Digest().process(msgData);

    // Sign transaction
    ECPrivateKey ecPrivateKey = _getECPrivateKey(ecpairPriv);
    ECPublicKey ecPublicKey = _getECPublicKey(ecPrivateKey);

    final signObj =
        TransactionSigner.deriveFrom(hash, ecPrivateKey, ecPublicKey);

    final signatureBase64 = base64Encode(signObj);

    return {
      "tx": {
        "msg": stdSignMsg['msg'],
        "fee": stdSignMsg['fee'],
        "signatures": [
          {
            "signature": signatureBase64,
            "pub_key": {
              "type": "tendermint/PubKeySecp256k1",
              "value": getPubKeyBase64(ecpairPriv)
            }
          }
        ],
        "memo": stdSignMsg['memo']
      },
      "mode": modeType
    };
  }

  /// Returns the associated [privateKey] as an [ECPrivateKey] instance.
  ECPrivateKey _getECPrivateKey(Uint8List privateKey) {
    final privateKeyInt = BigInt.parse(HEX.encode(privateKey), radix: 16);
    return ECPrivateKey(privateKeyInt, ECCurve_secp256k1());
  }

  /// Returns the associated [publicKey] as an [ECPublicKey] instance.
  ECPublicKey _getECPublicKey(ECPrivateKey _ecPrivateKey) {
    final secp256k1 = ECCurve_secp256k1();
    final point = secp256k1.G;
    final curvePoint = point * _ecPrivateKey.d;
    return ECPublicKey(curvePoint, ECCurve_secp256k1());
  }

  // ================== JSON RPC =====================
  Future<Response> getStdSignMsg(Map<String, dynamic> msg) =>
      jsonRpc.getStdSignMsg(msg);
}
