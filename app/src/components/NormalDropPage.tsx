import React from "react";
import { useParams } from "react-router-dom";
import { Bag } from "../App";
import { ItemCard } from "./ItemCard";
import { drops, items } from "./items";
import { NavBar } from "./NavBar";
import { Footer } from "./Footer";
import { BrowserProvider } from "ethers";
import "./NormalDropPage.css";

type NormalDropPageProps = {
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
    connect: () => void;
  };
};

export function NormalDropPage(props: NormalDropPageProps) {
  const { id } = useParams<{ id: string }>();
  const drop = drops.find((d) => d.id === id);

  if (!drop) {
    return (
      <div className="normal-drop-detail-page">
        <NavBar
          for="shop"
          bag={props.bag}
          HashFitKeyData={props.HashFitKeyData}
          wallet={props.wallet}
        />
        <div className="drop-missing">
          <h2>Drop not found</h2>
          <p>We couldn’t find the drop you were looking for.</p>
        </div>
        <Footer />
      </div>
    );
  }

  const totalItems = Number(drop.totalItems);

  return (
    <div className="normal-drop-detail-page">
      <NavBar
        for="shop"
        bag={props.bag}
        HashFitKeyData={props.HashFitKeyData}
        wallet={props.wallet}
      />

      <div className="drop-hero">
        <div className="drop-hero-media">
          {drop.coverVideo ? (
            <video autoPlay muted loop className="drop-hero-video">
              <source src={drop.coverVideo} type="video/mp4" />
            </video>
          ) : (
            drop.coverImg && (
              <img
                className="drop-hero-img"
                src={drop.coverImg}
                alt={drop.name}
              />
            )
          )}
        </div>
        <div className="drop-hero-content">
          <h1 className="drop-title">{drop.name}</h1>
          <p className="drop-subtitle">{drop.launchDate}</p>
          <p className="drop-meta">{totalItems} unique items</p>
        </div>
      </div>

      <div className="drop-items">
        <h2>Collection</h2>
        <div className="drop-items-grid">
          {items.map((item) => (
            <ItemCard
              key={item.key}
              details={{
                name: item.name,
                image: item.image,
                price: item.price,
                discount: item.discount,
                key: item.key,
                gen: item.gen,
                itemId: item.itemId,
                amount: 0,
                keysUsed: 0,
              }}
              bag={{ current: props.bag, setBag: props.setBag }}
            />
          ))}
        </div>
      </div>

      <Footer />
    </div>
  );
}
