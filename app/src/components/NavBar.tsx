import { Link } from "react-router-dom";
import { HomeNav } from "./HomeNav";
import { ShopNav } from "./ShopNav";
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
  keys: { legendary: number; mythic: number };
};

export function NavBar(props: NavBarProps) {
  return (
    <div className="nav-bar">
      {props.for === "home" && <HomeNav />}
      {props.for === "shop" && <ShopNav bag={props.bag} keys={props.keys} />}
    </div>
  );
}
