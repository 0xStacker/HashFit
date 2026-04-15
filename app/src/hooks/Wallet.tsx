import { useState, useEffect } from "react";
import { ethers, BrowserProvider, JsonRpcSigner } from "ethers";

const WalletSetupError = new Error("Install Metamask Wallet");

export function useWallet() {
  const [provider, setProvider] = useState<BrowserProvider | null>(null);
  const [address, setAddress] = useState("");
  const [signer, setSigner] = useState<JsonRpcSigner | null>(null);

  function initProvider() {
    if (window.ethereum) {
      try {
        setProvider(new BrowserProvider(window.ethereum));
      } catch {
        alert("Connection rejected");
      }
    } else {
      alert("Install Metamask");
    }
  }

  async function connect() {
    if (provider) {
      const accounts = await provider.send("eth_accounts", []);
      const network = await provider.getNetwork();
      console.log(network.chainId);
      if (network.chainId !== BigInt("31337")) {
        await window.ethereum.request({
          method: "wwallet_switchEthereumChain",
          params: [{ chainId: "31337" }],
        });
      }
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
    if (provider) {
      window.ethereum.on("accountsChanged", (accounts: string[]) => {
        connect();
      });

      // return window.ethereum.off("accountsChanged", (accounts: string[]) => {
      //   setAddress(accounts[0]);
      // });
    }
  }, []);

  return { provider, address, signer, connect };
}
