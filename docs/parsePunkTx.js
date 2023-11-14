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
          return [ 0, firstEvent[3], events.map(e => e[4]) ]; // Reserve
        } else {
          return [ 1, firstEvent[3], firstEvent[4] ]; // Claim
        }
      } else if (firstEvent[EVENTFIELD_CONTRACT] == 2) {
        return [ 2, events.map(e => [e[3], e[4]]) ]; // Airdrop
      }
    }

    if (eventsLength == 2) { // V1 transferPunk and V2 without bids to cancel
      const secondEvent = events[1];
      if (firstEvent[EVENTFIELD_TYPE] == 1 && secondEvent[EVENTFIELD_TYPE] == 2) { // Transfer & PunkTransfer
        return [ 3, secondEvent[3], secondEvent[4], secondEvent[5] ]; // [ Transfer, from, to, punkId ]
      }
    }

    if (eventsLength == 3) { // V2 transferPunk with bids cancelled
      const secondEvent = events[1];
      const thirdEvent = events[2];
      if (firstEvent[EVENTFIELD_TYPE] == 4 && secondEvent[EVENTFIELD_TYPE] == 1 && thirdEvent[EVENTFIELD_TYPE] == 2) { // PunkNoLongerForSale & Transfer & PunkTransfer
        return [ 3, thirdEvent[3], thirdEvent[4], thirdEvent[5] ]; // [ Transfer, from, to, punkId ]
      }
    }

    if (eventsLength == 1) {
      if (firstEvent[EVENTFIELD_TYPE] == 1) { // Transfer (W1)
        return [ 3, firstEvent[3], firstEvent[4], firstEvent[5] ]; // [ Transfer, from, to, punkId ]
      } else if (firstEvent[EVENTFIELD_TYPE] == 3) { // PunkOffered
        return [ 4, firstEvent[6], firstEvent[5], firstEvent[3], firstEvent[4] ]; // [ Offer, from, to, punkId, amount ]
      } else if (firstEvent[EVENTFIELD_TYPE] == 4) { // PunkNoLongerForSale
        return [ 5, firstEvent[4], firstEvent[3] ]; // [ Offer, from, punkId ]
      } else if (firstEvent[EVENTFIELD_TYPE] == 5) { // PunkBidEntered
        return [ 7, firstEvent[5], firstEvent[3], firstEvent[4] ]; // [ Bid, from, punkId, amount ]
      } else if (firstEvent[EVENTFIELD_TYPE] == 6) { // PunkBidWithdrawn
        return [ 8, firstEvent[5], firstEvent[3], firstEvent[4] ]; // [ RemoveBid, from, punkId, amount ]
      } else if (firstEvent[EVENTFIELD_TYPE] == 8) { // Approval
        return [ 12, firstEvent[3], firstEvent[4], firstEvent[5] ]; // [ Approval, owner, approved, tokenId ]
        // w1 w2 event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
      } else if (firstEvent[EVENTFIELD_TYPE] == 9) { // ApprovalForAll
        return [ 13, firstEvent[3], firstEvent[4], firstEvent[5] ]; // [ ApprovalForAll, owner, operator, approved ]
        // w1 w2 event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
      } else if (firstEvent[EVENTFIELD_TYPE] == 10) { // OwnershipTransferred
        return [ 14, firstEvent[3], firstEvent[4] ]; // [ OwnershipTransferred, from, to ]
      } else if (firstEvent[EVENTFIELD_TYPE] == 11) { // ProxyRegistered
        return [ 15, firstEvent[3], firstEvent[4] ]; // [ ProxyRegistered, user, proxy ]
      }
    }

    if (eventsLength == 3) {
      const secondEvent = events[1];
      const thirdEvent = events[2];
      if (firstEvent[EVENTFIELD_TYPE] == 1 && secondEvent[EVENTFIELD_TYPE] == 4 && thirdEvent[EVENTFIELD_TYPE] == 7) { // Transfer & PunkNoLongerForSale & PunkBought
        return [ 6, thirdEvent[6], thirdEvent[5], thirdEvent[3], thirdEvent[4] ]; // [ Purchase, from, to, punkId, amount ]
      }
    }

    if (eventsLength == 2) {
      const secondEvent = events[1];
      if (firstEvent[EVENTFIELD_TYPE] == 1 && secondEvent[EVENTFIELD_TYPE] == 7) { // Transfer & PunkBought
        return [ 9, secondEvent[5], secondEvent[6], secondEvent[3], secondEvent[4]]; // [ AcceptBid, from, to, punkId, amount ]
      }
    }

    if (eventsLength == 4) { // V1 Wrap
      // TODO: Check 2 contracts
      const secondEvent = events[1];
      const thirdEvent = events[2];
      const fourthEvent = events[3];
      if (firstEvent[EVENTFIELD_TYPE] == 1 && secondEvent[EVENTFIELD_TYPE] == 4 && thirdEvent[EVENTFIELD_TYPE] == 7 && fourthEvent[EVENTFIELD_TYPE] == 1) { // Transfer & PunkNoLongerForSale & PunkBought & Transfer
        return [ 10, firstEvent[3], fourthEvent[5] ]; // [ Wrap(V1), owner, punkId ]
      }
    }

    if (eventsLength == 4) { // V1 Unwrap
      // TODO: Check 2 contracts
      const secondEvent = events[1];
      const thirdEvent = events[2];
      const fourthEvent = events[3];
      if (firstEvent[EVENTFIELD_TYPE] == 8 && secondEvent[EVENTFIELD_TYPE] == 1 && thirdEvent[EVENTFIELD_TYPE] == 1 && fourthEvent[EVENTFIELD_TYPE] == 2) { // Approval & Transfer & Transfer & PunkTransfer
        return [11, fourthEvent[4], fourthEvent[5] ]; // [ Unwrap(V1), owner, punkId ]
      }
    }

    if (eventsLength == 3) { // V2 Wrap
      // TODO: Check 2 contracts
      const secondEvent = events[1];
      const thirdEvent = events[2];
      if (firstEvent[EVENTFIELD_TYPE] == 1 && secondEvent[EVENTFIELD_TYPE] == 2 && thirdEvent[EVENTFIELD_TYPE] == 1) { // Transfer & PunkTransfer & Transfer
        return [ 10, thirdEvent[4], thirdEvent[5] ]; // [ Wrap(V2), owner, punkId ]
      }
    }

    if (eventsLength == 3) { // V2 Unwrap
      // TODO: Check 2 contracts
      const secondEvent = events[1];
      const thirdEvent = events[2];
      if (firstEvent[EVENTFIELD_TYPE] == 1 && secondEvent[EVENTFIELD_TYPE] == 1 && thirdEvent[EVENTFIELD_TYPE] == 2) { // Transfer & Transfer & PunkTransfer
        return [ 11, thirdEvent[4], thirdEvent[5] ]; // [ Unwrap(V2), owner, punkId ]
      }
    }

  }
  return [undefined];
}
