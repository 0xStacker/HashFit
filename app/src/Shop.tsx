import { NavBar } from "./components/NavBar";
import { Footer } from "./components/Footer";
import { DropsPage } from "./components/DropsPage";
import { Bag } from "./App";

type ShopProps = {
  bag: Bag;
  setBag: React.Dispatch<React.SetStateAction<Bag>>;
  HashFitKeyData: {
    keys: { legendary: number; mythic: number };
    set: React.Dispatch<
      React.SetStateAction<{
        legendary: number;
        mythic: number;
      }>
    >;
  };
};

export function Shop(props: ShopProps) {
  return (
    <>
      <NavBar for="shop" bag={props.bag} keys={props.HashFitKeyData.keys} />
      <DropsPage bag={{ current: props.bag, setBag: props.setBag }} />
      <Footer />
    </>
  );
}
