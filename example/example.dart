import 'dart:convert';
import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
import 'package:kuchaindart/kuchaindart.dart';

Future main() async {
  print('main start');

  const chainId = 'testing';
  // const url = 'http://127.0.0.1:1317';
  const url = 'http://121.89.211.107';
  var kuchain = Kuchain(
    url: url,
    chainId: chainId,
  );

  // Configure your own information
  const myAddress = 'kuchain1ektcysuggtw29g5tql9mgv32fx6nkv90r98h9r';
  const myAccount = 'test1';
  const myPrivatKeyHex =
      '8c44ff31bf84292b316aee425b4ebb1b3e95fcf790fd163c8d5fa64418706f7d';

  var testMnemonic = bip39.generateMnemonic();
  print(testMnemonic);

  const mnemonic =
      // ignore: lines_longer_than_80_chars
      'vivid favorite regular curve check word bubble echo disorder cute parade neck rib evidence option glimpse couple force angry section dizzy puppy express cream';
  final address = kuchain.getAddress(mnemonic);
  print('address ======================');
  print(address);

  final addressFromPrivateKey =
      kuchain.getAddressFromPrivateKeyHex(myPrivatKeyHex);
  print('addressFromPrivateKey ======================');
  print(addressFromPrivateKey);

  final ecpairPriv = kuchain.getECPairPriv(mnemonic);
  print('ecpairPriv ======================');
  print(HEX.encode(ecpairPriv));

  final getPubKeyBase64 = kuchain.getPubKeyBase64(ecpairPriv);
  print('getPubKeyBase64 ======================');
  print(getPubKeyBase64);

  final getPubKey = kuchain.getPubKey(ecpairPriv);
  print('getPubKey ======================');
  print(getPubKey);

  // ====================================
  //          Get accounts from address
  // ====================================
  final accounts = await kuchain.getAccounts(myAddress);
  print('getAccounts ======================');
  print(accounts);

  // ====================================
  //          Get account info
  // ====================================
  final accountInfo = await kuchain.getAccount(myAccount);
  print('getAccount ======================');
  print(accountInfo);

  // ====================================
  //          Get coins info
  // ====================================
  final coinsInfo = await kuchain.getCoins(myAddress);
  print('getCoins ======================');
  print(coinsInfo);

  // ====================================
  //            Create account
  // ====================================
  // final newCreateAccMsg = await kuchain.newCreateAccMsg(
  //   myAccount,
  //   'test4',
  //   myAddress,
  // );
  // print('newCreateAccMsg ======================');
  // print(newCreateAccMsg);

  // final signedCreateAccMsgTx
  //  = await kuchain.sign(newCreateAccMsg, ecpairPriv);
  // print('signedCreateAccMsgTx ======================');
  // print(signedCreateAccMsgTx);

  // final createAccRes = await kuchain.broadcast(signedCreateAccMsgTx);
  // print('createAccRes ======================');
  // print(createAccRes);

  // ====================================
  //              Transfer
  // ====================================
  final newTransferMsg = await kuchain.newTransferMsg(
    myAccount,
    'test4',
    '10000kuchain/kcs',
  );
  print('newTransferMsg ======================');
  print(json.encode(newTransferMsg));

  final signedNewTransferMsgTx = await kuchain.sign(newTransferMsg, ecpairPriv);
  print('signedNewTransferMsgTx ======================');
  print(signedNewTransferMsgTx);
  print(json.encode(signedNewTransferMsgTx));

  final transferRes = await kuchain.broadcast(signedNewTransferMsgTx);
  print('transferRes ======================');
  print(transferRes);
}
