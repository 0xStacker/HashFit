import { useState, useEffect } from "react";
import { ethers, BrowserProvider, JsonRpcSigner } from "ethers";

const WalletSetupError = new Error("Install Metamask Wallet");

export function useWallet() {
  const [provider, setProvider] = useState<BrowserProvider | null>(null);
  const [address, setAddress] = useState("");
  const [signer, setSigner] = useState<JsonRpcSigner | null>(null);

  function initProvider() {
    if (window.ethereum) {
      setProvider(new BrowserProvider(window.ethereum));
    } else {
      alert("Install Metamask");
    }
  }

  async function connect() {
    if (provider) {
      const accounts = await provider.send("eth_accounts", []);
      if (accounts.length > 0) {
        setAddress(accounts[0]);
      } else {
        const accounts = await provider.send("eth_requestAccounts", []);
        setAddress(accounts[0]);
      }
      const _signer = await provider.getSigner();
      setSigner(_signer);
    } else {
      initProvider();
    }
  }

  useEffect(() => {
    initProvider();
    window.ethereum.on("accountsChanged", (accounts: string[]) => {
      connect();
    });

    // return window.ethereum.off("accountsChanged", (accounts: string[]) => {
    //   setAddress(accounts[0]);
    // });
  }, []);

  return { provider, address, signer, connect };
}
