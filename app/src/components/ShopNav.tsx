import { Logo } from "./NavBar";
import { NavItem } from "./NavBar";
import { Link } from "react-router";
import "./ShopNav.css";
import { Bag } from "../App";
import { WalletSection } from "./Wallet";

function CartSection(props: CartProps) {
  return (
    <div className="cart-section">
      <Link to="/keys">
        <div className="key-section">
          <div className="key" id="mythic">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              x="0px"
              y="0px"
              width="20"
              height="20"
              viewBox="0,0,256,256"
            >
              <g
                fill="none"
                fill-rule="nonzero"
                stroke="none"
                stroke-width="1"
                stroke-linecap="butt"
                stroke-linejoin="miter"
                stroke-miterlimit="10"
                stroke-dasharray=""
                stroke-dashoffset="0"
                font-family="none"
                font-weight="none"
                font-size="none"
                text-anchor="none"
              >
                <g transform="scale(5.33333,5.33333)">
                  <path
                    d="M30,41l-4,4h-4l-4,-4v-20h12v8l-2,2l2,2v2l-2,2l2,2z"
                    fill="#fa5252"
                  ></path>
                  <path
                    d="M38,7.8c-0.5,-1.8 -2,-3.1 -3.7,-3.6c-2.4,-0.5 -6.1,-1.2 -10.3,-1.2c-4.2,0 -7.9,0.7 -10.3,1.2c-1.7,0.5 -3.2,1.8 -3.7,3.6c-0.5,1.7 -1,4.1 -1,6.7c0,2.6 0.5,5 1,6.7c0.5,1.8 1.9,3.1 3.7,3.5c2.4,0.6 6.1,1.3 10.3,1.3c4.2,0 7.9,-0.7 10.3,-1.2c1.8,-0.4 3.2,-1.8 3.7,-3.5c0.5,-1.7 1,-4.1 1,-6.7c0,-2.7 -0.5,-5.1 -1,-6.8zM29,13h-10c-1.1,0 -2,-0.9 -2,-2v-2c0,-0.6 3.1,-1 7,-1c3.9,0 7,0.4 7,1v2c0,1.1 -0.9,2 -2,2z"
                    fill="#fa5252"
                  ></path>
                  <path d="M23,26h2v19h-2z" fill="#d68600"></path>
                </g>
              </g>
            </svg>
            <span className="key-amount">{props.keys.mythic}</span>
          </div>

          <div className="key" id="legendary">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              x="0px"
              y="0px"
              width="20"
              height="20"
              viewBox="0,0,256,256"
            >
              <g
                fill="none"
                fill-rule="nonzero"
                stroke="none"
                stroke-width="1"
                stroke-linecap="butt"
                stroke-linejoin="miter"
                stroke-miterlimit="10"
                stroke-dasharray=""
                stroke-dashoffset="0"
                font-family="none"
                font-weight="none"
                font-size="none"
                text-anchor="none"
              >
                <g transform="scale(5.33333,5.33333)">
                  <path
                    d="M30,41l-4,4h-4l-4,-4v-20h12v8l-2,2l2,2v2l-2,2l2,2z"
                    fill="#fcc419"
                  ></path>
                  <path
                    d="M38,7.8c-0.5,-1.8 -2,-3.1 -3.7,-3.6c-2.4,-0.5 -6.1,-1.2 -10.3,-1.2c-4.2,0 -7.9,0.7 -10.3,1.2c-1.7,0.5 -3.2,1.8 -3.7,3.6c-0.5,1.7 -1,4.1 -1,6.7c0,2.6 0.5,5 1,6.7c0.5,1.8 1.9,3.1 3.7,3.5c2.4,0.6 6.1,1.3 10.3,1.3c4.2,0 7.9,-0.7 10.3,-1.2c1.8,-0.4 3.2,-1.8 3.7,-3.5c0.5,-1.7 1,-4.1 1,-6.7c0,-2.7 -0.5,-5.1 -1,-6.8zM29,13h-10c-1.1,0 -2,-0.9 -2,-2v-2c0,-0.6 3.1,-1 7,-1c3.9,0 7,0.4 7,1v2c0,1.1 -0.9,2 -2,2z"
                    fill="#fcc419"
                  ></path>
                  <path d="M23,26h2v19h-2z" fill="#d68600"></path>
                </g>
              </g>
            </svg>
            <span className="key-amount">{props.keys.legendary}</span>
          </div>
        </div>
      </Link>
      <Link to="/bag">
        <div className="cart">
          <svg
            width="30"
            height="30"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
            <g
              id="SVGRepo_tracerCarrier"
              stroke-linecap="round"
              stroke-linejoin="round"
            ></g>
            <g id="SVGRepo_iconCarrier">
              {" "}
              <path
                fill-rule="evenodd"
                clip-rule="evenodd"
                d="M8.25013 6.01489C8.25003 6.00994 8.24998 6.00498 8.24998 6V5C8.24998 2.92893 9.92892 1.25 12 1.25C14.0711 1.25 15.75 2.92893 15.75 5V6C15.75 6.00498 15.7499 6.00994 15.7498 6.01489C17.0371 6.05353 17.8248 6.1924 18.4261 6.69147C19.2593 7.38295 19.4787 8.55339 19.9177 10.8943L20.6677 14.8943C21.2849 18.186 21.5934 19.8318 20.6937 20.9159C19.794 22 18.1195 22 14.7704 22H9.22954C5.88048 22 4.20595 22 3.30624 20.9159C2.40652 19.8318 2.71512 18.186 3.33231 14.8943L4.08231 10.8943C4.52122 8.55339 4.74068 7.38295 5.57386 6.69147C6.17521 6.1924 6.96287 6.05353 8.25013 6.01489ZM9.74998 5C9.74998 3.75736 10.7573 2.75 12 2.75C13.2426 2.75 14.25 3.75736 14.25 5V6C14.25 5.99999 14.25 6.00001 14.25 6C14.1747 5.99998 14.0982 6 14.0204 6H9.97954C9.90176 6 9.82525 6 9.74998 6.00002C9.74998 6.00002 9.74998 6.00003 9.74998 6.00002V5Z"
                fill="#000"
              ></path>{" "}
            </g>
          </svg>
          <span className="cart-amount">{props.bag.items.size}</span>
          <span className="bag-text">Bag</span>
        </div>
      </Link>
    </div>
  );
}

type NavProps = {
  bag: Bag;
  keys: { legendary: number; mythic: number };
  wallet: {
    address: string | null;
    connect: () => void;
  };
};

type CartProps = {
  bag: Bag;
  keys: { legendary: number; mythic: number };
};

export function ShopNav(props: NavProps) {
  return (
    <>
      <Logo />
      <div className="nav-items">
        <NavItem text="Home" id="home" ref="/" />
        <NavItem text="Drops" id="drop" ref="/shop/drop" />
        <NavItem text="Exclusives" id="exclusive" ref="/exclusive" />
      </div>
      <CartSection bag={props.bag} keys={props.keys} />
      <WalletSection
        address={props.wallet.address}
        connect={props.wallet.connect}
      />
    </>
  );
}
