import { NavBar } from "./components/NavBar";
import { Footer } from "./components/Footer";
import { DropsPage } from "./components/DropsPage";
import { useEffect } from "react";
import { Bag } from "./App";
import { CardProps } from "./components/ItemCard";
import { BrowserProvider, ethers, JsonRpcSigner } from "ethers";

type ShopProps = {
  bag: Bag;
  setBag: React.Dispatch<React.SetStateAction<Bag>>;
  HashFitKeyData: {
    keys: { legendary: number; mythic: number };
    set: React.Dispatch<
      React.SetStateAction<{
        legendary: number;
        mythic: number;
      }>
    >;
    load: (
      provider: BrowserProvider | null,
      address: string | null,
    ) => Promise<void>;
  };

  wallet: {
    provider: BrowserProvider | null;
    address: string | null;
    signer: JsonRpcSigner | null;
    connect: () => void;
  };
};
export function Shop(props: ShopProps) {
  return (
    <>
      <NavBar
        for="shop"
        bag={props.bag}
        HashFitKeyData={props.HashFitKeyData}
        wallet={props.wallet}
      />
      <DropsPage
        bag={{ current: props.bag, setBag: props.setBag }}
        wallet={props.wallet}
      />
      <Footer />
    </>
  );
}
