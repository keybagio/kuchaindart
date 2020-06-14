import 'dart:convert';

import 'package:bip39/bip39.dart' as bip39;
import 'package:http/http.dart' as http;
import 'package:kuchaindart/kuchaindart.dart';
import 'package:kuchaindart/json_rpc.dart';
void main() async {
  print("main start");

  const chainId = "testing";
  // const url = "http://127.0.0.1:1317";
  const url = "http://121.89.211.107";
  Kuchain kuchain = Kuchain(
    url: url,
    chainId: chainId,
  );

  String testMnemonic = bip39.generateMnemonic();
  print(testMnemonic);

  const mnemonic = "vivid favorite regular curve check word bubble echo disorder cute parade neck rib evidence option glimpse couple force angry section dizzy puppy express cream";
  String address = kuchain.getAddress(mnemonic);
  print("address ======================");
  print(address);

  final ecpairPriv = kuchain.getECPairPriv(mnemonic);
  print("ecpairPriv ======================");
  print(ecpairPriv);

  const msg = {"type":"kuchain/Tx","value":{"msg":[{"type":"account/createMsg","value":{"KuMsg":{"auth":["kuchain1fg3svnqcv9wcln0q5cwdcm0uk8a4hwqvng26sh"],"from":"validator","to":"acc1","amount":[],"router":"account","action":"create","data":"RJzo+ewKEwoRAQEJWBMJEBUPSAAAAAAAAAASEwoRAQEEBDDhAAAAAAAAAAAAAAAaFGNKvkbeXeCYw7nKG0NH7crAl8Km"}}}],"fee":{"amount":[{"denom":"stake","amount":"50"}],"gas":"200000","payer":""},"signatures":null,"memo":"Sent via Kuchain"}};
  final signedTx = await kuchain.sign(msg, ecpairPriv);
  print("signedTx ======================");
  print(signedTx);

  // JSON RPC Test
  JsonRPC rpc = JsonRPC(url, http.Client());

  final stdSignMsg = await rpc.getStdSignMsg(msg);
  final data = jsonDecode(stdSignMsg.body) as Map<String, dynamic>;
  print(data);
}
