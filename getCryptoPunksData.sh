#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Bash script to execute a Go Ethereum `geth` script to extract data from the CryptoPunks
# contract at 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB
#
# TODO:
# 1. Extract all relevant data for sample data sets
# 2. Format data into tab separated values (tsv)
# 3. Extract full data set
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2019. The MIT Licence.
# ----------------------------------------------------------------------------------------------

# echo "Options: [all|events|state]"
# MODE=${1:-all}

ABI=cryptoPunks.js
OUTPUTFILE=cryptoPunksData.txt
TSVFILE=cryptoPunksData.tsv

echo "Starting" | tee $OUTPUTFILE

geth attach << EOF | tee -a $OUTPUTFILE
loadScript("$ABI");

console.log("RESULT: blockNumber\t" + eth.blockNumber);
console.log("RESULT: address\t" + cryptoPunksAddress);
console.log("RESULT: imageHash\t" + cryptoPunks.imageHash());
console.log("RESULT: standard\t" + cryptoPunks.standard());
console.log("RESULT: name\t" + cryptoPunks.name());
console.log("RESULT: symbol\t" + cryptoPunks.symbol());
console.log("RESULT: decimals\t" + cryptoPunks.decimals());
console.log("RESULT: totalSupply\t" + cryptoPunks.totalSupply());
console.log("RESULT: nextPunkIndexToAssign\t" + cryptoPunks.nextPunkIndexToAssign());
console.log("RESULT: allPunksAssigned\t" + cryptoPunks.allPunksAssigned());
console.log("RESULT: punksRemainingToAssign\t" + cryptoPunks.punksRemainingToAssign());

var accountsData = {};
var blocksData = {};
var transactionsData = {};

var i;

// --- Get events in blocks ---

var rangeStart = cryptoPunksDeploymentBlock;
var rangeEnd = eth.blockNumber;
// var rangeEnd = parseInt(rangeStart) + 10000;
var fromBlock;
var toBlock;
var stepSize = 20000;
for (fromBlock = rangeStart; fromBlock < rangeEnd; fromBlock = parseInt(fromBlock) + stepSize) {
  var toBlock = Math.min(parseInt(fromBlock) + stepSize, eth.blockNumber);
  console.log("RESULT: processing\t" + fromBlock + "\t" + toBlock);

  // event Assign(address indexed to, uint256 punkIndex);
  var assignEvents = cryptoPunks.Assign({}, { fromBlock: fromBlock, toBlock: toBlock });
  assignEvents.watch(function (error, result) {
    transactionsData[result.transactionHash] = 1;
    accountsData[result.address] = 1;
    accountsData[result.args.to] = 1;
    // console.log("RESULT: Assign " + JSON.stringify(result));
    console.log("RESULT: event\t" + result.blockNumber + "\t" + result.transactionIndex + "\t" +
      result.transactionHash + "\t" + result.removed + "\t" + result.address + "\t" +
      "Assign\t" + "\t" + result.args.to + "\t" + result.args.punkIndex);
  });
  assignEvents.stopWatching();

  // event Transfer(address indexed from, address indexed to, uint256 value);
  var transferEvents = cryptoPunks.Transfer({}, { fromBlock: fromBlock, toBlock: toBlock });
  transferEvents.watch(function (error, result) {
    transactionsData[result.transactionHash] = 1;
    accountsData[result.address] = 1;
    accountsData[result.args.from] = 1;
    accountsData[result.args.to] = 1;
    console.log("RESULT: event\t" + result.blockNumber + "\t" + result.transactionIndex + "\t" +
      result.transactionHash + "\t" + result.removed + "\t" + result.address + "\t" +
      "Transfer\t" + "\t" + result.args.from + "\t" + result.args.to + "\t" + result.args.value);
  });
  transferEvents.stopWatching();

  // event PunkTransfer(address indexed from, address indexed to, uint256 punkIndex);
  var punkTransferEvents = cryptoPunks.PunkTransfer({}, { fromBlock: fromBlock, toBlock: toBlock });
  punkTransferEvents.watch(function (error, result) {
    transactionsData[result.transactionHash] = 1;
    accountsData[result.address] = 1;
    accountsData[result.args.from] = 1;
    accountsData[result.args.to] = 1;
    console.log("RESULT: event\t" + result.blockNumber + "\t" + result.transactionIndex + "\t" +
      result.transactionHash + "\t" + result.removed + "\t" + result.address + "\t" +
      "PunkTransfer\t" + "\t" + result.args.from + "\t" + result.args.to + "\t" + result.args.punkIndex);
  });
  punkTransferEvents.stopWatching();

  // event PunkOffered(uint indexed punkIndex, uint minValue, address indexed toAddress);
  var punkOfferedEvents = cryptoPunks.PunkOffered({}, { fromBlock: fromBlock, toBlock: toBlock });
  punkOfferedEvents.watch(function (error, result) {
    transactionsData[result.transactionHash] = 1;
    accountsData[result.address] = 1;
    accountsData[result.args.toAddress] = 1;
    console.log("RESULT: event\t" + result.blockNumber + "\t" + result.transactionIndex + "\t" +
      result.transactionHash + "\t" + result.removed + "\t" + result.address + "\t" +
      "PunkOffered\t" + "\t" + result.args.punkIndex + "\t" + result.args.minValue + "\t" + result.args.toAddress);
  });
  punkOfferedEvents.stopWatching();

  // event PunkBidEntered(uint indexed punkIndex, uint value, address indexed fromAddress);
  var punkBidEnteredEvents = cryptoPunks.PunkBidEntered({}, { fromBlock: fromBlock, toBlock: toBlock });
  punkBidEnteredEvents.watch(function (error, result) {
    transactionsData[result.transactionHash] = 1;
    accountsData[result.address] = 1;
    accountsData[result.args.fromAddress] = 1;
    console.log("RESULT: event\t" + result.blockNumber + "\t" + result.transactionIndex + "\t" +
      result.transactionHash + "\t" + result.removed + "\t" + result.address + "\t" +
      "PunkBidEntered\t" + "\t" + result.args.punkIndex + "\t" + result.args.value + "\t" + result.args.fromAddress);
  });
  punkBidEnteredEvents.stopWatching();

  // event PunkBidWithdrawn(uint indexed punkIndex, uint value, address indexed fromAddress);
  var punkBidWithdrawnEvents = cryptoPunks.PunkBidWithdrawn({}, { fromBlock: fromBlock, toBlock: toBlock });
  punkBidWithdrawnEvents.watch(function (error, result) {
    transactionsData[result.transactionHash] = 1;
    accountsData[result.address] = 1;
    accountsData[result.args.fromAddress] = 1;
    console.log("RESULT: event\t" + result.blockNumber + "\t" + result.transactionIndex + "\t" +
      result.transactionHash + "\t" + result.removed + "\t" + result.address + "\t" +
      "PunkBidWithdrawn\t" + "\t" + result.args.punkIndex + "\t" + result.args.value + "\t" + result.args.fromAddress);
  });
  punkBidWithdrawnEvents.stopWatching();

  // event PunkBought(uint indexed punkIndex, uint value, address indexed fromAddress, address indexed toAddress);
  var assignEvents = cryptoPunks.PunkBought({}, { fromBlock: fromBlock, toBlock: toBlock });
  assignEvents.watch(function (error, result) {
    transactionsData[result.transactionHash] = 1;
    accountsData[result.address] = 1;
    accountsData[result.args.fromAddress] = 1;
    accountsData[result.args.toAddress] = 1;
    console.log("RESULT: event\t" + result.blockNumber + "\t" + result.transactionIndex + "\t" +
      result.transactionHash + "\t" + result.removed + "\t" + result.address + "\t" +
      "PunkBought\t" + "\t" + result.args.punkIndex + "\t" + result.args.value + "\t" + result.args.fromAddress + "\t" + result.args.toAddress);
  });
  assignEvents.stopWatching();

  // event PunkNoLongerForSale(uint indexed punkIndex);
  var punkNoLongerForSaleEvents = cryptoPunks.PunkNoLongerForSale({}, { fromBlock: fromBlock, toBlock: toBlock });
  punkNoLongerForSaleEvents.watch(function (error, result) {
    transactionsData[result.transactionHash] = 1;
    accountsData[result.address] = 1;
    console.log("RESULT: event\t" + result.blockNumber + "\t" + result.transactionIndex + "\t" +
      result.transactionHash + "\t" + result.removed + "\t" + result.address + "\t" +
      "PunkNoLongerForSale\t" + "\t" + result.args.punkIndex);
  });
  punkNoLongerForSaleEvents.stopWatching();
}


// 0 (2500 for testing)
var indexStart = 0;
var indexEnd = cryptoPunks.totalSupply();
// var indexEnd = 10;
console.log("RESULT: indexStart\t" + indexStart);
console.log("RESULT: indexEnd\t" + indexEnd);

// Get data by index
for (i = indexStart; i < indexEnd; i++) {
  var address = cryptoPunks.punkIndexToAddress(i);
  accountsData[address] = 1;
  console.log("RESULT: punkIndexToAddress\t" + i + "\t" + cryptoPunks.punkIndexToAddress(i));
  var offer = cryptoPunks.punksOfferedForSale(i);
  console.log("RESULT: punksOfferedForSale\t" + i + "\t" + offer[0] + "\t" + offer[1] + "\t" + offer[2] + "\t" + offer[3] + "\t" + offer[3]);
  var bid = cryptoPunks.punkBids(i);
  console.log("RESULT: punkBids\t" + i + "\t" + bid[0] + "\t" + bid[1] + "\t" + bid[2] + "\t" + bid[3]);
}

// Get data by accounts
var accounts = Object.keys(accountsData).sort();
accounts.forEach(function(e) {
  var balance = cryptoPunks.balanceOf(e);
  console.log("RESULT: balanceOf\t" + e + "\t" + balance);
  console.log("RESULT: pendingWithdrawals\t" + e + "\t" + cryptoPunks.pendingWithdrawals(e));
  console.log("RESULT: getBalance\t" + e + "\t" + eth.getBalance(e));
});

/*
// Get data by transactions
var transactions = Object.keys(transactionsData).sort();
transactions.forEach(function(e) {
  var tx = eth.getTransaction(e);
  var txr = eth.getTransactionReceipt(e);
  console.log("RESULT: tx\t" + e + "\t" + JSON.stringify(tx));
  console.log("RESULT: txReceipt\t" + e + "\t" + JSON.stringify(txReceipt));
});
*/


EOF

grep "RESULT: " $OUTPUTFILE > $TSVFILE
cat $TSVFILE
