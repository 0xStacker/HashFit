import { useEffect, useState } from "react";
import { Bag, BagItemData } from "./App";
import "./Checkout.css";
import { NavBar } from "./components/NavBar";
import { DeliveryForm, DeliveryDetails } from "./components/DeliveryForm";
import { BrowserProvider, ethers, JsonRpcSigner } from "ethers";

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
    load: (
      provider: BrowserProvider | null,
      address: string | null,
    ) => Promise<void>;
  };
  wallet: {
    provider: BrowserProvider | null;
    address: string | null;
    signer: JsonRpcSigner | null;
    connect: () => void;
  };
};

// The ERC-20 Contract ABI, which is a common contract interface
// for tokens (this is the Human-Readable ABI format)

const paidRouterAddress = "0x964a143aDfcaDE7352820Db06C3f243c43C3692E";
const keyRouterAddress = "0xCa8Ab90b5c6a9D8079149bDB86c51C89FE3d516c";
const mythicKeyAddress = "0x1e974e3EC9D47E8552dCA62C408a0b1d0f5b891c";
const usdtAddress = "0x7e45fBA8Cf17097dbe7DFC992713F82767b973F0";

const usdtAbi = ["function approve(address spender, uint256 value)"];

const mythicAbi = [
  "function setApprovalForAll(address operator, bool approved)",
];
const paidRouterAbi = [
  "function bundledPurchase((address gen, (uint8 itemId, uint64 amount)[] items, bytes32[] proof)[]) payable",
];

const keyRouterAbi = [
  "function bundledPurchase((address gen, (uint8 itemId, uint64 amount) item)[]) payable",
];

type Item = {
  itemId: number;
  amount: number;
};

type PaidRouterItems = {
  gen: string;
  items: [number, number][];
  proof: [];
};

type KeyRouterItems = {
  gen: string;
  item: [number, number];
};

export function Checkout(props: CheckOutProps) {
  const [totalKeyUsed, settotalKeyUsed] = useState(0);
  const [showDeliveryForm, setShowDeliveryForm] = useState(false);
  const [deliveryDetails, setDeliveryDetails] =
    useState<DeliveryDetails | null>(null);
  const [orderPlaced, setOrderPlaced] = useState(false);
  useEffect(() => {});
  const usdt = new ethers.Contract(usdtAddress, usdtAbi, props.wallet.provider);
  const mythic = new ethers.Contract(
    mythicKeyAddress,
    mythicAbi,
    props.wallet.provider,
  );

  const handleDeliverySubmit = async (details: DeliveryDetails) => {
    setDeliveryDetails(details);
    const paidRouterItems = new Map<string, PaidRouterItems>();
    const keyRouterItems: KeyRouterItems[] = [];
    Array.from(props.bag.items.values()).map((v: BagItemData) => {
      if ((v.keysUsed as number) > 0) {
        keyRouterItems.push({
          gen: v.gen,
          item: [v.itemId, v.amount],
        });
      } else {
        if (paidRouterItems.has(v.gen)) {
          (paidRouterItems.get(v.gen) as PaidRouterItems).items.push([
            v.itemId,
            v.amount,
          ]);
        } else {
          paidRouterItems.set(v.gen, {
            gen: v.gen,
            items: [[v.itemId, v.amount]],
            proof: [],
          });
        }
      }
      return;
    });

    const paidRouter = new ethers.Contract(
      paidRouterAddress,
      paidRouterAbi,
      props.wallet.provider,
    );

    const keyRouter = new ethers.Contract(
      keyRouterAddress,
      keyRouterAbi,
      props.wallet.provider,
    );

    const keyRouterWithSigner = keyRouter.connect(props.wallet.signer);

    const usdtWithSigner = usdt.connect(props.wallet.signer);
    const mythicWithSigner = mythic.connect(props.wallet.signer);
    const paidRouterWithSigner = paidRouter.connect(props.wallet.signer);

    // Submitting empty cart
    if (keyRouterItems.length < 1 && paidRouterItems.size < 1) {
      return;
    }

    let keyReceipt = 0;
    let paidReceipt = 0;

    // Parse paid cart items and send payment txn to blockchain
    if (paidRouterItems.size > 0) {
      // Approve USDT spending
      await (usdtWithSigner as any).approve(
        paidRouterAddress,
        ethers.parseEther(String(props.bag.subTotal)),
      );

      let data: [
        address: string,
        items: [number, number][],
        proof: string[],
      ][] = [];
      for (const i of Array.from(paidRouterItems.values())) {
        data.push([i.gen, i.items, i.proof]);
      }
      const paidPurchaseTxn = await (
        paidRouterWithSigner as any
      ).bundledPurchase(data);
      const txHash = await paidPurchaseTxn.wait();
      paidReceipt = txHash.status;
      console.log(paidReceipt);
    }

    // Parse purchases involving key usage and send payment txn to blockchain
    if (keyRouterItems.length > 0) {
      // Approve NFT spending
      await (mythicWithSigner as any).setApprovalForAll(keyRouterAddress, true);
      let keyQueryData: [address: string, items: [number, number]][] = [];
      for (const i of Array.from(keyRouterItems.values())) {
        keyQueryData.push([i.gen, i.item]);
      }
      console.log(keyQueryData);
      const keyTxn = await (keyRouterWithSigner as any).bundledPurchase(
        keyQueryData,
      );
      const txHash = await keyTxn.wait();
      keyReceipt = txHash.status;
      console.log(keyReceipt);
    }

    props.bag.items.clear();
    props.bag.subTotal = 0;
    setOrderPlaced(true);
  };

  return (
    <>
      <NavBar
        for="shop"
        bag={props.bag}
        HashFitKeyData={props.HashFitKeyData}
        wallet={props.wallet}
      />
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
                    <svg
                      width="25px"
                      height="25px"
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
              <svg
                width="20px"
                height="20px"
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
                    <circle fill="#ff00bb" cx="16" cy="16" r="16"></circle>{" "}
                    <g fill="#FFF">
                      {" "}
                      <path d="M20.022 18.124c0-2.124-1.28-2.852-3.84-3.156-1.828-.243-2.193-.728-2.193-1.578 0-.85.61-1.396 1.828-1.396 1.097 0 1.707.364 2.011 1.275a.458.458 0 00.427.303h.975a.416.416 0 00.427-.425v-.06a3.04 3.04 0 00-2.743-2.489V9.142c0-.243-.183-.425-.487-.486h-.915c-.243 0-.426.182-.487.486v1.396c-1.829.242-2.986 1.456-2.986 2.974 0 2.002 1.218 2.791 3.778 3.095 1.707.303 2.255.668 2.255 1.639 0 .97-.853 1.638-2.011 1.638-1.585 0-2.133-.667-2.316-1.578-.06-.242-.244-.364-.427-.364h-1.036a.416.416 0 00-.426.425v.06c.243 1.518 1.219 2.61 3.23 2.914v1.457c0 .242.183.425.487.485h.915c.243 0 .426-.182.487-.485V21.34c1.829-.303 3.047-1.578 3.047-3.217z"></path>{" "}
                      <path d="M12.892 24.497c-4.754-1.7-7.192-6.98-5.424-11.653.914-2.55 2.925-4.491 5.424-5.402.244-.121.365-.303.365-.607v-.85c0-.242-.121-.424-.365-.485-.061 0-.183 0-.244.06a10.895 10.895 0 00-7.13 13.717c1.096 3.4 3.717 6.01 7.13 7.102.244.121.488 0 .548-.243.061-.06.061-.122.061-.243v-.85c0-.182-.182-.424-.365-.546zm6.46-18.936c-.244-.122-.488 0-.548.242-.061.061-.061.122-.061.243v.85c0 .243.182.485.365.607 4.754 1.7 7.192 6.98 5.424 11.653-.914 2.55-2.925 4.491-5.424 5.402-.244.121-.365.303-.365.607v.85c0 .242.121.424.365.485.061 0 .183 0 .244-.06a10.895 10.895 0 007.13-13.717c-1.096-3.46-3.778-6.07-7.13-7.162z"></path>{" "}
                    </g>{" "}
                  </g>{" "}
                </g>
              </svg>{" "}
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
              <svg
                width="20px"
                height="20px"
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
                    <circle fill="#ff00bb" cx="16" cy="16" r="16"></circle>{" "}
                    <g fill="#FFF">
                      {" "}
                      <path d="M20.022 18.124c0-2.124-1.28-2.852-3.84-3.156-1.828-.243-2.193-.728-2.193-1.578 0-.85.61-1.396 1.828-1.396 1.097 0 1.707.364 2.011 1.275a.458.458 0 00.427.303h.975a.416.416 0 00.427-.425v-.06a3.04 3.04 0 00-2.743-2.489V9.142c0-.243-.183-.425-.487-.486h-.915c-.243 0-.426.182-.487.486v1.396c-1.829.242-2.986 1.456-2.986 2.974 0 2.002 1.218 2.791 3.778 3.095 1.707.303 2.255.668 2.255 1.639 0 .97-.853 1.638-2.011 1.638-1.585 0-2.133-.667-2.316-1.578-.06-.242-.244-.364-.427-.364h-1.036a.416.416 0 00-.426.425v.06c.243 1.518 1.219 2.61 3.23 2.914v1.457c0 .242.183.425.487.485h.915c.243 0 .426-.182.487-.485V21.34c1.829-.303 3.047-1.578 3.047-3.217z"></path>{" "}
                      <path d="M12.892 24.497c-4.754-1.7-7.192-6.98-5.424-11.653.914-2.55 2.925-4.491 5.424-5.402.244-.121.365-.303.365-.607v-.85c0-.242-.121-.424-.365-.485-.061 0-.183 0-.244.06a10.895 10.895 0 00-7.13 13.717c1.096 3.4 3.717 6.01 7.13 7.102.244.121.488 0 .548-.243.061-.06.061-.122.061-.243v-.85c0-.182-.182-.424-.365-.546zm6.46-18.936c-.244-.122-.488 0-.548.242-.061.061-.061.122-.061.243v.85c0 .243.182.485.365.607 4.754 1.7 7.192 6.98 5.424 11.653-.914 2.55-2.925 4.491-5.424 5.402-.244.121-.365.303-.365.607v.85c0 .242.121.424.365.485.061 0 .183 0 .244-.06a10.895 10.895 0 007.13-13.717c-1.096-3.46-3.778-6.07-7.13-7.162z"></path>{" "}
                    </g>{" "}
                  </g>{" "}
                </g>
              </svg>{" "}
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

      {orderPlaced && (
        <div className="order-placed-view">
          <div>
            <h2>Order Confirmed!</h2>
            <p>
              🎉 Your order has been successfully placed! We're preparing your
              items and will notify you once they're on the way. Thank you for
              shopping with HashFit!
            </p>
            <button onClick={() => setOrderPlaced(false)}>
              Continue Shopping
            </button>
          </div>
        </div>
      )}
    </>
  );
}
