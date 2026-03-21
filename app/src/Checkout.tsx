import { useState } from "react";
import { Bag, BagItemData } from "./App";
import "./Checkout.css";
import { NavBar } from "./components/NavBar";
import { Link } from "react-router-dom";
import { DeliveryForm, DeliveryDetails } from "./components/DeliveryForm";
import { baseGoerli } from "viem/chains";

type CheckOutProps = {
  bag: Bag;
  setBag: React.Dispatch<React.SetStateAction<Bag>>;
  HashFitKeyData: {
    keys: { mythic: number; legendary: number };
    set: React.Dispatch<
      React.SetStateAction<{
        legendary: number;
        mythic: number;
      }>
    >;
  };
};

type SaleItem = {
  itemId: number;
  amount: number;
};

type RouterInput = {
  gen: string;
  items: SaleItem[];
  proof: [];
};

type KeysRouterInput = {
  gen: string;
  item: SaleItem;
  proof: [];
};
export function Checkout(props: CheckOutProps) {
  const [totalKeyUsed, settotalKeyUsed] = useState(0);
  const [showDeliveryForm, setShowDeliveryForm] = useState(false);
  const [deliveryDetails, setDeliveryDetails] =
    useState<DeliveryDetails | null>(null);

  const handleDeliverySubmit = (details: DeliveryDetails) => {
    setDeliveryDetails(details);
    // Here you would typically proceed to payment processing
    console.log("Delivery details submitted:", details);
    alert("Delivery details saved! Proceeding to payment...");
    const items = Array.from(props.bag.items.values());
    const paidRouterInput = new Map<string, RouterInput>();
    const keysRouterInput = [];
    for (const i of items) {
      const saleItem: SaleItem = {
        itemId: i.itemId,
        amount: i.amount,
      };
      // Route purchases involving keys to the key router
      if ((i.keysUsed as number) > 0) {
        keysRouterInput.push({
          gen: i.gen,
          item: saleItem,
          proof: [],
        });
        // Route paid purchases to paid router
      } else {
        if (paidRouterInput.has(i.gen)) {
          const oldItems = paidRouterInput.get(i.gen)?.items as SaleItem[];
          oldItems.push(saleItem);
          paidRouterInput.set(i.gen, {
            gen: i.gen,
            items: oldItems,
            proof: [],
          });
        } else {
          paidRouterInput.set(i.gen, {
            gen: i.gen,
            items: [saleItem],
            proof: [],
          });
        }
      }
    }

    // props.bag.items.clear();
    console.log(Array.from(paidRouterInput.values()));
    console.log(keysRouterInput);
  };

  return (
    <>
      <NavBar for="shop" bag={props.bag} keys={props.HashFitKeyData.keys} />
      <div className="items-checkout">
        <div className="item-box">
          <h3 className="bag-title">Bag({props.bag.items.size})</h3>
          {Array.from(props.bag.items.keys()).map((key: string) => {
            const getSubTotal = (bagItems: Map<string, BagItemData>) => {
              let total = 0;
              bagItems.forEach((item) => {
                const keysUsed = item.keysUsed ?? 0;
                total += item.price * Math.max(0, item.amount - keysUsed);
              });
              return total;
            };

            const add = () => {
              const oldBag = new Map(props.bag.items);
              const currentItem = oldBag.get(key);
              if (!currentItem) return;

              const newAmount = currentItem.amount + 1;
              oldBag.set(key, {
                ...currentItem,
                amount: newAmount,
                keysUsed: Math.min(currentItem.keysUsed ?? 0, newAmount),
              });

              props.setBag({
                items: oldBag,
                subTotal: getSubTotal(oldBag),
              });
            };

            const remove = () => {
              const oldBag = new Map(props.bag.items);
              const currentItem = oldBag.get(key);
              if (!currentItem) return;

              const newAmount = currentItem.amount - 1;
              if (newAmount <= 0) {
                oldBag.delete(key);
                props.setBag({
                  items: oldBag,
                  subTotal: getSubTotal(oldBag),
                });
                return;
              }

              oldBag.set(key, {
                ...currentItem,
                amount: newAmount,
                keysUsed: Math.min(currentItem.keysUsed ?? 0, newAmount),
              });

              props.setBag({
                items: oldBag,
                subTotal: getSubTotal(oldBag),
              });
            };

            const useKey = () => {
              const oldBag = new Map(props.bag.items);
              const currentItem = oldBag.get(key);
              if (!currentItem) return;

              const priceInKeys = currentItem.priceInKeys ?? 0;
              if (priceInKeys <= 0) return;

              const keysAlreadyUsed = currentItem.keysUsed ?? 0;
              const remaining = currentItem.amount - keysAlreadyUsed;
              if (remaining <= 0) return;

              const requiredKeys = remaining * priceInKeys;
              if (props.HashFitKeyData.keys.mythic < requiredKeys) return;

              oldBag.set(key, {
                ...currentItem,
                keysUsed: currentItem.amount,
              });

              props.HashFitKeyData.set({
                ...props.HashFitKeyData.keys,
                mythic: props.HashFitKeyData.keys.mythic - requiredKeys,
              });

              props.setBag({
                items: oldBag,
                subTotal: getSubTotal(oldBag),
              });

              settotalKeyUsed(totalKeyUsed + requiredKeys);
            };

            ///
            return (
              <div className="item">
                <div className="name-image">
                  <img
                    className="c-item-image"
                    src={props.bag.items.get(key)?.image}
                  />
                  <h3>{props.bag.items.get(key)?.name}</h3>
                  <span className="c-price-sec">
                    <img
                      className="usdc"
                      src="/assests/currency/usdc.svg"
                      alt="USDC"
                    />
                    {props.bag.items.get(key)?.price}
                    {(props.bag.items.get(key)?.priceInKeys as number) > 0 && (
                      <>
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
                        {props.bag.items.get(key)?.priceInKeys}
                      </>
                    )}
                  </span>
                </div>

                <div className="amount-sec">
                  {(() => {
                    const item = props.bag.items.get(key);
                    const priceInKeys = item?.priceInKeys ?? 0;
                    const keysUsed = item?.keysUsed ?? 0;
                    const remaining = (item?.amount ?? 0) - keysUsed;
                    const needed = remaining * priceInKeys;
                    return (
                      priceInKeys > 0 &&
                      remaining > 0 &&
                      needed <= props.HashFitKeyData.keys.mythic && (
                        <button className="use-key" onClick={useKey}>
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
                          <span className="key-amount">Use {needed} keys</span>
                        </button>
                      )
                    );
                  })()}
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
          <h4 className="checkout-heading"> BAG SUMMARY </h4>
          <span className="subtotal">
            Subtotal{" "}
            <span>
              <img
                className="usdc"
                src="/assests/currency/usdc.svg"
                alt="USDC"
              />{" "}
              <span className="sub-total-value">{props.bag.subTotal}</span>
              <span>
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
                <span className="sub-total-value">{totalKeyUsed}</span>
              </span>
            </span>
          </span>
          <button
            onClick={() => setShowDeliveryForm(true)}
            className="checkout-button"
            disabled={props.bag.items.size === 0}
          >
            Checkout{" "}
            <span>
              {" "}
              <img
                className="usdc"
                src="/assests/currency/usdc.svg"
                alt="USDC"
              />{" "}
            </span>
            {props.bag.subTotal}
          </button>
        </div>
      </div>

      {showDeliveryForm && (
        <DeliveryForm
          onSubmit={handleDeliverySubmit}
          initialDetails={deliveryDetails || undefined}
        />
      )}
    </>
  );
}
