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
    const newBag: Bag = {
      items: oldBag,
      subTotal: props.bag.current.subTotal + props.details.price,
    };
    newBag.items.set(props.details.key, {
      ...props.details,
      amount: oldItemAmount !== undefined ? oldItemAmount + 1 : 1,
    });
    props.bag.setBag(newBag);
  };

  return (
    <div className="card">
      <Link to="/">
        <img className="item-image" src={props.details.image} />
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
              <p className="price"> {props.details.price} </p>
              <div className="currencies">
                <img className="usdt" src={usdt.image} />
                <img className="usdc" src={usdc.image} />
              </div>
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
