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
                <img className="usdt" src={usdt.image} alt="USDT" />
                <img className="usdc" src={usdc.image} alt="USDC" />
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
