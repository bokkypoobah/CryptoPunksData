#!/bin/sh

ABI=cryptoPunks.js
OUTPUTFILE=cryptoPunksData.txt
TSVFILE=cryptoPunksData.tsv

echo "Starting" | tee $OUTPUTFILE

geth attach << EOF | tee -a $OUTPUTFILE

// cryptoPunks.totalSupply() = 10000
var MAXINDEX=100;

loadScript("$ABI");

console.log("RESULT: --- CryptoPunksMarket @ " + cryptoPunksAddress + " ---");
console.log("RESULT: imageHash: " + cryptoPunks.imageHash());
console.log("RESULT: standard: " + cryptoPunks.standard());
console.log("RESULT: name: " + cryptoPunks.name());
console.log("RESULT: symbol: " + cryptoPunks.symbol());
console.log("RESULT: decimals: " + cryptoPunks.decimals());
console.log("RESULT: totalSupply: " + cryptoPunks.totalSupply());
console.log("RESULT: NOTE. Using only the first " + MAXINDEX + " items for testing");
console.log("RESULT: nextPunkIndexToAssign: " + cryptoPunks.nextPunkIndexToAssign());
console.log("RESULT: allPunksAssigned: " + cryptoPunks.allPunksAssigned());
console.log("RESULT: punksRemainingToAssign: " + cryptoPunks.punksRemainingToAssign());


//mapping (address => uint) public addressToPunkIndex;
// mapping (uint => address) public punkIndexToAddress;

// mapping (address => uint256) public balanceOf;

var accountsData = {};

var i;
for (i = 0; i < MAXINDEX; i++) {
  var address = cryptoPunks.punkIndexToAddress(i);
  accountsData[address] = 1;
  console.log("RESULT: punkIndexToAddress(" + i + "): " + cryptoPunks.punkIndexToAddress(i));
}

var accounts = Object.keys(accountsData).sort();

accounts.forEach(function(e) {
  var balance = cryptoPunks.balanceOf(e);
  console.log("RESULT: balanceOf(" + e + "): " + balance);
});


EOF

grep "RESULTS: " $OUTPUTFILE > $TSVFILE
cat $TSVFILE
