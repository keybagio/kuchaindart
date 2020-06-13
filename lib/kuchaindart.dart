import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
import './utils/bech32_encoder.dart';

class Kuchain {

  final String url;
  final String chainId;

  // m/purpse'/coin_type'/account'/change/address_index
  String path = "m/44'/23808'/0'/0/0";
  String bech32MainPrefix = "kuchain";

  Kuchain({
    this.url,
    this.chainId
  });

  /// get address from a mnemonic
  /// 
  /// [mnemonic] -  BIP39 mnemonic seed
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
}