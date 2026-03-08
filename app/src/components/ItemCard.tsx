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
              <p className="price"> {props.price} </p>
              <div className="currencies">
                <img className="usdt" src={usdt.image} />
                <img className="usdc" src={usdc.image} />
              </div>
            </div>
            {props.discount && (
              <div className="discount">
                <p className="old-price">
                  {((props.price * 100) / (100 - props.discount / 100)).toFixed(
                    2,
                  )}
                </p>
                <p className="discount-p"> {props.discount / 100}% Off</p>
              </div>
            )}
          </div>

          <div className="contract-details">
            <p className="ca">{props.gen}</p>
          </div>
        </div>
      </div>
    </Link>
  );
}
