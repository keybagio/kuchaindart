import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'query_rpc.dart';

const defaultMemo = 'send via kuchain';
const defaultFee = '2000';
const defaultGas = '200000';
const defaultGasAdjustment = '1.2';
const nameStrLenMax = 17;

class JsonRPC {
  String url;
  String chainId;
  String mainCoinDenom;
  Client client;
  QueryRPC queryRPC;

  void config({
    @required String url,
    @required String chainId,
    String mainCoinDenom = 'kuchain/kcs',
    Client client,
    QueryRPC queryRPC,
  }) {
    this.url = url;
    this.chainId = chainId;
    this.mainCoinDenom = mainCoinDenom;
    this.client = client ?? Client();
    this.queryRPC = queryRPC ?? QueryRPC();

    this.queryRPC.config(
          url: this.url,
          client: this.client,
        );
  }

  /// get standard sign message
  Future<Response> getStdSignMsg(
    Map<String, dynamic> msg,
  ) async {
    const encodeApi = '/sign_msg/encode';

    return _httpPost(
      url + encodeApi,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(msg),
    );
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

    return fetchMsg(url + createAccApi, reqData);
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

    return fetchMsg(url + updateApi, reqData);
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

    return fetchMsg(url + transferApi, reqData);
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

    return fetchMsg(url + createApi, reqData);
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

    return fetchMsg(url + issueApi, reqData);
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

    return fetchMsg(url + lockApi, reqData);
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

    return fetchMsg(url + unlockApi, reqData);
  }

  /// construct BurnCoin Msg in JSON
  ///
  /// [account] account ID of burning coin
  /// [amount] amount of coin to be issued
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [gasAdjustment] max gas consumption rate of a transaction can take
  ///
  /// Returns standard message of BurnCoin
  Future<Map<String, dynamic>> newBurnCoinMsg(String account, String amount,
      [String fee = defaultFee,
      String gas = defaultGas,
      String memo = defaultMemo,
      String gasAdjustment = defaultGasAdjustment]) async {
    const burnApi = '/assets/burn';
    final reqData = {
      'base_req': _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, account),
      'account': account,
      'amount': amount,
    };

    return fetchMsg(url + burnApi, reqData);
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

    return fetchMsg(url + delegationApi, reqData);
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

    return fetchMsg(url + delegationApi, reqData);
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

    return fetchMsg(url + delegationApi, reqData);
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
      'title': title,
      'description': description,
      'initial_deposit': initialDeposit,
      'proposer_acc': proposer
    };

    return fetchMsg(url + proposalApi, reqData);
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
      'title': title,
      'description': description,
      'initial_deposit': initialDeposit,
      'proposer_acc': proposer,
      'param_changes': [
        {'subspace': subspace, 'key': key, 'value': value}
      ]
    };

    return fetchMsg(url + proposalApi, reqData);
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
    const depositsApi = '/gov/deposits';
    final reqData = {
      'base_req':
          _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, depositor),
      'proposal_id': proposalId,
      'depositor': depositor,
      'amount': amount,
    };

    return fetchMsg(url + depositsApi, reqData);
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
      'voter': voter,
      'option': option,
    };

    return fetchMsg(url + voteApi, reqData);
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

    return fetchMsg(url + rewardApi, reqData);
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
    const rewardApi = '/distribution/delegators_validator/rewards';
    final reqData = {
      'base_req':
          _sortBaseReq(chainId, fee, gas, memo, gasAdjustment, delegator),
      'delegator_acc': delegator,
      'validator_acc': validator,
    };

    return fetchMsg(url + rewardApi, reqData);
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

    return fetchMsg(url + withdrawApi, reqData);
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

    return fetchMsg(url + rewardApi, reqData);
  }

  Future queryFee(Map<String, dynamic> stdSignMsg) {
    final queryFeeApi = '/txs/fee';

    return _httpPost(url + queryFeeApi,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(stdSignMsg))
        .then((response) => json.decode(response.body));
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
    if (msg['error'] != null && (msg['error'] as String).isNotEmpty) {
      throw Exception('Get Msg From Cli Error: ${json.encode(msg)}');
    }

    final auth = await _sortAuth(sender);

    return {
      'chain_id': chainId,
      'account_number': auth['result']['number'],
      'sequence': auth['result']['sequence'],
      'msg': msg['value']['msg'],
      'fee': msg['value']['fee'],
      'memo': msg['value']['memo']
    };
  }

  /// Sort MultiMsg
  ///
  /// [sender] transaction sender
  /// [fee] fees = gas * gas-prices
  /// [gas] a special unit that is used to track the consumption of resources during execution
  /// [memo] memo
  /// [msgs] Msg which to sort
  ///
  /// Return sorted Msg
  Future<Map<String, dynamic>> sortMultiMsg(
    String sender,
    String fee,
    String gas,
    String memo,
    List msgs,
  ) async {
    final finalMsgs = [];

    for (var i = 0, len = msgs.length; i < len; i++) {
      if (msgs[i]['error'] != null && (msgs[i]['error'] as String).isNotEmpty) {
        throw Exception('Get Msg From Cli Error: ${json.encode(msgs[i])}');
      }
      finalMsgs.add(msgs[i].msg[0]);
    }

    final auth = await _sortAuth(sender);

    return {
      'chain_id': chainId,
      'account_number': auth['result']['number'],
      'sequence': auth['result']['sequence'],
      'msg': finalMsgs,
      'fee': {
        'amount': [
          {'denom': mainCoinDenom, 'amount': fee}
        ],
        'gas': gas,
        'payer': sender
      },
      'memo': memo
    };
  }

  Future<Map<String, dynamic>> _sortAuth(String sender) async {
    Map<String, dynamic> acc, auth;

    if (sender.length <= nameStrLenMax) {
      acc = await queryRPC.getAccountInfo(sender);
      if (acc['error'] != null && (acc['error'] as String).isNotEmpty) {
        throw Exception('Get Account Info Error: ${json.encode(acc)}');
      }

      sender = acc['result']['value']['auths'][0]['address'] as String;
    }

    auth = await queryRPC.getAuthInfo(sender);

    if (auth['error'] != null && (auth['error'] as String).isNotEmpty) {
      throw Exception('Get Auth Info Error:  ${json.encode(auth)}');
    }

    return auth;
  }

  Future<Map<String, dynamic>> fetchMsg(String msgPath, dynamic req) async {
    final msg = await _httpPost(msgPath,
        headers: {'Content-Type': 'application/json'}, body: json.encode(req));

    return _sortMsg(json.decode(msg.body) as Map<String, dynamic>,
        req['base_req']['payer'] as String);
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
