import { Home } from "./HomePage";
import { Shop } from "./Shop";
import { useEffect, useState } from "react";
import { Routes, Route } from "react-router-dom";
import { Checkout } from "./Checkout";
import { ExclusiveDropPage } from "./components/ExclusiveDropPage";
import { DropDetailPage } from "./components/DropDetailPage";
import { NormalDropPage } from "./components/NormalDropPage";
import { BrowserProvider, ethers, JsonRpcSigner } from "ethers";
import { useWallet } from "./hooks/Wallet";

// Full details of an item
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

// Wallet config
type Wallet = {
  provider: BrowserProvider | null;
  address: string | null;
  getSigner: JsonRpcSigner | null;
};

// Global bag
const shopBag: Bag = {
  items: new Map<string, BagItemData>(),
  subTotal: 0,
};

// Fetch HashFit Keys held by user
async function fetchKeys(
  provider: BrowserProvider | null,
  address: string | null,
) {
  const mythicAddress = "0x1e974e3EC9D47E8552dCA62C408a0b1d0f5b891c";
  const legendaryAddress = "0xC4fE20e8EcD1aF51b4672671a429E2Ee56dc1650";

  const keysABI = [
    "function balanceOf(address) view returns (uint256)",
    "function setApprovalForAll(address operator, bool approved)",
  ];

  if (!provider) {
    return { mythic: 0, legendary: 0 };
  }

  const mythicKeyContract = new ethers.Contract(
    mythicAddress,
    keysABI,
    provider,
  );
  let mythicKeys = 0;
  let leggyKeys = 0;

  try {
    mythicKeys = await mythicKeyContract.balanceOf(address);
  } catch (e: any) {
    console.log(e);
  }

  const legendaryKeyContract = new ethers.Contract(
    legendaryAddress,
    keysABI,
    provider,
  );
  try {
    leggyKeys = await legendaryKeyContract.balanceOf(address);
  } catch (e: any) {
    console.log(e);
  }

  return { mythic: mythicKeys, legendary: leggyKeys };
}

export function App() {
  const { provider, address, signer, connect } = useWallet();
  const [keys, setKeys] = useState({ legendary: 0, mythic: 0 });
  const [bag, setBag] = useState(shopBag);

  async function loadKeys(
    provider: BrowserProvider | null,
    address: string | null,
  ) {
    const keys = await fetchKeys(provider, address);
    setKeys({ legendary: keys.legendary, mythic: keys.mythic });
  }

  const HashFitKeys = {
    keys: keys,
    load: loadKeys,
    set: setKeys,
  };

  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route
        path="/shop/drop"
        element={
          <Shop
            bag={bag}
            setBag={setBag}
            HashFitKeyData={HashFitKeys}
            wallet={{
              provider: provider,
              address: address,
              signer: signer,
              connect: connect,
            }}
          />
        }
      />
      <Route
        path="/exclusive"
        element={
          <ExclusiveDropPage
            bag={bag}
            setBag={setBag}
            HashFitKeyData={HashFitKeys}
            wallet={{
              provider: provider,
              address: address,
              connect: connect,
            }}
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
            wallet={{ provider: provider, address: address, connect: connect }}
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
            wallet={{ provider: provider, address: address, connect: connect }}
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
            wallet={{
              provider: provider,
              address: address,
              signer: signer,
              connect: connect,
            }}
          />
        }
      ></Route>
    </Routes>
  );
}
