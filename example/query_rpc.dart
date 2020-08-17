import 'package:kuchaindart/query_rpc.dart';

Future main() async {
  const url = 'http://121.89.216.155';

  // Configure your own information

  // 账号信息
  const myAccount = 'testaccount1';

  // 地址信息
  const myAddress = 'kratos1ektcysuggtw29g5tql9mgv32fx6nkv900ghnkg';

  // 验证人
  const validator = 'michael';
  const validator2 = 'raphael';

  // 代币符号
  const coinCreator = 'kratos';
  const coinSymbol = 'kts';
  const denomination = 'kratos/kts';

  // 提案
  const proposalId = '3';

  final queryRPC = QueryRPC();

  queryRPC.config(
    url: url,
  );

  // ====================================
  //           节点信息接口
  // ====================================

  // 查询节点基本信息，如链ID、节点名、块高度等
  await queryRPC.getNodeInfo();

  // 获取最新区块信息
  // await queryRPC.getBlocks();

  // 获取指定高度区块信息
  // await queryRPC.getBlocks('1');

  // ====================================
  //           用户信息接口
  // ====================================

  // 获取指定用户的信息
  // await queryRPC.getAccountInfo(myAccount);

  // 获取指定AUTH的信息
  // await queryRPC.getAuthInfo(myAddress);

  // 根据AUTH查询ACCOUNT列表
  // await queryRPC.getAccountsByAuth(myAddress);

  // ====================================
  //           交易相关接口
  // ====================================

  // 根据HASH获取指定交易的信息
  // await queryRPC.getTxsByHash('42B01D85B442F4CF4BF2923B207D362304C5EEF8E1AC230D3DAE8937E490FE7B');

  // 根据参数中设置的条件获取指定交易的信息
  // await queryRPC.getTxs(
  //   messageAction: 'delegate',
  //   messageSender: myAccount,
  //   page: '1',
  //   limit: '10',
  // );

  // ====================================
  //           资产相关接口
  // ====================================

  // 获取指定账户资产
  // await queryRPC.getCoins(myAddress);

  // 获取指定账户COINPOWER（COINPOWER是模块账户内部的资产）
  // await queryRPC.getCoinPowers(validator);

  // 获取资产供给总量信息
  // await queryRPC.getSupplyTotal();

  // 获取指定资产供给总量信息
  // await queryRPC.getSupplyTotal(denomination);

  // 获取通胀/通缩参数信息
  // await queryRPC.getMintingParameters();

  // 获取锁仓信息
  // await queryRPC.getCoinsLocked(myAccount);

  // 获取代币状态信息
  // await queryRPC.getCoinsStat(coinCreator, coinSymbol);

  // ====================================
  //           staking模块接口
  // ====================================

  // 获取指定用户的所有抵押信息
  // await queryRPC.getDelegations(myAccount);

  // 查看指定用户针对指定节点的抵押信息
  // await queryRPC.getDelegations(myAccount, validator);

  // 查看指定用户撤回抵押后还未到账的资产
  // await queryRPC.getUnbondingDelegations(myAccount);

  // 查看指定用户针对指定节点撤回抵押后还未到账的资产
  // await queryRPC.getUnbondingDelegations(myAccount, validator);

  // 查看转移抵押的相关信息
  // 请求说明：由于转移抵押不存在冻结期，交易提交出块后抵押就已转移，所以该接口大概率是返回查询不到
  // await queryRPC.getRedelegations(
  //   delegator: myAccount,
  //   validatorFrom: validator,
  //   validatorTo: validator2,
  // );

  // 查看指定用户抵押的所有节点信息
  // await queryRPC.getValidatorsByDelegator(myAccount);

  // 查看指定用户针对指定节点抵押的节点信息
  // await queryRPC.getValidatorsByDelegator(myAccount, validator);

  // 查看所有验证节点信息
  // await queryRPC.getAllValidators();

  // 查看指定验证节点信息
  // await queryRPC.getValidatorInfo(validator);

  // 查看指定验证节点的所有抵押用户信息
  // await queryRPC.getValidatorDelegations(validator);

  // 查看指定验证节点所有撤回投票后还未到账的资产
  // await queryRPC.getValidatorUnbondingDelegations(validator);

  // 查看当前抵押池信息
  // await queryRPC.getStakingPoolInfo();

  // 查看当前抵押参数信息
  // await queryRPC.getStakingParameters();

  // ====================================
  //           提案相关接口
  // ====================================

  // 查询提案
  // await queryRPC.getProposals(
  //   depositor: myAccount,
  //   status: 'DepositPeriod',
  // );

  // 查询指定提案信息
  // await queryRPC.getProposalInfo(proposalId);

  // 查询指定提案的提案人
  // await queryRPC.getProposalProposer(proposalId);

  // 查询指定提案当前投票状态
  // await queryRPC.getProposalTally(proposalId);

  // 查询指定提案的保证金
  // await queryRPC.getProposalDeposits(proposalId);

  // 查询指定用户为指定提案缴纳的保证金
  // await queryRPC.getProposalDeposits(proposalId, myAccount);

  // 查询指定提案的投票信息
  // await queryRPC.getProposalVotes(proposalId);

  // 查询指定用户对指定提案的投票信息
  // await queryRPC.getProposalVotes(proposalId, validator);

  // 查询为提案缴纳保证金的相关参数信息（如最小保证金数、最大保证金缴纳期限）
  // await queryRPC.getDepositParameters();

  // 查询为提案投票的相关参数信息（如投票期限）
  // await queryRPC.getVotingParameters();

  // ====================================
  //           分红相关接口
  // ====================================

  // 查询指定用户的所有抵押回报
  // await queryRPC.getDelegationRewards(myAccount);

  // 查询指定用户的针对指定节点的抵押回报
  // await queryRPC.getDelegationRewards(myAccount, validator);

  // 查询指定用户领取抵押回报的账户(用户可以自行设置领取自己分红的账户)
  // await queryRPC.getDistributionWithdrawAccount(myAccount);

  // 查询指定节点所有的分红信息（包括抵押用户，节点自己，手续费）
  // await queryRPC.getValidatorDistribution(validator);

  // 查询指定节点的手续费分红信息
  // await queryRPC.getValidatorOutstandingRewards(validator);

  // 查询指定节点自身的分红信息
  // await queryRPC.getValidatorRewards(validator);

  // 查询分红模块相关参数
  // await queryRPC.getDistributionParameters();
}
