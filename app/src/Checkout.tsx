import { Bag, BagItemData } from "./App";
import "./Checkout.css";
import { NavBar } from "./components/NavBar";

type CheckOutProps = {
  bag: Bag;
  setBag: React.Dispatch<React.SetStateAction<Bag>>;
};

export function Checkout(props: CheckOutProps) {
  return (
    <>
      <NavBar for="shop" bag={props.bag} />
      <div className="items-checkout">
        <div className="item-box">
          <h3 className="bag-title">Bag({props.bag.items.size})</h3>
          {Array.from(props.bag.items.keys()).map((key: string) => {
            const add = () => {
              const oldBag = props.bag.items;
              const newBag: Bag = {
                items: oldBag,
                subTotal:
                  props.bag.subTotal + (oldBag.get(key)?.price as number),
              };

              if (newBag.items.has(key)) {
                newBag.items.set(key, {
                  ...(newBag.items.get(key) as BagItemData),
                  amount: (newBag.items.get(key)?.amount as number) + 1,
                });
              }

              props.setBag(newBag);
            };

            const remove = () => {
              const oldBag = props.bag.items;
              if ((oldBag.get(key)?.amount as number) - 1 === 0) {
                const newBag: Bag = {
                  items: oldBag,
                  subTotal:
                    props.bag.subTotal -
                    (props.bag.items.get(key)?.price as number),
                };
                newBag.items.delete(key);
                props.setBag(newBag);
                return;
              }

              const newBag: Bag = {
                items: oldBag,
                subTotal:
                  props.bag.subTotal -
                  (props.bag.items.get(key)?.price as number),
              };

              if (newBag.items.has(key)) {
                newBag.items.set(key, {
                  ...(newBag.items.get(key) as BagItemData),
                  amount: (newBag.items.get(key)?.amount as number) - 1,
                });
              }
              props.setBag(newBag);
            };
            return (
              <div className="item">
                <div className="name-image">
                  <img
                    className="c-item-image"
                    src={props.bag.items.get(key)?.image}
                  />
                  <h3>{props.bag.items.get(key)?.name}</h3>
                  <span className="c-price-sec">
                    <img className="usdc" src="/assests/currency/usdc.svg" />
                    {props.bag.items.get(key)?.price}
                  </span>
                </div>

                <div className="amount-sec">
                  <button className="increament" onClick={add}>
                    <svg
                      width="25px"
                      height="25px"
                      viewBox="0 0 24.00 24.00"
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
                          d="M5 15L10 9.84985C10.2563 9.57616 10.566 9.35814 10.9101 9.20898C11.2541 9.05983 11.625 8.98291 12 8.98291C12.375 8.98291 12.7459 9.05983 13.0899 9.20898C13.434 9.35814 13.7437 9.57616 14 9.84985L19 15"
                          stroke="#000000"
                          stroke-width="2.4"
                          stroke-linecap="round"
                          stroke-linejoin="round"
                        ></path>{" "}
                      </g>
                    </svg>
                  </button>
                  <p className="item-amount">
                    x{props.bag.items.get(key)?.amount}
                  </p>
                  <button className="decreament" onClick={remove}>
                    <svg
                      width="25px"
                      height="25px"
                      viewBox="0 0 24.00 24.00"
                      fill="none"
                      xmlns="http://www.w3.org/2000/svg"
                      transform="rotate(180)"
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
                          d="M5 15L10 9.84985C10.2563 9.57616 10.566 9.35814 10.9101 9.20898C11.2541 9.05983 11.625 8.98291 12 8.98291C12.375 8.98291 12.7459 9.05983 13.0899 9.20898C13.434 9.35814 13.7437 9.57616 14 9.84985L19 15"
                          stroke="#000000"
                          stroke-width="2.4"
                          stroke-linecap="round"
                          stroke-linejoin="round"
                        ></path>{" "}
                      </g>
                    </svg>
                  </button>
                </div>
              </div>
            );
          })}
        </div>

        <div className="checkout">
          <p> Bag Summary</p>
          <span>
            Subtotal{" "}
            <span>
              <img src="/assests/currency/usdc.svg"></img> {props.bag.subTotal}
            </span>
          </span>
        </div>
      </div>
    </>
  );
}
