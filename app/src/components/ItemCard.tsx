import { Link } from "react-router-dom";
import "./ItemCard.css";
import { useState } from "react";
import { Bag, BagItemData } from "../App";
type Currency = {
  name: "USDT" | "USDC";
  image: string;
};

const usdt = {
  name: "USDT",
  image: "/assests/currency/usdt.svg",
};

const usdc = {
  name: "USDT",
  image: "/assests/currency/usdc.svg",
};

export type CardProps = {
  name: string;
  image: string;
  price: number;
  discount: number;
  key: string;
  gen: string;
  itemId: number;
  priceInKeys: number;
};

type BagItem = {
  details: BagItemData;
  bag: {
    current: Bag;
    setBag: React.Dispatch<React.SetStateAction<Bag>>;
  };
};

export function ItemCard(props: BagItem) {
  const add = () => {
    const oldBag = props.bag.current.items;
    const oldItemAmount = oldBag.get(props.details.key)?.amount;
    const newAmount = oldItemAmount !== undefined ? oldItemAmount + 1 : 1;
    const current = oldBag.get(props.details.key);
    const newBag: Bag = {
      items: oldBag,
      subTotal: props.bag.current.subTotal + props.details.price,
    };
    newBag.items.set(props.details.key, {
      ...props.details,
      amount: newAmount,
      keysUsed: Math.min(current?.keysUsed ?? 0, newAmount),
    });
    props.bag.setBag(newBag);
  };

  return (
    <div className="card">
      <Link to="/">
        <img
          className="item-image"
          src={props.details.image}
          alt={props.details.name}
        />
      </Link>
      <div className="item-details">
        <p className="name-section"> {props.details.name} </p>
        <div className="price-section">
          <div className="actual">
            {props.details.discount > 0 && (
              <div className="discount">
                <p className="old-price">
                  {(
                    (props.details.price * 100) /
                    (100 - props.details.discount / 100)
                  ).toFixed(2)}
                </p>
                <p className="discount-p">-{props.details.discount / 100}%</p>
              </div>
            )}
            <div className="actual-price">
              <div className="currencies">
                <p>{props.details.price}</p>
                <svg
                  width="15px"
                  height="15px"
                  viewBox="0 0 32 32"
                  xmlns="http://www.w3.org/2000/svg"
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
                    <g fill="none">
                      {" "}
                      <circle
                        fill="#ff00bb"
                        cx="16"
                        cy="16"
                        r="16"
                      ></circle>{" "}
                      <g fill="#FFF">
                        {" "}
                        <path d="M20.022 18.124c0-2.124-1.28-2.852-3.84-3.156-1.828-.243-2.193-.728-2.193-1.578 0-.85.61-1.396 1.828-1.396 1.097 0 1.707.364 2.011 1.275a.458.458 0 00.427.303h.975a.416.416 0 00.427-.425v-.06a3.04 3.04 0 00-2.743-2.489V9.142c0-.243-.183-.425-.487-.486h-.915c-.243 0-.426.182-.487.486v1.396c-1.829.242-2.986 1.456-2.986 2.974 0 2.002 1.218 2.791 3.778 3.095 1.707.303 2.255.668 2.255 1.639 0 .97-.853 1.638-2.011 1.638-1.585 0-2.133-.667-2.316-1.578-.06-.242-.244-.364-.427-.364h-1.036a.416.416 0 00-.426.425v.06c.243 1.518 1.219 2.61 3.23 2.914v1.457c0 .242.183.425.487.485h.915c.243 0 .426-.182.487-.485V21.34c1.829-.303 3.047-1.578 3.047-3.217z"></path>{" "}
                        <path d="M12.892 24.497c-4.754-1.7-7.192-6.98-5.424-11.653.914-2.55 2.925-4.491 5.424-5.402.244-.121.365-.303.365-.607v-.85c0-.242-.121-.424-.365-.485-.061 0-.183 0-.244.06a10.895 10.895 0 00-7.13 13.717c1.096 3.4 3.717 6.01 7.13 7.102.244.121.488 0 .548-.243.061-.06.061-.122.061-.243v-.85c0-.182-.182-.424-.365-.546zm6.46-18.936c-.244-.122-.488 0-.548.242-.061.061-.061.122-.061.243v.85c0 .243.182.485.365.607 4.754 1.7 7.192 6.98 5.424 11.653-.914 2.55-2.925 4.491-5.424 5.402-.244.121-.365.303-.365.607v.85c0 .242.121.424.365.485.061 0 .183 0 .244-.06a10.895 10.895 0 007.13-13.717c-1.096-3.46-3.778-6.07-7.13-7.162z"></path>{" "}
                      </g>{" "}
                    </g>{" "}
                  </g>
                </svg>
              </div>
              {(props.details.priceInKeys as number) > 0 && (
                <div className="price-in-keys">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    x="0px"
                    y="0px"
                    width="15px"
                    height="15px"
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
                  <span className="key-amount">
                    {props.details.priceInKeys}
                  </span>
                </div>
              )}
            </div>
          </div>
        </div>
        <button className="add" onClick={add}>
          Add to bag
        </button>
      </div>
    </div>
  );
}
