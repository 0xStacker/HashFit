import { Link } from "react-router-dom";
import { HomeNav } from "./HomeNav";
import { ShopNav } from "./ShopNav";
import "./NavBar.css";

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
};

export function NavBar(props: NavBarProps) {
  return (
    <div className="nav-bar">
      {props.for === "home" && <HomeNav />}
      {props.for === "shop" && <ShopNav />}
    </div>
  );
}
