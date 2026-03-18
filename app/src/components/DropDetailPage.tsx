import React from "react";
import { useParams } from "react-router-dom";
import { Bag } from "../App";
import { ItemCard } from "./ItemCard";
import { premiumDrops, premiumItems } from "./items";
import { NavBar } from "./NavBar";
import { Footer } from "./Footer";
import "./DropDetailPage.css";

type DropDetailPageProps = {
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

export function DropDetailPage(props: DropDetailPageProps) {
  const { id } = useParams<{ id: string }>();
  const drop = premiumDrops.find((d) => d.id === id);

  if (!drop) {
    return (
      <div className="drop-detail-page">
        <NavBar for="shop" bag={props.bag} keys={props.HashFitKeyData.keys} />
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
    <div className="drop-detail-page">
      <NavBar for="shop" bag={props.bag} keys={props.HashFitKeyData.keys} />

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
        <div className="drop-hero-overlay"></div>
        <div className="drop-hero-content">
          <h1 className="p-drop-title">{drop.name}</h1>
          <p className="p-drop-subtitle">{drop.launchDate}</p>
          <p className="p-drop-meta">{totalItems} unique items</p>
        </div>
      </div>

      <div className="p-drop-items">
        <h2>Collection</h2>
        <div className="drop-items-grid">
          {premiumItems.map((item) => (
            <ItemCard
              key={item.key}
              details={{
                name: `${drop.name} ${item.name}`,
                image: item.image,
                price: item.price,
                discount: item.discount,
                key: item.key,
                gen: item.gen,
                amount: 0,
                keysUsed: 0,
                priceInKeys: item.priceInKeys,
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
