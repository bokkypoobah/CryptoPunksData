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


var ENDEVENTS = eth.blockNumber;
var STARTEVENTS = ENDEVENTS - 2000;

// event Assign(address indexed to, uint256 punkIndex);
var ASSIGNSTART = 3918216;
// First assignment phase end. Further assignments after this block
// var ASSIGNEND = 3919418;
var ASSIGNEND = parseInt(ASSIGNSTART) + 20;
var assignEvents = cryptoPunks.Assign({}, { fromBlock: ASSIGNSTART, toBlock: ASSIGNEND });
i = 0;
assignEvents.watch(function (error, result) {
  console.log("RESULT: Assign " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
});
assignEvents.stopWatching();

// event Transfer(address indexed from, address indexed to, uint256 value);
// TODO

// event PunkTransfer(address indexed from, address indexed to, uint256 punkIndex);
// TODO

// event PunkOffered(uint indexed punkIndex, uint minValue, address indexed toAddress);
// TODO

// event PunkBidEntered(uint indexed punkIndex, uint value, address indexed fromAddress);
// TODO

// event PunkBidWithdrawn(uint indexed punkIndex, uint value, address indexed fromAddress);
// TODO
var PUNKBIDWITHDRAWNSTART = 7355365;
var PUNKBIDWITHDRAWNEND = 7366652;
var punkBidWithdrawnEvents = cryptoPunks.PunkBidWithdrawn({}, { fromBlock: PUNKBIDWITHDRAWNSTART, toBlock: PUNKBIDWITHDRAWNEND });
i = 0;
punkBidWithdrawnEvents.watch(function (error, result) {
  console.log("RESULT: PunkBidWithdrawn " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
});
punkBidWithdrawnEvents.stopWatching();


// event PunkBought(uint indexed punkIndex, uint value, address indexed fromAddress, address indexed toAddress);
var PUNKBOUGHTSTART = 7372263;
var PUNKBOUGHTEND = 7372277;
var assignEvents = cryptoPunks.PunkBought({}, { fromBlock: PUNKBOUGHTSTART, toBlock: PUNKBOUGHTEND });
i = 0;
assignEvents.watch(function (error, result) {
  console.log("RESULT: PunkBought " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
});
assignEvents.stopWatching();

// event PunkNoLongerForSale(uint indexed punkIndex);
// TODO

exit;



EOF

grep "RESULTS: " $OUTPUTFILE > $TSVFILE
cat $TSVFILE
