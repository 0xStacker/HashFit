import { useState } from "react";
import { NavBar } from "./components/NavBar";
import { Footer } from "./components/Footer";
import { DropsPage } from "./components/DropsPage";
import { CardProps } from "./components/ItemCard";
import { Bag } from "./App";
import { BrowserProvider } from "ethers";
// import { Connection } from "./components/Connection";
// import { WalletOptions } from "./components/WalletOptions";
// import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
// import { WagmiProvider, useAccount } from "wagmi";
// import { config } from "./config";

// Set up a React Query client.
// const queryClient = new QueryClient();

// function ConnectWallet() {
//   const { isConnected } = useAccount();
//   if (isConnected) return <Connection />;
//   return <WalletOptions />;
// }

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
  };
};

export function Shop(props: ShopProps) {
  return (
    <>
      <NavBar for="shop" bag={props.bag} keys={props.HashFitKeyData.keys} />
      <DropsPage bag={{ current: props.bag, setBag: props.setBag }} />
      <Footer />
    </>
  );
}
