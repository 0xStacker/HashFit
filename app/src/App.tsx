import { Home } from "./HomePage";
import { Shop } from "./Shop";
import { useEffect, useState } from "react";
import { Routes, Route } from "react-router-dom";
import { Checkout } from "./Checkout";
import { ExclusiveDropPage } from "./components/ExclusiveDropPage";
import { DropDetailPage } from "./components/DropDetailPage";
import { NormalDropPage } from "./components/NormalDropPage";
import { BrowserProvider, ethers } from "ethers";

export type BagItemData = {
  name: string;
  image: string;
  price: number;
  discount: number;
  key: string;
  gen: string;
  amount: number;
  itemId: number;
  priceInKeys?: number;
  keysUsed?: number;
};

export type Bag = {
  items: Map<string, BagItemData>;
  subTotal: number;
};

type Wallet = {
  provider: ethers.BrowserProvider;
  signer: ethers.JsonRpcSigner | undefined
}

const mythicAddress = "Mythic";
const legendaryAddress = "Legendary";

const keysABI = [
  "function balanceOf(address) returns (uint256)",
  "function setApprovalForAll(address operator, bool approved)",
];

async function fetchDrops() {}

const shopBag: Bag = {
  items: new Map<string, BagItemData>(),
  subTotal: 0,
};


// Set provider
const provider = new BrowserProvider((window as any).ethereum);
const wallet: Wallet = {provider: provider,
  signer: undefined
}


// Set signer
async function walletSetup() {
  const signer = await provider.getSigner();
  wallet.signer = signer
}

// Fetch keys held by signer
async function fetchKeys() {
  const acc = await provider.send("eth_accounts", []);
  const mythicKeyContract = new ethers.Contract(
    mythicAddress,
    keysABI,
    provider,
  );
  const mythicKeys = await mythicKeyContract.balanceOf(acc[0]);
  const legendaryKeyContract = new ethers.Contract(
    legendaryAddress,
    keysABI,
    provider,
  );
  const leggyKeys = await legendaryKeyContract.balanceOf(acc[0]);
  console.log(mythicKeys);
  userKeys.legendary = leggyKeys
  userKeys.mythic = mythicKeys
}


const userKeys = {legendary: 0,
  mythic: 0
}


export function App() {
  useEffect(
    () => {
      async function _fetchKeys(){
        await walletSetup()
        await fetchKeys()
      }
      _fetchKeys()
    }
  )

  const [keys, setKeys] = useState(userKeys);
  const [bag, setBag] = useState(shopBag);

  const HashFitKeys = {
    keys: keys,
    set: setKeys,
  };

  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route
        path="/shop/drop"
        element={
          <Shop bag={bag} setBag={setBag} HashFitKeyData={HashFitKeys} />
        }
      />
      <Route
        path="/exclusive"
        element={
          <ExclusiveDropPage
            bag={bag}
            setBag={setBag}
            HashFitKeyData={HashFitKeys}
          />
        }
      />
      <Route
        path="/exclusive/:id"
        element={
          <DropDetailPage
            bag={bag}
            setBag={setBag}
            HashFitKeyData={HashFitKeys}
          />
        }
      />

      <Route
        path="/drops/:id"
        element={
          <NormalDropPage
            bag={bag}
            setBag={setBag}
            HashFitKeyData={HashFitKeys}
          />
        }
      />
      <Route
        path="/bag"
        element={
          <Checkout
            bag={bag}
            setBag={setBag}
            HashFitKeyData={HashFitKeys}
            wallet={wallet}
          />
        }
      ></Route>
    </Routes>
  );
}
