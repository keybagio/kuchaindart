import 'dart:convert';
import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
import 'package:kuchaindart/kuchaindart.dart';

Future main() async {
  print('main start');

  // const url = 'http://127.0.0.1:1317';
  const url = 'http://121.89.216.155';

  // const chainId = 'kuchain';
  // const prefix = 'kuchain';
  // const mainCoinDenom = 'kuchain/kcs';
  
  const chainId = 'kratos';
  const prefix = 'kratos'; // Test network
  const mainCoinDenom = 'kratos/kts'; // Test network

  var kuchain = Kuchain(
    url: url,
    chainId: chainId,
  );

  kuchain.setBech32MainPrefix(prefix);
  kuchain.setMainCoinDenom(mainCoinDenom);

  var testMnemonic = bip39.generateMnemonic();
  print('\n mnemonic ======================');
  print(testMnemonic);

  const mnemonic =
      // ignore: lines_longer_than_80_chars
      'vivid favorite regular curve check word bubble echo disorder cute parade neck rib evidence option glimpse couple force angry section dizzy puppy express cream';
  final address = kuchain.getAddress(mnemonic);
  print('\n address ======================');
  print(address);

  // Configure your own information
  const myAccount = 'testaccount1';
  final myAddress = address;

  const myPrivatKeyHex =
      '8c44ff31bf84292b316aee425b4ebb1b3e95fcf790fd163c8d5fa64418706f7d';
  final addressFromPrivateKey =
      kuchain.getAddressFromPrivateKeyHex(myPrivatKeyHex);
  print('\n addressFromPrivateKey ======================');
  print(addressFromPrivateKey);

  final ecpairPriv = kuchain.getECPairPriv(mnemonic);
  print('\n ecpairPriv ======================');
  print(HEX.encode(ecpairPriv));

  final getPubKeyBase64 = kuchain.getPubKeyBase64(ecpairPriv);
  print('\n getPubKeyBase64 ======================');
  print(getPubKeyBase64);

  final getPubKey = kuchain.getPubKey(ecpairPriv);
  print('\n getPubKey ======================');
  print(getPubKey);

  // ====================================
  //          Get accounts info from address
  // ====================================
  final accounts = await kuchain.getAccounts(myAddress);
  print('\n getAccounts ======================');
  print(accounts);

  // ====================================
  //          Get account info
  // ====================================
  final accountInfo = await kuchain.getAccount(myAccount);
  print('\n getAccount ======================');
  print(accountInfo);

  // ====================================
  //          Get coins info
  // ====================================
  final coinsInfo = await kuchain.getCoins(myAddress);
  print('\n getCoins ======================');
  print(coinsInfo);

  // ====================================
  //            Create account
  // ====================================
  // final newCreateAccMsg = await kuchain.newCreateAccMsg(
  //   myAddress,
  //   myAccount,
  //   myAddress,
  // );
  // print('\n newCreateAccMsg ======================');
  // print(newCreateAccMsg);

  // final signedCreateAccMsgTx = await kuchain.sign(newCreateAccMsg, ecpairPriv);
  // print('\n signedCreateAccMsgTx ======================');
  // print(signedCreateAccMsgTx);

  // final createAccRes = await kuchain.broadcast(signedCreateAccMsgTx);
  // print('\n createAccRes ======================');
  // print(createAccRes);

  // ====================================
  //              Transfer
  // ====================================
  final newTransferMsg = await kuchain.newTransferMsg(
    myAddress,
    myAccount,
    '10000$mainCoinDenom',
  );
  print('\n newTransferMsg ======================');
  print(json.encode(newTransferMsg));

  final signedNewTransferMsgTx = await kuchain.sign(newTransferMsg, ecpairPriv);
  print('\n signedNewTransferMsgTx ======================');
  print(signedNewTransferMsgTx);
  print(json.encode(signedNewTransferMsgTx));

  final transferRes = await kuchain.broadcast(signedNewTransferMsgTx);
  print('\n transferRes ======================');
  print(transferRes);
}
