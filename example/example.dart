import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
import 'package:kuchaindart/kuchaindart.dart';

void main() async {
  print("main start");

  const chainId = "testing";
  // const url = "http://127.0.0.1:1317";
  const url = "http://121.89.211.107";
  Kuchain kuchain = Kuchain(
    url: url,
    chainId: chainId,
  );

  // Configure your own information
  const myAddress = "kuchain1ektcysuggtw29g5tql9mgv32fx6nkv90r98h9r";
  const myAccount = "test1";

  String testMnemonic = bip39.generateMnemonic();
  print(testMnemonic);

  const mnemonic =
      "vivid favorite regular curve check word bubble echo disorder cute parade neck rib evidence option glimpse couple force angry section dizzy puppy express cream";
  String address = kuchain.getAddress(mnemonic);
  print("address ======================");
  print(address);

  final ecpairPriv = kuchain.getECPairPriv(mnemonic);
  print("ecpairPriv ======================");
  print(HEX.encode(ecpairPriv));

  String getPubKeyBase64 = kuchain.getPubKeyBase64(ecpairPriv);
  print("getPubKeyBase64 ======================");
  print(getPubKeyBase64);

  Uint8List getPubKey = kuchain.getPubKey(ecpairPriv);
  print("getPubKey ======================");
  print(getPubKey);
 
  // ====================================
  //          Get account info
  // ====================================
  final accountInfo = await kuchain.getAccount(myAccount);
  print("getAccount ======================");
  print(accountInfo);

  // ====================================
  //            Create account
  // ====================================
  // final newCreateAccMsg = await kuchain.newCreateAccMsg(
  //   myAccount,
  //   "test4",
  //   myAddress,
  // );
  // print("newCreateAccMsg ======================");
  // print(newCreateAccMsg);

  // final signedCreateAccMsgTx = await kuchain.sign(newCreateAccMsg, ecpairPriv);
  // print("signedCreateAccMsgTx ======================");
  // print(signedCreateAccMsgTx);

  // final createAccRes = await kuchain.broadcast(signedCreateAccMsgTx);
  // print("createAccRes ======================");
  // print(createAccRes);


  // ====================================
  //              Transfer
  // ====================================
  final newTransferMsg = await kuchain.newTransferMsg(
    myAccount,
    "test4",
    "10000kuchain/kcs",
  );
  print("newTransferMsg ======================");
  print(json.encode(newTransferMsg));

  final signedNewTransferMsgTx = await kuchain.sign(newTransferMsg, ecpairPriv);
  print("signedNewTransferMsgTx ======================");
  print(signedNewTransferMsgTx);
  print(json.encode(signedNewTransferMsgTx));

  final transferRes = await kuchain.broadcast(signedNewTransferMsgTx);
  print("transferRes ======================");
  print(transferRes);
}
