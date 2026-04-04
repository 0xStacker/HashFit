import { Link } from "react-router-dom";
import { HomeNav } from "./HomeNav";
import { ShopNav } from "./ShopNav";
import { useEffect } from "react";
import { BrowserProvider } from "ethers";
import { Bag } from "../App";
import "./NavBar.css";
import { CardProps } from "./ItemCard";

export function Logo() {
  return (
    <Link to="/">
      <img src="/HashfitLogo.svg" className="logo-image" alt="HashFit Logo" />
    </Link>
  );
}

type NavItemProps = {
  text: string;
  ref: string;
  id: string;
};

export function NavItem(props: NavItemProps) {
  return (
    <>
      <Link className="nav-item" id={props.id} to={props.ref}>
        {props.text}
      </Link>
    </>
  );
}

type NavBarProps = {
  for: "shop" | "home";
  bag: Bag;
  HashFitKeyData?: {
    keys: {
      legendary: number;
      mythic: number;
    };
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
  wallet?: {
    provider: BrowserProvider | null;
    address: string | null;
    connect: () => void;
  };
};

export function NavBar(props: NavBarProps) {
  useEffect(() => {
    if (props.wallet?.address) {
      props.HashFitKeyData?.load(props.wallet.provider, props.wallet.address);
      console.log("address", props.wallet.address);
    }
  }, [props.wallet?.address]);

  return (
    <div className="nav-bar">
      {props.for === "home" && <HomeNav />}
      {props.for === "shop" && (
        <ShopNav
          bag={props.bag}
          keys={
            props.HashFitKeyData?.keys as { legendary: number; mythic: number }
          }
          wallet={{
            address: (
              props.wallet as { address: string | null; connect: () => void }
            ).address,
            connect: (
              props.wallet as { address: string | null; connect: () => void }
            ).connect,
          }}
        />
      )}
    </div>
  );
}
