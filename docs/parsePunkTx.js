let cryptoPunksDeployerIndex = null;

const EVENTFIELD_LOGINDEX = 0;
const EVENTFIELD_CONTRACT = 1;
const EVENTFIELD_TYPE = 2;
const EVENTFIELD_FIELD_3 = 3;

let myCounter = 0;

function parsePunkTx(txHash, events, addressToIndex) {
  // console.log("parsePunkTx: " + txHash); //  + " => " + JSON.stringify(txInfo));
  if (!cryptoPunksDeployerIndex) {
    cryptoPunksDeployerIndex = addressToIndex[CRYPTOPUNKSDEPLOYER];
  }

  if (myCounter++ < 10) {
    console.log("  " + txHash + ": " + JSON.stringify(events));    
  }

  if (events.length > 0) {
    // Assign
    if (events[0][EVENTFIELD_TYPE] == 0) {
      // console.log("Assign");
      // V1
      if (events[0][EVENTFIELD_CONTRACT] == 1) {
        // console.log("v1");
        if (events[0][3] == cryptoPunksDeployerIndex) {
          console.log("v1 - LarvaLabs - first punkId: " + events[0][4] + ", count: " + events.length + " " + txHash);
          return ['v1 LarvaLabs Reserve'];
        } else {
          return ['v1 Claim'];
        }
      } else if (events[0][EVENTFIELD_CONTRACT] == 2) {
        // console.log("v2");
        if (events[0][3] == cryptoPunksDeployerIndex) {
          console.log("v2 - Airdrop v2 - first punkId: " + events[0][4] + ", count: " + events.length + " " + txHash);
          return ['v2 Airdrop (LarvaLabs)'];
        } else {
          return ['v2 Airdrop'];
          // console.log("--- UNEXPECTED ---")
        }
      }
    }
  }
  return undefined;
}
