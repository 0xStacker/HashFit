import { useState } from "react";
import { NavBar } from "./components/NavBar";
import { Footer } from "./components/Footer";
import { DropsPage } from "./components/DropsPage";
import { CardProps } from "./components/ItemCard";
import { Bag } from "./App";

type ShopProps = {
  bag: Bag;
  setBag: React.Dispatch<React.SetStateAction<Bag>>;
};
export function Shop(props: ShopProps) {
  return (
    <>
      <NavBar for="shop" bag={props.bag} />
      <DropsPage bag={{ current: props.bag, setBag: props.setBag }} />
      <Footer />
    </>
  );
}
