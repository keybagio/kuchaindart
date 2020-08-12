import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

const defaultMemo = 'send via kuchain';
const defaultFee = '100';
const defaultGas = '200000';
const defaultGasAdjustment = '1.2';
const nameStrLenMax = 17;

class JsonRPC {
  String url;
  String chainId;
  String mainCoinDenom;
  Client client;

  void config({
    @required String url, 
    @required String chainId, 
    String mainCoinDenom = 'kuchain/kcs', 
    Client client,
  }) {
    this.url = url;
    this.chainId = chainId;
    this.mainCoinDenom = mainCoinDenom;
    this.client = client != null ? client : Client();
  }

  /// get standard sign message
  Future<Response> getStdSignMsg(
    Map<String, dynamic> msg,
  ) async {
    const encodeApi = '/sign_msg/encode';

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
    const accountsApi = '/account/';

    return _httpGet(
      url + accountsApi + account,
    ).then((response) => json.decode(response.body) as Map<String, dynamic>);
  }

  /// get accounts info from `address`
  ///
  /// [address] address of kuchain
  ///
  /// Returns accounts in JSON
  Future<Map<String, dynamic>> getAccounts(
    String address,
  ) async {
    const accountsApi = '/accounts/';

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
    const authApi = '/account/auth/';

    return _httpGet(
      url + authApi + auth,
    ).then((response) => json.decode(response.body) as Map<String, dynamic>);
  }

  /// get coins info from `account` or `address`
  ///
  /// [account] account or address of kuchain
  ///
  /// Returns coins infos in JSON
  Future<Map<String, dynamic>> getCoins(
    String account,
  ) async {
    const coinsApi = '/assets/coins/';

    return _httpGet(
      url + coinsApi + account,
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
    const txsApi = '/txs/';

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
    const createAccApi = '/account/create';
    final reqData = {
      'base_req': _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, creator),
      'creator': creator,
      'account': account,
      'account_auth': accAuth
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
    const updateApi = '/account/update_auth';
    final reqData = {
      'base_req': _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, account),
      'account': account,
      'new_account_auth': newAccountAuth,
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
    const transferApi = '/assets/transfer';
    final reqData = {
      'base_req': _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, from),
      'from': from,
      'to': to,
      'amount': amount,
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
      // ignore: avoid_positional_boolean_parameters
      bool canIssue,
      bool canLock,
      String issueToHeight,
      String initSupply,
      String desc,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const createApi = '/assets/create';
    final reqData = {
      'base_req': _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, creator),
      'creator': creator,
      'symbol': symbol,
      'max_supply': maxSupply,
      'can_issue': canIssue,
      'can_lock': canLock,
      'issue_to_height': issueToHeight,
      'init_supply': initSupply,
      'desc': desc,
    };

    final msg = await _httpPost(url + createApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, creator);
  }

  /// construct IssueCoin Msg in JSON
  ///
  /// [creator] account ID of creator
  /// [symbol] symbol of coin to be created(eg. btc, eos)
  /// [amount] amount of coin to be issued
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of CreateCoin
  Future<Map<String, dynamic>> newIssueCoinMsg(
      String creator, String symbol, String amount,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const issueApi = '/assets/issue';
    final reqData = {
      'base_req': _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, creator),
      'creator': creator,
      'symbol': symbol,
      'amount': amount,
    };

    final msg = await _httpPost(url + issueApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, creator);
  }

  /// construct LockCoin Msg in JSON
  ///
  /// [account] account ID of locking coin
  /// [unlockBlockHeight] height that coin can be unlocked
  /// [amount] amount of coin to be issued
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of LockCoin
  Future<Map<String, dynamic>> newLockCoinMsg(
      String account, String unlockBlockHeight, String amount,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const lockApi = '/assets/lock';
    final reqData = {
      'base_req': _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, account),
      'account': account,
      'unlock_block_height': unlockBlockHeight,
      'amount': amount,
    };

    final msg = await _httpPost(url + lockApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, account);
  }

  /// construct UnlockCoin Msg in JSON
  ///
  /// [account] account ID of locking coin
  /// [amount] amount of coin to be issued
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of UnlockCoin
  Future<Map<String, dynamic>> newUnlockCoinMsg(String account, String amount,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const unlockApi = '/assets/lock';
    final reqData = {
      'base_req': _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, account),
      'account': account,
      'amount': amount,
    };

    final msg = await _httpPost(url + unlockApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, account);
  }

  /// construct Delegation Msg in JSON
  ///
  /// [delegator] account ID of delegator
  /// [validator] account ID of validator
  /// [amount] amount of coin to be issued
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of Delegation
  Future<Map<String, dynamic>> newDelegationMsg(
      String delegator, String validator, String amount,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const delegationApi = '/staking/delegations';
    final reqData = {
      'base_req':
          _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, delegator),
      'delegator_acc': delegator,
      'validator_acc': validator,
      'amount': amount,
    };

    final msg = await _httpPost(url + delegationApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, delegator);
  }

  /// construct Unbonding Msg in JSON
  ///
  /// [delegator] account ID of delegator
  /// [validator] account ID of validator
  /// [amount] amount of coin to be issued
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of Unbonding
  Future<Map<String, dynamic>> newUnbondingMsg(
      String delegator, String validator, String amount,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const delegationApi = '/staking/unbonding_delegations';
    final reqData = {
      'base_req':
          _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, delegator),
      'delegator_acc': delegator,
      'validator_acc': validator,
      'amount': amount,
    };

    final msg = await _httpPost(url + delegationApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, delegator);
  }

  /// construct Redelegation Msg in JSON
  ///
  /// [delegator] account ID of delegator
  /// [validatorSrc] account ID of validator redelegated from
  /// [validatorDst] account ID of validator redelegated to
  /// [amount] amount of coin to be issued
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of Redelegation
  Future<Map<String, dynamic>> newRedelegationMsg(
      String delegator, String validatorSrc, String validatorDst, String amount,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const delegationApi = '/staking/redelegations';
    final reqData = {
      'base_req':
          _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, delegator),
      'delegator_acc': delegator,
      'validator_src_acc': validatorSrc,
      'validator_dst_acc': validatorDst,
      'amount': amount
    };

    final msg = await _httpPost(url + delegationApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, delegator);
  }

  /// construct Proposal Msg in JSON
  ///
  /// [title] title of proposal to be propose
  /// [description] description of proposal to be propose
  /// [initialDeposit] accoinitial deposit of this proposal
  /// [proposer] proposer of this proposal
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of Proposal
  Future<Map<String, dynamic>> newProposalMsg(
      String title, String description, String initialDeposit, String proposer,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const proposalApi = '/gov/proposals';
    final reqData = {
      'base_req':
          _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, proposer),
      title: title,
      description: description,
      'initial_deposit': initialDeposit,
      'proposer_acc': proposer
    };

    final msg = await _httpPost(url + proposalApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, proposer);
  }

  /// construct ProposalParamChange Msg in JSON
  ///
  /// [title] title of proposal to be propose
  /// [description] description of proposal to be propose
  /// [initialDeposit] accoinitial deposit of this proposal
  /// [proposer] proposer of this proposal
  /// [subspace] subspace
  /// [key] key
  /// [value] value
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of ProposalParamChange
  Future<Map<String, dynamic>> newProposalParamMsg(
      String title,
      String description,
      String initialDeposit,
      String proposer,
      String subspace,
      String key,
      String value,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const proposalApi = '/gov/proposals/param_change';
    final reqData = {
      'base_req':
          _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, proposer),
      title: title,
      description: description,
      'initial_deposit': initialDeposit,
      'proposer_acc': proposer,
      'param_changes': [
        {subspace: subspace, key: key, value: value}
      ]
    };

    final msg = await _httpPost(url + proposalApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, proposer);
  }

  /// construct Deposit Msg in JSON
  ///
  /// [proposalId] proposal ID
  /// [depositor] depositor of proposal to be propose
  /// [amount] amount of coin to be deposit
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of Deposit
  Future<Map<String, dynamic>> newDepositMsg(
      String proposalId, String depositor, String amount,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const proposalApi = '/gov/deposits';
    final reqData = {
      'base_req':
          _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, depositor),
      'proposal_id': proposalId,
      depositor: depositor,
      amount: amount,
    };

    final msg = await _httpPost(url + proposalApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, depositor);
  }

  /// construct Vote Msg in JSON
  ///
  /// [proposalId] proposal ID
  /// [voter] vote of this proposal
  /// [option] vote option (eg. yes|abstain|no|no_with_veto)
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of Vote
  Future<Map<String, dynamic>> newVoteMsg(
      String proposalId, String voter, String option,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const voteApi = '/gov/votes';
    final reqData = {
      'base_req': _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, voter),
      'proposal_id': proposalId,
      voter: voter,
      option: option,
    };

    final msg = await _httpPost(url + voteApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, voter);
  }

  /// construct DelegatorReward Msg in JSON
  ///
  /// [delegator] proposal ID
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of DelegatorReward
  Future<Map<String, dynamic>> newDelegatorReward(String delegator,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const rewardApi = '/distribution/delegators/rewards';
    final reqData = {
      'base_req':
          _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, delegator),
      'delegator_acc': delegator,
    };

    final msg = await _httpPost(url + rewardApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, delegator);
  }

  /// construct DelegatorValidatorReward Msg in JSON
  ///
  /// [delegator] account ID of delegator
  /// [validator] account ID of validator
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of DelegatorValidatorReward
  Future<Map<String, dynamic>> newDelegatorValidatorReward(
      String delegator, String validator,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const rewardApi = '/distribution/delegators/rewards';
    final reqData = {
      'base_req':
          _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, delegator),
      'delegator_acc': delegator,
      'validator_acc': validator,
    };

    final msg = await _httpPost(url + rewardApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, delegator);
  }

  /// construct SetWithdrawAddr Msg in JSON
  ///
  /// [delegator] account ID of delegator
  /// [withdrawAddr] new withdraw account of delegator
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of SetWithdrawAddr
  Future<Map<String, dynamic>> newSetWithdrawAddr(
      String delegator, String withdrawAddr,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const withdrawApi = '/distribution/delegators/withdraw_account';
    final reqData = {
      'base_req':
          _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, delegator),
      'delegator_acc': delegator,
      'withdraw_acc': withdrawAddr,
    };

    final msg = await _httpPost(url + withdrawApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, delegator);
  }

  /// construct ValidatorReward Msg in JSON
  ///
  /// [validator] account ID of validator
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of ValidatorReward
  Future<Map<String, dynamic>> newValidatorReward(String validator,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const rewardApi = '/distribution/validators/rewards';
    final reqData = {
      'base_req':
          _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, validator),
      'validator_acc': validator,
    };

    final msg = await _httpPost(url + rewardApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reqData));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>, validator);
  }

  /// post a signed transaction to blockchain
  ///
  /// [signedTx] signed transaction
  ///
  /// Returns succeed or not
  Future broadcast(Map<String, dynamic> signedTx) {
    const broadcastApi = '/txs';

    return _httpPost(url + broadcastApi,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(signedTx))
        .then((response) => json.decode(response.body));
  }

  // 请求参数排序
  dynamic _sortBaseReq(String chainId, String fee, String gas, String memo,
      String gasAdjustment, String payer) {
    return {
      'chain_id': chainId,
      'memo': memo,
      'gas': gas,
      'gas_adjustment': gasAdjustment,
      'payer': payer,
      'fees': [
        {'denom': mainCoinDenom, 'amount': fee}
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
    if (msg['error'] != null && msg['error'].isNotEmpty) {
      throw Exception('Get Msg From Cli Error: ' + json.encode(msg));
    }

    Map<String, dynamic> acc, auth;

    if (sender.length <= nameStrLenMax) {
      acc = await getAccount(sender);
      if (acc['error'] != null && acc['error'].isNotEmpty) {
        throw Exception('Get Account Info Error: ' + json.encode(acc));
      }

      sender = acc['result']['value']['auths'][0]['address'] as String;
    }

    auth = await getAuth(sender);

    if (auth['error'] != null && auth['error'].isNotEmpty) {
      throw Exception('Get Auth Info Error: ' + json.encode(auth));
    }

    return {
      'chain_id': chainId,
      'account_number': auth['result']['number'],
      'sequence': auth['result']['sequence'],
      'msg': msg['value']['msg'],
      'fee': msg['value']['fee'],
      'memo': msg['value']['memo']
    };
  }

  Future<Response> _httpGet(url, {Map<String, String> headers}) async {
    print('_httpGet url ================');
    print(url);

    final response = await client.get(url, headers: headers);

    print('_httpGet response================');
    print(response.body);
    return response;
  }

  Future<Response> _httpPost(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    // print('_httpPost url ================');
    // print(url);
    // print('_httpPost body ================');
    // print(body);

    final response = await client.post(url,
        headers: headers, body: body, encoding: encoding);

    // print('_httpPost response================');
    // print(response.body);
    return response;
  }
}
