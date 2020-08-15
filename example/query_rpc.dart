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

  // 代币符号
  const coinCreator = 'kratos';
  const coinSymbol = 'kts';
  const denomination = 'kratos/kts';

  final queryRPC = QueryRPC();

  queryRPC.config(
    url: url,
  );

  // ====================================
  //           节点信息接口
  // ====================================

  // 查询节点基本信息，如链ID、节点名、块高度等
  // await queryRPC.getNodeInfo();

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

  // 根据参数中设置的条件获取指定交易的信息（待验证）
  // await queryRPC.getTxs(
  //   messageAction: 'create@account',
  //   messageSender: myAccount,
  //   page: '1',
  //   limit: '10',
  // );

  // ====================================
  //           资产相关接口
  // ====================================

  // 获取指定账户资产
  // await queryRPC.getCoins(myAddress);

  // 获取指定账户COINPOWER（COINPOWER是模块账户内部的资产）(待验证)
  // await queryRPC.getCoinPowers(validator);

  // 获取资产供给总量信息
  // await queryRPC.getSupplyTotal();

  // 获取指定资产供给总量信息
  // await queryRPC.getSupplyTotal(denomination);

  // 获取通胀/通缩参数信息
  // await queryRPC.getMintingParameters();

  // 获取锁仓信息(待验证)
  // await queryRPC.getCoinsLocked(myAccount);

  // 获取代币状态信息
  await queryRPC.getCoinsStat(coinCreator, coinSymbol);
}
