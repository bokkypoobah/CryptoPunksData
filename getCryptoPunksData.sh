#!/bin/sh

ABI=cryptoPunks.js
OUTPUTFILE=cryptoPunksData.txt
TSVFILE=cryptoPunksData.tsv

echo "Starting" | tee $OUTPUTFILE

geth attach << EOF | tee -a $OUTPUTFILE

// 0
var START = 2500;
// cryptoPunks.totalSupply() = 10000
var END = 2600;
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


EOF

grep "RESULTS: " $OUTPUTFILE > $TSVFILE
cat $TSVFILE
