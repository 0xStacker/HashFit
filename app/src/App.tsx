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
  const mythicAddress = "0x712516e61C8B383dF4A63CFe83d7701Bce54B03e";
  const legendaryAddress = "0xbCF26943C0197d2eE0E5D05c716Be60cc2761508";

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
  const mythicKeys = await mythicKeyContract.balanceOf(address);
  const legendaryKeyContract = new ethers.Contract(
    legendaryAddress,
    keysABI,
    provider,
  );
  const leggyKeys = await legendaryKeyContract.balanceOf(address);
  return { mythic: mythicKeys, legendary: leggyKeys };
}

// // Fetch and organize items present in gen and exclusive drops from smartcontracts
// async function fetchDrops(provider: BrowserProvider | null) {
//   const genDrops: Record<string, { items: any[]; metadata: any }> = {};
//   const exclusiveDrops: Record<string, { items: any[]; metadata: any }> = {};

//   if (!provider) {
//     return { genDrops, exclusiveDrops };
//   }
//   const factoryAddress = "0x75537828f2ce51be7289709686A69CbFDbB714F1";
//   const factoryAbi = [
//     "function genDrops() view returns(address[])",
//     "function exclusiveDrops() view returns(address[])",
//   ];

//   const dropAbi = [
//     "function items() view returns((uint64 maxSupply, uint64 discount, uint64 priceInKeys, uint256 price, string name, string uri)[] memory)",
//     "function contractUri() view returns(string)",
//     "function name() view returns(string)",
//     "function startTime() view returns(uint256)",
//   ];

//   const factoryContract = new ethers.Contract(
//     factoryAddress,
//     factoryAbi,
//     provider,
//   );

//   const fetchedGenDrops: any[] = await factoryContract.genDrops();
//   const fetchedExclusiveDrops: any[] = await factoryContract.exclusiveDrops();
//   for (const i of fetchedGenDrops) {
//     const drop = new ethers.Contract(i, dropAbi, provider);
//     const dropItems = await drop.items();
//     console.log(dropItems.target);
//     const dropUri = await drop.contractUri();
//     const dropName = await drop.name();
//     const startTime = await drop.startTime();
//     console.log("unique", dropItems.length);
//     const metadata = {
//       name: dropName,
//       uri: dropUri,
//       startTime: startTime,
//       uniqueItems: dropItems.length,
//     };
//     genDrops[i] = { items: dropItems, metadata: metadata };
//   }

//   for (const i of fetchedExclusiveDrops) {
//     const drop = new ethers.Contract(i, dropAbi, provider);
//     const dropItems = await drop.items();
//     const metadata = await drop.metadata();
//     exclusiveDrops[i] = { items: dropItems, metadata: metadata };
//   }
//   console.log(genDrops);
//   console.log(exclusiveDrops);
//   return { genDrops, exclusiveDrops };
// }

export function App() {
  const { provider, address, signer, connect } = useWallet();
  const [keys, setKeys] = useState({ legendary: 0, mythic: 0 });
  const [bag, setBag] = useState(shopBag);
  // const [drops, setDrops] = useState({ genDrops: {}, exclusiveDrops: {} });

  // async function loadDrops() {
  //   try {
  //     const drops = await fetchDrops(provider);
  //     setDrops(drops);
  //   } catch {
  //     setDrops({ genDrops: {}, exclusiveDrops: {} });
  //   }
  // }
  // useEffect(() => {
  //   if (provider) {
  //     loadDrops();
  //   }
  // }, [provider]);

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
