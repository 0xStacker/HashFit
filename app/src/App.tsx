import { CardProps } from "./components/ItemCard";
import { Home } from "./HomePage";
import { Shop } from "./Shop";
import { useState } from "react";
import { Routes, Route } from "react-router-dom";
import { Checkout } from "./Checkout";

export type BagItemData = {
  name: string;
  image: string;
  price: number;
  discount: number;
  key: string;
  gen: string;
  amount: number;
};

export type Bag = {
  items: Map<string, BagItemData>;
  subTotal: number;
};

export function App() {
  const shopBag: Bag = {
    items: new Map<string, BagItemData>(),
    subTotal: 0,
  };

  const [bag, setBag] = useState(shopBag);
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/shop/drop" element={<Shop bag={bag} setBag={setBag} />} />
      <Route
        path="/bag"
        element={<Checkout bag={bag} setBag={setBag} />}
      ></Route>
    </Routes>
  );
}
