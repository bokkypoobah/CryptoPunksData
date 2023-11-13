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
    const firstEvent = events[0];
    if (firstEvent[EVENTFIELD_TYPE] == 0) { // Assign
      if (firstEvent[EVENTFIELD_CONTRACT] == 1) {
        if (firstEvent[3] == cryptoPunksDeployerIndex) {
          return [0]; // Reserve
        } else {
          return [1]; // Claim
        }
      } else if (firstEvent[EVENTFIELD_CONTRACT] == 2) {
        return [2]; // Airdrop
      }
    }

    if (eventsLength == 2) { // V1 transferPunk and V2 without bids to cancel
      const secondEvent = events[1];
      if (firstEvent[EVENTFIELD_TYPE] == 1 && secondEvent[EVENTFIELD_TYPE] == 2) { // Transfer & PunkTransfer
        return [3]; // Transfer
      }
    }

    if (eventsLength == 3) { // V2 transferPunk with bids cancelled
      const secondEvent = events[1];
      const thirdEvent = events[2];
      if (firstEvent[EVENTFIELD_TYPE] == 4 && secondEvent[EVENTFIELD_TYPE] == 1 && thirdEvent[EVENTFIELD_TYPE] == 2) { // PunkNoLongerForSale & Transfer & PunkTransfer
        return [3]; // Transfer
      }
    }

    if (eventsLength == 1) {
      if (firstEvent[EVENTFIELD_TYPE] == 3) { // PunkOffered
        return [4]; // Offer
      } else if (firstEvent[EVENTFIELD_TYPE] == 4) { // PunkNoLongerForSale
        return [5]; // Offer
      } else if (firstEvent[EVENTFIELD_TYPE] == 5) { // PunkBidEntered
        return [7]; // Bid
      } else if (firstEvent[EVENTFIELD_TYPE] == 6) { // PunkBidWithdrawn
        return [8]; // RemoveBid
      }
    }

    if (eventsLength == 3) {
      const secondEvent = events[1];
      const thirdEvent = events[2];
      if (firstEvent[EVENTFIELD_TYPE] == 1 && secondEvent[EVENTFIELD_TYPE] == 4 && thirdEvent[EVENTFIELD_TYPE] == 7) { // Transfer & PunkNoLongerForSale & PunkBought
        return [6]; // Purchase
      }
    }

    if (eventsLength == 2) {
      const secondEvent = events[1];
      if (firstEvent[EVENTFIELD_TYPE] == 1 && secondEvent[EVENTFIELD_TYPE] == 7) { // Transfer & PunkBought
        return [9]; // AcceptBid
      }
    }

    if (eventsLength == 4) { // V1 Wrap
      // TODO: Check 2 contracts
      const secondEvent = events[1];
      const thirdEvent = events[2];
      const fourthEvent = events[3];
      if (firstEvent[EVENTFIELD_TYPE] == 1 && secondEvent[EVENTFIELD_TYPE] == 4 && thirdEvent[EVENTFIELD_TYPE] == 7 && fourthEvent[EVENTFIELD_TYPE] == 1) { // Transfer & PunkNoLongerForSale & PunkBought & Transfer
        return [10]; // Wrap (V1)
      }
    }

    if (eventsLength == 4) { // V1 Unwrap
      // TODO: Check 2 contracts
      const secondEvent = events[1];
      const thirdEvent = events[2];
      const fourthEvent = events[3];
      if (firstEvent[EVENTFIELD_TYPE] == 8 && secondEvent[EVENTFIELD_TYPE] == 1 && thirdEvent[EVENTFIELD_TYPE] == 1 && fourthEvent[EVENTFIELD_TYPE] == 2) { // Approval & Transfer & Transfer & PunkTransfer
        return [11]; // Unwrap (V1)
      }
    }

    if (eventsLength == 3) { // V2 Wrap
      // TODO: Check 2 contracts
      const secondEvent = events[1];
      const thirdEvent = events[2];
      if (firstEvent[EVENTFIELD_TYPE] == 1 && secondEvent[EVENTFIELD_TYPE] == 2 && thirdEvent[EVENTFIELD_TYPE] == 1) { // Transfer & PunkTransfer & Transfer
        return [10]; // Wrap (V2)
      }
    }

    if (eventsLength == 3) { // V2 Unwrap
      // TODO: Check 2 contracts
      const secondEvent = events[1];
      const thirdEvent = events[2];
      if (firstEvent[EVENTFIELD_TYPE] == 1 && secondEvent[EVENTFIELD_TYPE] == 1 && thirdEvent[EVENTFIELD_TYPE] == 2) { // Transfer & Transfer & PunkTransfer
        return [11]; // Unwrap (V2)
      }
    }

  }
  return [undefined];
}
