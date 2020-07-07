import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

const defaultMemo = "send via kuchain";
const defaultFee = "100";
const defaultGas = "200000";
const defaultGasAdjustment = "1.2";
const defaultCoin = "kuchain/kcs";
const nameStrLenMax = 17;

class JsonRPC {
  final String url;
  final String chainId;
  final Client client;

  JsonRPC({@required this.url, @required this.chainId, @required this.client});

  Future<Response> getStdSignMsg(
    Map<String, dynamic> msg,
  ) async {
    const encodeApi = "/sign_msg/encode";

    return _httpPost(
      url + encodeApi,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(msg),
    );
  }

  /// get account info from `account`
  ///
  /// [account] account ID of kuchain
  ///
  /// Returns account infos in JSON
  Future<Map<String, dynamic>> getAccount(
    String account,
  ) async {
    const accountsApi = "/account/";

    return _httpGet(
      url + accountsApi + account,
    ).then((response) => json.decode(response.body) as Map<String, dynamic>);
  }

  /// get accounts info by `address`
  ///
  /// [address] address of kuchain
  ///
  /// Returns accounts in JSON
  Future<Map<String, dynamic>> getAccounts(
    String address,
  ) async {
    const accountsApi = "/accounts/";

    return _httpGet(
      url + accountsApi + address,
    ).then((response) => json.decode(response.body) as Map<String, dynamic>);
  }

  /// get auth info from `auth`
  ///
  /// [auth] auth(address) of an account in kuchain
  ///
  /// Returns auth infos in JSON
  Future<Map<String, dynamic>> getAuth(
    String auth,
  ) async {
    const authApi = "/account/auth/";

    return _httpGet(
      url + authApi + auth,
    ).then((response) => json.decode(response.body) as Map<String, dynamic>);
  }

  /// get txs info from `hash`
  ///
  /// [hash] Tx hash
  ///
  /// Returns txs infos in JSON
  Future<Map<String, dynamic>> getTxs(
    String hash,
  ) async {
    const txsApi = "/txs/";

    return _httpGet(
      url + txsApi + hash,
    ).then((response) => json.decode(response.body) as Map<String, dynamic>);
  }

  /// get CreateAccount Msg in JSON
  ///
  /// [creator] account ID of creator
  /// [account] account ID of whom to be created
  /// [accAuth] account auth of whom to be created
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  /// Returns standard message
  Future<Map<String, dynamic>> newCreateAccMsg(
      String creator, String account, String accAuth,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const createAccApi = "/account/create";
    final reqData = {
      "base_req": _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, creator),
      "creator": creator,
      "account": account,
      "account_auth": accAuth
    };

    final msg = await _httpPost(url + createAccApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, creator);
  }

  /// construct UpdateAuthMsg Msg in JSON
  ///
  /// [account] account ID
  /// [newAccountAuth] new account auth
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  /// Returns standard message of UpdateAuthMsg
  Future<Map<String, dynamic>> newUpdateAuthMsg(
      String account, String newAccountAuth,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const updateApi = "/account/update_auth";
    final reqData = {
      "base_req": _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, account),
      "account": account,
      "new_account_auth": newAccountAuth,
    };

    final msg = await _httpPost(url + updateApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, account);
  }

  /// construct TransferMsg Msg in JSON
  ///
  /// [from] account ID of sender
  ///
  /// [to] account ID of receiver
  ///
  /// [amount] amount to be transfer(eg. 10000kuchain/kcs)
  ///
  /// [fee] fees = gas * gas-prices
  ///
  /// [gas] a special unit that is used to track the consumption of resources during execution
  ///
  /// [memo] memo
  ///
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  /// Returns standard message of TransferMsg
  Future<Map<String, dynamic>> newTransferMsg(
      String from, String to, String amount,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const transferApi = "/assets/transfer";
    final reqData = {
      "base_req": _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, from),
      "from": from,
      "to": to,
      "amount": amount,
    };

    final msg = await _httpPost(url + transferApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, from);
  }

  /// construct CreateCoin Msg in JSON
  ///
  /// [creator] account ID of creator
  /// [symbol] symbol of coin to be created(eg. btc, eos)
  /// [maxSupply] max supply of coin to be created
  /// [canIssue] if can be issued
  /// [canLock] if can be locked
  /// [issueToHeight] issue_to_height
  /// [initSupply] init_supply
  /// [desc] desc of coin
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of CreateCoin
  Future<Map<String, dynamic>> newCreateCoinMsg(
      String creator,
      String symbol,
      String maxSupply,
      bool canIssue,
      bool canLock,
      String issueToHeight,
      String initSupply,
      String desc,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const createApi = "/assets/create";
    final reqData = {
      "base_req": _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, creator),
      "creator": creator,
      "symbol": symbol,
      "max_supply": maxSupply,
      "can_issue": canIssue,
      "can_lock": canLock,
      "issue_to_height": issueToHeight,
      "init_supply": initSupply,
      "desc": desc,
    };

    final msg = await _httpPost(url + createApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, creator);
  }

  /// post a signed transaction to blockchain
  ///
  /// [signedTx] signed transaction
  ///
  /// Returns succeed or not
  Future broadcast(Map<String, dynamic> signedTx) {
    const broadcastApi = "/txs";

    return _httpPost(url + broadcastApi,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(signedTx))
        .then((response) => json.decode(response.body));
  }

  // 请求参数排序
  dynamic _sortBaseReq(String chainId, String fee, String gas, String memo,
      String gasAdjustment, String payer) {
    return {
      "chain_id": chainId,
      "memo": memo,
      "gas": gas,
      "gas_adjustment": gasAdjustment,
      "payer": payer,
      "fees": [
        {"denom": defaultCoin, "amount": fee}
      ],
    };
  }

  /// Sort Msg
  ///
  /// `Account Sender`
  /// 1. Get account info to find `address`
  /// 2. Get auth info to find `account number` and `sequence`
  /// `Address Sender`
  /// 1. Get auth info to find `account number` and `sequence`
  ///
  /// [msg] Msg which to sort
  /// [sender] transaction sender
  ///
  /// Return sorted Msg
  Future<Map<String, dynamic>> _sortMsg(
      Map<String, dynamic> msg, String sender) async {
    Map<String, dynamic> acc, auth;

    if (sender.length <= nameStrLenMax) {
      acc = await getAccount(sender);
      auth = await getAuth(
          acc["result"]["value"]["auths"][0]["address"] as String);
    } else {
      auth = await getAuth(sender);
    }

    return {
      "chain_id": chainId,
      "account_number": auth["result"]["number"],
      "sequence": auth["result"]["sequence"],
      "msg": msg["value"]["msg"],
      "fee": msg["value"]["fee"],
      "memo": msg["value"]["memo"]
    };
  }

  Future<Response> _httpGet(url, {Map<String, String> headers}) async {
    // print("_httpGet url ================");
    // print(url);

    final response = await client.get(url, headers: headers);

    // print("_httpGet response================");
    // print(response.body);
    return response;
  }

  Future<Response> _httpPost(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    // print("_httpPost url ================");
    // print(url);
    // print("_httpPost body ================");
    // print(body);

    final response = await client.post(url,
        headers: headers, body: body, encoding: encoding);

    // print("_httpPost response================");
    // print(response.body);
    return response;
  }
}
