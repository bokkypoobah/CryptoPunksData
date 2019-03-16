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

ABI=cryptoPunks.js
OUTPUTFILE=cryptoPunksData.txt
TSVFILE=cryptoPunksData.tsv

echo "Starting" | tee $OUTPUTFILE

geth attach << EOF | tee -a $OUTPUTFILE

// 0
var START = 2500;
// cryptoPunks.totalSupply() = 10000
var END = 2530;
console.log("RESULT: NOTE. Using only the indices between " + START + " and " + END + " for testing");

loadScript("$ABI");

console.log("RESULT: --- CryptoPunksMarket @ " + cryptoPunksAddress + " ---");
console.log("RESULT: imageHash: " + cryptoPunks.imageHash());
console.log("RESULT: standard: " + cryptoPunks.standard());
console.log("RESULT: name: " + cryptoPunks.name());
console.log("RESULT: symbol: " + cryptoPunks.symbol());
console.log("RESULT: decimals: " + cryptoPunks.decimals());
console.log("RESULT: totalSupply: " + cryptoPunks.totalSupply());
console.log("RESULT: nextPunkIndexToAssign: " + cryptoPunks.nextPunkIndexToAssign());
console.log("RESULT: allPunksAssigned: " + cryptoPunks.allPunksAssigned());
console.log("RESULT: punksRemainingToAssign: " + cryptoPunks.punksRemainingToAssign());

var accountsData = {};

var i;
for (i = START; i < END; i++) {
  var address = cryptoPunks.punkIndexToAddress(i);
  accountsData[address] = 1;
  console.log("RESULT: punkIndexToAddress(" + i + "): " + cryptoPunks.punkIndexToAddress(i));
  console.log("RESULT: punksOfferedForSale(" + i + "): " + cryptoPunks.punksOfferedForSale(i));
  console.log("RESULT: punkBids(" + i + "): " + cryptoPunks.punkBids(i));
}
var accounts = Object.keys(accountsData).sort();

accounts.forEach(function(e) {
  var balance = cryptoPunks.balanceOf(e);
  console.log("RESULT: balanceOf(" + e + "): " + balance);
  console.log("RESULT: pendingWithdrawals(" + e + "): " + cryptoPunks.pendingWithdrawals(e));
});

var fromBlock = cryptoPunksDeploymentBlock;
var toBlock = eth.blockNumber;

// event Assign(address indexed to, uint256 punkIndex);
fromBlock = 3918216;
// First assignment phase end. Further assignments after this block
// var toBlock = 3919418;
toBlock = parseInt(fromBlock) + 20;
var assignEvents = cryptoPunks.Assign({}, { fromBlock: fromBlock, toBlock: toBlock });
i = 0;
assignEvents.watch(function (error, result) {
  console.log("RESULT: " + result.blockNumber + "\t" + result.transactionIndex + "\t" +
    result.transactionHash + "\t" + result.address + "\t" + "Assign\t" + "\t" + result.args.to + "\t" +
    result.args.punkIndex);
});
assignEvents.stopWatching();

// event Transfer(address indexed from, address indexed to, uint256 value);
fromBlock = 3920026;
toBlock = 3920546;
var transferEvents = cryptoPunks.Transfer({}, { fromBlock: fromBlock, toBlock: toBlock });
i = 0;
transferEvents.watch(function (error, result) {
  console.log("RESULT: " + result.blockNumber + "\t" + result.transactionIndex + "\t" +
    result.transactionHash + "\t" + result.address + "\t" + "Transfer\t" + "\t" + result.args.from + "\t" +
    result.args.to + "\t" + result.args.value);
});
transferEvents.stopWatching();

// event PunkTransfer(address indexed from, address indexed to, uint256 punkIndex);
fromBlock = 3920026;
toBlock = 3931970;
var punkTransferEvents = cryptoPunks.PunkTransfer({}, { fromBlock: fromBlock, toBlock: toBlock });
i = 0;
punkTransferEvents.watch(function (error, result) {
  console.log("RESULT: " + result.blockNumber + "\t" + result.transactionIndex + "\t" +
    result.transactionHash + "\t" + result.address + "\t" + "PunkTransfer\t" + "\t" + result.args.from + "\t" +
    result.args.to + "\t" + result.args.punkIndex);
});
punkTransferEvents.stopWatching();

// event PunkOffered(uint indexed punkIndex, uint minValue, address indexed toAddress);
fromBlock = 7317877;
toBlock = 7355280;
var punkOfferedEvents = cryptoPunks.PunkOffered({}, { fromBlock: fromBlock, toBlock: toBlock });
i = 0;
punkOfferedEvents.watch(function (error, result) {
  console.log("RESULT: " + result.blockNumber + "\t" + result.transactionIndex + "\t" +
    result.transactionHash + "\t" + result.address + "\t" + "PunkOffered\t" + "\t" + result.args.punkIndex + "\t" +
    result.args.minValue + "\t" + result.args.toAddress);
});
punkOfferedEvents.stopWatching();

// event PunkBidEntered(uint indexed punkIndex, uint value, address indexed fromAddress);
fromBlock = 7355365;
toBlock = 7366652;
var punkBidEnteredEvents = cryptoPunks.PunkBidEntered({}, { fromBlock: fromBlock, toBlock: toBlock });
i = 0;
punkBidEnteredEvents.watch(function (error, result) {
  console.log("RESULT: " + result.blockNumber + "\t" + result.transactionIndex + "\t" +
    result.transactionHash + "\t" + result.address + "\t" + "PunkBidEntered\t" + "\t" + result.args.punkIndex + "\t" +
    result.args.value + "\t" + result.args.fromAddress);
});
punkBidEnteredEvents.stopWatching();

// event PunkBidWithdrawn(uint indexed punkIndex, uint value, address indexed fromAddress);
fromBlock = 7355365;
toBlock = 7366652;
var punkBidWithdrawnEvents = cryptoPunks.PunkBidWithdrawn({}, { fromBlock: fromBlock, toBlock: toBlock });
i = 0;
punkBidWithdrawnEvents.watch(function (error, result) {
  console.log("RESULT: " + result.blockNumber + "\t" + result.transactionIndex + "\t" +
    result.transactionHash + "\t" + result.address + "\t" + "PunkBidWithdrawn\t" + "\t" + result.args.punkIndex + "\t" +
    result.args.value + "\t" + result.args.fromAddress);
});
punkBidWithdrawnEvents.stopWatching();

// event PunkBought(uint indexed punkIndex, uint value, address indexed fromAddress, address indexed toAddress);
fromBlock = 7372263;
toBlock = 7372277;
var assignEvents = cryptoPunks.PunkBought({}, { fromBlock: fromBlock, toBlock: toBlock });
i = 0;
assignEvents.watch(function (error, result) {
  console.log("RESULT: " + result.blockNumber + "\t" + result.transactionIndex + "\t" +
    result.transactionHash + "\t" + result.address + "\t" + "PunkBought\t" + "\t" + result.args.punkIndex + "\t" +
    result.args.value + "\t" + result.args.fromAddress + "\t" + result.args.toAddress);
});
assignEvents.stopWatching();

// event PunkNoLongerForSale(uint indexed punkIndex);
fromBlock = 7355365;
toBlock = 7366652;
var punkNoLongerForSaleEvents = cryptoPunks.PunkNoLongerForSale({}, { fromBlock: fromBlock, toBlock: toBlock });
i = 0;
punkNoLongerForSaleEvents.watch(function (error, result) {
  // console.log("RESULT: PunkNoLongerForSale " + JSON.stringify(result));
  console.log("RESULT: " + result.blockNumber + "\t" + result.transactionIndex + "\t" +
    result.transactionHash + "\t" + result.address + "\t" + "PunkNoLongerForSale\t" + "\t" + result.args.punkIndex);
});
punkNoLongerForSaleEvents.stopWatching();


EOF

grep "RESULTS: " $OUTPUTFILE > $TSVFILE
cat $TSVFILE
