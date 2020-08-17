import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:http/http.dart';

class QueryRPC {
  String url;
  Client client;

  void config({
    @required String url,
    Client client,
  }) {
    this.url = url;
    this.client = client ?? Client();
  }

  /// Get node info
  Future<Map<String, dynamic>> getNodeInfo() {
    return _httpGetAndDecode('/node_info');
  }

  /// Get block info
  ///
  /// [height] block height
  Future<Map<String, dynamic>> getBlocks([String height = 'latest']) {
    return _httpGetAndDecode('/blocks/$height');
  }

  /// Get account info from `account`
  ///
  /// [account] account ID of kuchain
  Future<Map<String, dynamic>> getAccountInfo(
    String account,
  ) {
    return _httpGetAndDecode('/account/$account');
  }

  /// Get auth info from `auth`
  ///
  /// [auth] auth(address) of an account in kuchain
  Future<Map<String, dynamic>> getAuthInfo(
    String auth,
  ) {
    return _httpGetAndDecode('/account/auth/$auth');
  }

  /// Get accounts info by `auth`
  ///
  /// [auth] auth of kuchain
  Future<Map<String, dynamic>> getAccountsByAuth(
    String auth,
  ) {
    return _httpGetAndDecode('/accounts/$auth');
  }

  /// Get txs info by `hash`
  ///
  /// [hash] Tx hash
  Future<Map<String, dynamic>> getTxsByHash(
    String hash,
  ) {
    return _httpGetAndDecode('/txs/$hash');
  }

  /// Get txs info with filter
  ///
  /// [messageAction] message action type
  ///
  /// [messageSender] message sender
  ///
  /// [page] page index, start from 1
  ///
  /// [limit] limit number per page
  Future<Map<String, dynamic>> getTxs({
    String messageAction,
    String messageSender,
    String page = '1',
    String limit = '10',
  }) {
    return _httpGetAndDecode(
        '/txs?message.action=$messageAction&message.sender=$messageSender&page=$page&limit=$limit');
  }

  /// Get coins info from `account` or `address`
  ///
  /// [account] account or address of kuchain
  Future<Map<String, dynamic>> getCoins(String account) {
    return _httpGetAndDecode('/assets/coins/$account');
  }

  /// Get coin power info from `account`
  ///
  /// [account] account of kuchain
  Future<Map<String, dynamic>> getCoinPowers(String account) {
    return _httpGetAndDecode('/assets/coin_powers/$account');
  }

  /// Get supply total info
  ///
  /// [denomination] denomination of coin，default for main coin denom
  Future<Map<String, dynamic>> getSupplyTotal([String denomination = '']) {
    if (denomination.isEmpty) {
      return _httpGetAndDecode('/supply/total');
    }
    return _httpGetAndDecode('/supply/total/$denomination');
  }

  /// Get minting parameters
  Future<Map<String, dynamic>> getMintingParameters() {
    return _httpGetAndDecode('/minting/parameters');
  }

  /// Get coins locked info from `account`
  ///
  /// [account] account of kuchain
  Future<Map<String, dynamic>> getCoinsLocked(String account) {
    return _httpGetAndDecode('/assets/coins_locked/$account');
  }

  /// Get coins stat info
  ///
  /// [creator] account ID of creator
  ///
  /// [symbol] symbol of coin(eg. btc, eos)
  Future<Map<String, dynamic>> getCoinsStat(String creator, String symbol) {
    return _httpGetAndDecode('/assets/coin_stat/$creator/$symbol');
  }

  /// Get delegations info
  ///
  /// [delegator] account ID of delegator
  ///
  /// [validator] account ID of validator, if not supply `validator` will get all delegations info
  Future<Map<String, dynamic>> getDelegations(String delegator,
      [String validator = '']) {
    if (validator.isEmpty) {
      return _httpGetAndDecode('/staking/delegators/$delegator/delegations');
    }
    return _httpGetAndDecode(
        '/staking/delegators/$delegator/delegations/$validator');
  }

  /// Get unbonding delegations info
  ///
  /// [delegator] account ID of delegator
  ///
  /// [validator] account ID of validator, if not supply `validator` will get all unbonding delegations info
  Future<Map<String, dynamic>> getUnbondingDelegations(String delegator,
      [String validator = '']) {
    if (validator.isEmpty) {
      return _httpGetAndDecode(
          '/staking/delegators/$delegator/unbonding_delegations');
    }
    return _httpGetAndDecode(
        '/staking/delegators/$delegator/unbonding_delegations/$validator');
  }

  /// Get redelegations info
  ///
  /// [delegator] account ID of delegator
  ///
  /// [validatorFrom] the validator which redelegations from
  ///
  /// [validatorTo] the validator which redelegations to
  Future<Map<String, dynamic>> getRedelegations({
    String delegator,
    String validatorFrom,
    String validatorTo,
  }) {
    return _httpGetAndDecode(
        '/staking/redelegations?delegator=$delegator&validator_from=$validatorFrom&validator_to=$validatorTo');
  }

  /// Get validators info by delegator
  ///
  /// [delegator] account ID of delegator
  ///
  /// [validator] account ID of validator, if not supply `validator` will get all validators info
  Future<Map<String, dynamic>> getValidatorsByDelegator(String delegator,
      [String validator = '']) {
    if (validator.isEmpty) {
      return _httpGetAndDecode('/staking/delegators/$delegator/validators');
    }
    return _httpGetAndDecode(
        '/staking/delegators/$delegator/validators/$validator');
  }

  /// Get all validators info
  Future<Map<String, dynamic>> getAllValidators() {
    return _httpGetAndDecode('/staking/validators');
  }

  /// Get validator info
  ///
  /// [validator] account ID of validator
  Future<Map<String, dynamic>> getValidatorInfo(String validator) {
    return _httpGetAndDecode('/staking/validators/$validator');
  }

  /// Get validator's delegations info
  ///
  /// [validator] account ID of validator
  Future<Map<String, dynamic>> getValidatorDelegations(String validator) {
    return _httpGetAndDecode('/staking/validators/$validator/delegations');
  }

  /// Get validator's unbonding delegations info
  ///
  /// [validator] account ID of validator
  Future<Map<String, dynamic>> getValidatorUnbondingDelegations(
      String validator) {
    return _httpGetAndDecode(
        '/staking/validators/$validator/unbonding_delegations');
  }

  /// Get staking pool info
  Future<Map<String, dynamic>> getStakingPoolInfo() {
    return _httpGetAndDecode('/staking/pool');
  }

  /// Get staking parameters
  Future<Map<String, dynamic>> getStakingParameters() {
    return _httpGetAndDecode('/staking/parameters');
  }

  /// Get proposals
  ///
  /// [voter] voter of this proposal
  ///
  /// [depositor] depositor of proposal to be propose
  ///
  /// [status] status of proposal (eg. deposit_period, voting_period, passed, rejected)
  Future<Map<String, dynamic>> getProposals({
    String voter = '',
    String depositor = '',
    String status = '',
  }) {
    return _httpGetAndDecode(
        '/gov/proposals?voter=$voter&depositor=$depositor&status=$status');
  }

  /// Get proposals info by proposal id
  ///
  /// [proposalId] proposal id
  Future<Map<String, dynamic>> getProposalInfo(String proposalId) {
    return _httpGetAndDecode('/gov/proposals/$proposalId');
  }

  /// Get proposal’s proposer by proposal id
  ///
  /// [proposalId] proposal id
  Future<Map<String, dynamic>> getProposalProposer(String proposalId) {
    return _httpGetAndDecode('/gov/proposals/$proposalId/proposer');
  }

  /// Get proposal's tally by proposal id
  ///
  /// [proposalId] proposal id
  Future<Map<String, dynamic>> getProposalTally(String proposalId) {
    return _httpGetAndDecode('/gov/proposals/$proposalId/tally');
  }

  /// Get proposal's deposits by proposal id
  ///
  /// [proposalId] proposal id
  ///
  /// [depositor] depositor of proposal to be propose
  Future<Map<String, dynamic>> getProposalDeposits(String proposalId,
      [String depositor = '']) {
    if (depositor.isEmpty) {
      return _httpGetAndDecode('/gov/proposals/$proposalId/deposits');
    }
    return _httpGetAndDecode('/gov/proposals/$proposalId/deposits/$depositor');
  }

  /// Get proposal's votes by proposal id
  ///
  /// [proposalId] proposal id
  ///
  /// [voter] voter of this proposal
  Future<Map<String, dynamic>> getProposalVotes(String proposalId,
      [String voter = '']) {
    if (voter.isEmpty) {
      return _httpGetAndDecode('/gov/proposals/$proposalId/votes');
    }
    return _httpGetAndDecode('/gov/proposals/$proposalId/votes/$voter');
  }

  /// Get deposit parameters
  Future<Map<String, dynamic>> getDepositParameters() {
    return _httpGetAndDecode('/gov/parameters/deposit');
  }

  /// Get voting parameters
  Future<Map<String, dynamic>> getVotingParameters() {
    return _httpGetAndDecode('/gov/parameters/voting');
  }

  /// Get delegation rewards info
  ///
  /// [delegator] account ID of delegator
  ///
  /// [validator] account ID of validator, if not supply `validator` will get all rewards info
  Future<Map<String, dynamic>> getDelegationRewards(String delegator,
      [String validator = '']) {
    if (validator.isEmpty) {
      return _httpGetAndDecode('/distribution/delegators/$delegator/rewards');
    }
    return _httpGetAndDecode(
        '/distribution/delegators/$delegator/rewards/$validator');
  }

  /// Get withdraw account of distribution
  ///
  /// [delegator] account ID of delegator
  Future<Map<String, dynamic>> getDistributionWithdrawAccount(
      String delegator) {
    return _httpGetAndDecode(
        '/distribution/delegators/$delegator/withdraw_account');
  }

  /// Get distribution info of validator
  ///
  /// [validator] account ID of validator
  Future<Map<String, dynamic>> getValidatorDistribution(String validator) {
    return _httpGetAndDecode('/distribution/validators/$validator');
  }

  /// Get outstanding rewards info of validator
  ///
  /// [validator] account ID of validator
  Future<Map<String, dynamic>> getValidatorOutstandingRewards(
      String validator) {
    return _httpGetAndDecode(
        '/distribution/validators/$validator/outstanding_rewards');
  }

  /// Get rewards info of validator
  ///
  /// [validator] account ID of validator
  Future<Map<String, dynamic>> getValidatorRewards(String validator) {
    return _httpGetAndDecode('/distribution/validators/$validator/rewards');
  }

  /// Get distribution parameters
  Future<Map<String, dynamic>> getDistributionParameters() {
    return _httpGetAndDecode('/distribution/parameters');
  }

  Future<Map<String, dynamic>> _httpGetAndDecode(String path) async {
    print('_httpGetAndDecode url ================');
    print(url + path);

    final response = await client.get(url + path);

    print('_httpGetAndDecode response================');
    print(response.body);

    return json.decode(response.body) as Map<String, dynamic>;
  }
}
