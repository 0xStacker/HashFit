import { CardProps } from "./components/ItemCard";
import { Home } from "./HomePage";
import { Shop } from "./Shop";
import { useState } from "react";
import { Routes, Route } from "react-router-dom";
import { Checkout } from "./Checkout";
import { ExclusiveDropPage } from "./components/ExclusiveDropPage";
import { DropDetailPage } from "./components/DropDetailPage";
import { NormalDropPage } from "./components/NormalDropPage";

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

type Keys = {
  legendary: number;
  mythic: number;
};

export function App() {
  const shopBag: Bag = {
    items: new Map<string, BagItemData>(),
    subTotal: 0,
  };
  const [keys, setKeys] = useState({ legendary: 0, mythic: 0 });
  const HashFitKeys = {
    keys: keys,
    set: setKeys,
  };
  const [bag, setBag] = useState(shopBag);

  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route
        path="/shop/drop"
        element={
          <Shop bag={bag} setBag={setBag} HashFitKeyData={HashFitKeys} />
        }
      />
      <Route
        path="/exclusive"
        element={
          <ExclusiveDropPage
            bag={bag}
            setBag={setBag}
            HashFitKeyData={HashFitKeys}
          />
        }
      />
      <Route
        path="/exclusive/:id"
        element={
          <DropDetailPage
            bag={bag}
            setBag={setBag}
            HashFitKeyData={HashFitKeys}
          />
        }
      />

      <Route
        path="/drops/:id"
        element={
          <NormalDropPage
            bag={bag}
            setBag={setBag}
            HashFitKeyData={HashFitKeys}
          />
        }
      />
      <Route
        path="/bag"
        element={
          <Checkout bag={bag} setBag={setBag} HashFitKeyData={HashFitKeys} />
        }
      ></Route>
    </Routes>
  );
}
