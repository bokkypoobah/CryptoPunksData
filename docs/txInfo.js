async function getTxInfo(data, provider, exchangeRates) {
  console.log("getTxInfo - BEGIN: " + JSON.stringify(data));
  const tx = await provider.getTransaction(data.txHash);
  data.tx = {
    hash: tx.hash,
    type: tx.type,
    blockHash: tx.blockHash,
    blockNumber: tx.blockNumber,
    transactionIndex: tx.transactionIndex,
    from: tx.from,
    gasPrice: ethers.BigNumber.from(tx.gasPrice).toString(),
    gasLimit: ethers.BigNumber.from(tx.gasLimit).toString(),
    to: tx.to,
    value: ethers.BigNumber.from(tx.value).toString(),
    nonce: tx.nonce,
    data: tx.to && tx.data || null, // Remove contract creation data to reduce memory footprint
    // r: tx.r,
    // s: tx.s,
    // v: tx.v,
    chainId: tx.chainId,
  };
  const txReceipt = await provider.getTransactionReceipt(data.txHash);
  data.txReceipt = {
    to: txReceipt.to,
    from: txReceipt.from,
    contractAddress: txReceipt.contractAddress,
    transactionIndex: txReceipt.transactionIndex,
    gasUsed: ethers.BigNumber.from(txReceipt.gasUsed).toString(),
    blockHash: txReceipt.blockHash,
    // transactionHash: txReceipt.transactionHash,
    logs: txReceipt.logs,
    blockNumber: txReceipt.blockNumber,
    // confirmations: txReceipt.confirmations,
    cumulativeGasUsed: ethers.BigNumber.from(txReceipt.cumulativeGasUsed).toString(),
    effectiveGasPrice: ethers.BigNumber.from(txReceipt.effectiveGasPrice).toString(),
    status: txReceipt.status,
    type: txReceipt.type,
    // byzantium: txReceipt.byzantium,
  };
  const block = await provider.getBlock(data.tx.blockNumber);
  data.timestamp = block.timestamp;
  const yyyymmdd = moment.unix(block.timestamp).utc().format("YYYYMMDD");
  data.exchangeRate = exchangeRates[yyyymmdd];
  const gasUsed = ethers.BigNumber.from(data.txReceipt.gasUsed);
  data.txFee = ethers.utils.formatEther(gasUsed.mul(data.txReceipt.effectiveGasPrice).toString());
  data.txFeeInReportingCurrency = (parseFloat(data.txFee) * data.exchangeRate).toFixed(2);
  console.log("getTxInfo - END: " + JSON.stringify(data));
  return data;
}
