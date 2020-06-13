import 'package:kuchaindart/kuchaindart.dart';
import 'package:bip39/bip39.dart' as bip39;

void main() async {
  print("main start");

  const chainId = "testing";
  const url = "http://127.0.0.1:1317";
  Kuchain kuchain = Kuchain(
    url: url,
    chainId: chainId,
  );

  String testMnemonic = bip39.generateMnemonic();
  print(testMnemonic);

  const mnemonic = "vivid favorite regular curve check word bubble echo disorder cute parade neck rib evidence option glimpse couple force angry section dizzy puppy express cream";
  String address = kuchain.getAddress(mnemonic);

  print(address);

  print(kuchain);
}
