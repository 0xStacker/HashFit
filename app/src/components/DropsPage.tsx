import { Drop, DropProps } from "./Drop";
import { Link } from "react-router-dom";
import { ItemCard, CardProps } from "./ItemCard";

import "./DropsPage.css";
type Drop = {
  contract: string;
  coverImg: string;
  coverVideo: string;
};

const today = new Date();

const drops: DropProps[] = [
  {
    name: "Genesis",
    totalItems: 50,
    launchDate: today.toLocaleString("default", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }),
    id: "drop1",
    coverImg: "/assests/background/cp2.png",
    coverVideo: "",
  },
  {
    name: "Cypher X",
    totalItems: 100,
    launchDate: today.toLocaleString("default", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }),
    id: "drop1",
    coverImg: "/assests/background/cp3.png",
    coverVideo: "",
  },
  {
    name: " X256",
    launchDate: today.toLocaleString("default", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }),
    totalItems: 25,
    id: "drop1",
    coverImg: "",
    coverVideo: "/assests/background/cp5.mp4",
  },
  {
    name: "X-100",
    launchDate: today.toLocaleString("default", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }),
    totalItems: 90,
    id: "drop1",
    coverImg: "/assests/background/cp5.png",
    coverVideo: "",
  },
];

const items: CardProps[] = [
  {
    name: "Genesis M-50",
    image: "/assests/background/bg2.png",
    price: 25,
    discount: 0,
    gen: "0x60fC61c50186a4012AE9153c47e2643544cdE30C",
  },
  {
    name: "Genesis M-10",
    image: "/assests/background/bg3.png",
    price: 25,
    discount: 0,
    gen: "0x9661A6F57F5Bc7bA370e01C8E1f2BEdF185e06c4",
  },
  {
    name: "Cypher-X",
    image: "/assests/background/bg5.png",
    price: 100,
    discount: 500,
    gen: "0x1703b33d2e6815baf2d69d5e74d37b8da0fc023a",
  },

  {
    name: "Genesis M-1",
    image: "/assests/background/bg4.png",
    price: 25,
    discount: 0,
    gen: "0x52346350618d1Ff566511385BA79e9875c0955Ab",
  },
];

function LatestDrop() {
  return (
    <div className="latest-drops">
      <h3>
        New
        <span>
          <svg
            version="1.1"
            id="_x32_"
            xmlns="http://www.w3.org/2000/svg"
            width="17px"
            height="17px"
            viewBox="0 0 512 512"
            fill="#000000"
          >
            <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
            <g
              id="SVGRepo_tracerCarrier"
              stroke-linecap="round"
              stroke-linejoin="round"
            ></g>
            <g id="SVGRepo_iconCarrier">
              {" "}
              <g>
                {" "}
                <path d="M480.013,31.996c-133.453-70.359-271.75-15.094-360.016,73.172C39.606,185.574,10.044,341.339,56.278,419.37 l-56.281,56.281l36.359,36.344l56.281-56.266c78.031,46.219,233.797,16.672,314.188-63.718 C495.106,303.746,550.372,165.433,480.013,31.996z M421.685,227.417l-107.656-2.516l-81.641,81.641l123.031,3.984l-1.234,38.063 l-158.719-5.109l-64.188,64.172l-26.922-26.922l64.172-64.188l-5.109-158.719l38.063-1.234l3.969,123.031l81.641-81.641 l-2.5-107.656l38.078-0.875l1.656,71.297l70.859-70.859l26.938,26.922l-70.859,70.875l71.313,1.656L421.685,227.417z"></path>{" "}
              </g>{" "}
            </g>
          </svg>
        </span>
      </h3>
      <span>Shop our most recent drops!</span>
      <div className="drops-container">
        {drops.map((drop) => {
          return (
            <Drop
              name={drop.name}
              launchDate={drop.launchDate}
              totalItems={drop.totalItems}
              id={drop.id}
              coverImg={drop.coverImg}
              coverVideo={drop.coverVideo}
            ></Drop>
          );
        })}
        <Link className="view-all" to="/">
          View all
        </Link>
      </div>
    </div>
  );
}

function Market() {
  return (
    <div className="market">
      <h3>Market</h3>
      <input className="market-search" placeholder="Search by items" />
      <button className="filter">
        <svg
          viewBox="0 0 16 16"
          width="15px"
          height="15px"
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
            <path d="M0 3H16V1H0V3Z" fill="#000000"></path>{" "}
            <path d="M2 7H14V5H2V7Z" fill="#000000"></path>{" "}
            <path d="M4 11H12V9H4V11Z" fill="#000000"></path>{" "}
            <path d="M10 15H6V13H10V15Z" fill="#000000"></path>{" "}
          </g>
        </svg>
      </button>
      <svg
        className="searchIcon"
        viewBox="0 0 24 24"
        width="20px"
        height="20px"
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
            d="M15.7955 15.8111L21 21M18 10.5C18 14.6421 14.6421 18 10.5 18C6.35786 18 3 14.6421 3 10.5C3 6.35786 6.35786 3 10.5 3C14.6421 3 18 6.35786 18 10.5Z"
            stroke="#c7c7c7"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          ></path>{" "}
        </g>
      </svg>

      <div className="item-card-container">
        {items.map((item) => {
          return (
            <ItemCard
              name={item.name}
              image={item.image}
              price={item.price}
              gen={item.gen}
              discount={item.discount}
            />
          );
        })}
      </div>
    </div>
  );
}

export function DropsPage() {
  return (
    <>
      <LatestDrop />
      <Market />
    </>
  );
}
