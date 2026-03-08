import { Link } from "react-router-dom";
import "./ItemCard.css";

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
  //   id: number;
  gen: string;
};

export function ItemCard(props: CardProps) {
  return (
    <Link to="/">
      <div className="card">
        <img className="item-image" src={props.image} />
        <div className="item-details">
          <p className="name-section"> {props.name} </p>
          <div className="price-section">
            <div className="actual">
              {props.discount > 0 && (
                <div className="discount">
                  <p className="old-price">
                    {(
                      (props.price * 100) /
                      (100 - props.discount / 100)
                    ).toFixed(2)}
                  </p>
                  <p className="discount-p">-{props.discount / 100}%</p>
                </div>
              )}
              <div className="actual-price">
                <p className="price"> {props.price} </p>
                <div className="currencies">
                  <img className="usdt" src={usdt.image} />
                  <img className="usdc" src={usdc.image} />
                </div>
              </div>
            </div>
          </div>
          <button className="add">
            Add to bag
            <svg
              fill="#c9c9c9"
              viewBox="0 0 24 24"
              width="25px"
              height="18px"
              xmlns="http://www.w3.org/2000/svg"
              stroke="#c9c9c9"
            >
              <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
              <g
                id="SVGRepo_tracerCarrier"
                stroke-linecap="round"
                stroke-linejoin="round"
              ></g>
              <g id="SVGRepo_iconCarrier">
                <path d="M8,3V7H21l-2,7H8v2H18a1,1,0,0,1,0,2H7a1,1,0,0,1-1-1V4H4A1,1,0,0,1,4,2H7A1,1,0,0,1,8,3ZM6,20.5A1.5,1.5,0,1,0,7.5,19,1.5,1.5,0,0,0,6,20.5Zm9,0A1.5,1.5,0,1,0,16.5,19,1.5,1.5,0,0,0,15,20.5Z"></path>
              </g>
            </svg>
          </button>
          <div className="contract-details">
            <p className="ca">
              {props.gen.slice(0, 8)}...{props.gen.slice(32, props.gen.length)}
            </p>
          </div>
        </div>
      </div>
    </Link>
  );
}
