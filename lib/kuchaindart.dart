import 'dart:convert';
import 'dart:typed_data';
import 'package:base_x/base_x.dart';
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

  Kuchain({
    this.url,
    this.chainId
  }) {
    jsonRpc = JsonRPC(url, http.Client());
  }

  /// get address from a mnemonic
  /// 
  /// [mnemonic] -  BIP39 mnemonic seed
  /// 
  /// Returns the address derived from the provided mnemonic
  String getAddress(String mnemonic) {
    print("getAddress start");

    // Convert the mnemonic to a seed
    final seed = bip39.mnemonicToSeed(mnemonic);
    print("seed = $seed");

    // Convert the seed to a BIP32 instance
    final node = bip32.BIP32.fromSeed(seed);
    print("node = $node");

    // Get the child from the derivation path
    final child = node.derivePath(path);
    print("child = $child");
    print("privateKey = ${HEX.encode(child.privateKey)}");
    print("publicKey = ${HEX.encode(child.publicKey)}");

    final words = child.identifier;
    print("words = $words");

    // Bech32 encode
    String address = Bech32Encoder.encode(bech32MainPrefix, words);
    print("address = $address");

    return address;
  }

  /// get private key from a mnemonic
  /// 
  /// [mnemonic] -  BIP39 mnemonic seed
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

  Future<dynamic> sign(Map<String, dynamic> stdSignMsg, Uint8List ecpairPriv) async {
    final rsp = await getStdSignMsg(stdSignMsg);
    var signMsg2 = jsonDecode(rsp.body);
    print("signMsg2 ===========");
    print(signMsg2);

    var signMsg = {"msg":"eyJhY2NvdW50X251bWJlciI6IjEiLCJjaGFpbl9pZCI6InRlc3RpbmciLCJmZWUiOnsiYW1vdW50IjpbeyJhbW91bnQiOiIxMDAiLCJkZW5vbSI6Imt1Y2hhaW4va2NzIn1dLCJnYXMiOiIyMDAwMDAiLCJwYXllciI6ImFjYzEifSwibWVtbyI6InNlbmQgdmlhIGt1Y2hhaW4iLCJtc2ciOlt7ImFjdGlvbiI6ImNyZWF0ZSIsImFtb3VudCI6W10sImF1dGgiOlsia3VjaGFpbjFmaHFqaHMyMnM0Y3d2anhydmxjeXN0M2g0cHZ3N3g0OWp2azB1eCJdLCJkYXRhIjoiUkp6bytld0tFd29SQVFFRUJERGhBQUFBQUFBQUFBQUFBQUFTRXdvUkFRRUVCRERpQUFBQUFBQUFBQUFBQUFBYUZFM0JLOEZLaFhEbVNNTm44RWd1TjZoWTd4cWwiLCJmcm9tIjoiYWNjMSIsInJvdXRlciI6ImFjY291bnQiLCJ0byI6ImFjYzIifV0sInNlcXVlbmNlIjoiMSJ9"};

    // Decode message as base64
    final base64 = BaseXCodec('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/');
    final msgData = base64.decode(signMsg['msg']);
    print("msgData ========= ");
    print(msgData);
    print(msgData);
    
    // Convert message to a SHA-256 hash
    final hash = SHA256Digest().process(msgData);
    print("hash ========= ");
    print(HEX.encode(hash));

    ECPrivateKey ecPrivateKey = _getECPrivateKey(ecpairPriv);
    ECPublicKey ecPublicKey = _getECPublicKey(ecPrivateKey);

    final signObj2 = TransactionSigner.deriveFrom(hash, ecPrivateKey, ecPublicKey);
    print("signObj2 ========= ");
    print(signObj2);
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
  Future<Response> getStdSignMsg(Map<String, dynamic> msg) => jsonRpc.getStdSignMsg(msg);
}