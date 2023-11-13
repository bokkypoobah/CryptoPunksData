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

  // indexToEventTypes: [
  //   "Assign", // 0
  //   "Transfer", // 1
  //   "PunkTransfer", // 2
  //   "PunkOffered", // 3
  //   "PunkNoLongerForSale", // 4
  //   "PunkBidEntered", // 5
  //   "PunkBidWithdrawn", // 6
  //   "PunkBought", // 7
  //   "Approval", // 8
  //   "ApprovalForAll", // 9
  //   "OwnershipTransferred", // 10
  //   "ProxyRegistered", // 11
  // ],

  // indexToTransactionTypes: [
  //   "Reserve", // 0
  //   "Claim", // 1
  //   "Airdrop", // 2
  //   "Transfer", // 3
  //   "Offer", // 4
  //   "RemoveOffer", // 5
  //   "Purchase", // 6
  //   "Bid", // 7
  //   "RemoveBid", // 8
  //   "AcceptBid", // 9
  //   "Wrap", // 10
  //   "Unwrap", // 11
  //   "Approval", // 12
  //   "ApprovalForAll", // 13
  //   "OwnershipTransferred", // 14
  //   "ProxyRegistered", // 15
  // ],

  const eventsLength = events.length;
  if (eventsLength > 0) {
    if (events[0][EVENTFIELD_TYPE] == 0) { // Assign
      if (events[0][EVENTFIELD_CONTRACT] == 1) {
        if (events[0][3] == cryptoPunksDeployerIndex) {
          return 0; // Reserve
        } else {
          return 1; // Claim
        }
      } else if (events[0][EVENTFIELD_CONTRACT] == 2) {
        return 2; // Airdrop
      }
    }
  }

  if (eventsLength == 2) {
    if (events[0][EVENTFIELD_TYPE] == 1 && events[1][EVENTFIELD_TYPE] == 2) { // Transfer & PunkTransfer
      return 3; // Transfer
    }
  }
  return undefined;
}
