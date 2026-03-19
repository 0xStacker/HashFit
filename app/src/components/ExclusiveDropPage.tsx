import React from "react";
import { Bag } from "../App";
import { PremiumDrop } from "./PremiumDrop";
import { premiumDrops } from "./items";
import { NavBar } from "./NavBar";
import { Footer } from "./Footer";
import "./ExclusiveDropPage.css";

type ExclusiveDropPageProps = {
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

export function ExclusiveDropPage(props: ExclusiveDropPageProps) {
  return (
    <>
      <NavBar for="shop" bag={props.bag} keys={props.HashFitKeyData.keys} />
      <div className="exclusive-drop-page">
        <div className="exclusive-hero">
          <div className="hero-background">
            <div className="hero-images-grid">
              <img src="/assests/background/bg1.png" alt="Background 1" />
              <img src="/assests/background/bg2.png" alt="Background 2" />
              <img src="/assests/background/bg3.png" alt="Background 3" />
              <img src="/assests/background/bg4.png" alt="Background 4" />
              <img src="/assests/background/bg5.png" alt="Background 5" />
            </div>
            <div className="hero-overlay"></div>
          </div>
          <div className="hero-content">
            <h1 className="exclusive-title">Exclusive Drop</h1>
            <p className="exclusive-subtitle">
              Limited edition items for discerning collectors
            </p>
          </div>
        </div>

        <div className="exclusive-content">
          <div className="exclusive-description">
            <h2>Premium Collection</h2>
            <p>
              Discover our most exclusive items, crafted for the elite
              collector. Each piece is a testament to innovation, design, and
              rarity.
            </p>
          </div>

          <div className="exclusive-items-grid">
            {premiumDrops.map((drop) => (
              <PremiumDrop
                key={drop.id}
                name={drop.name}
                launchDate={drop.launchDate}
                totalItems={drop.totalItems}
                coverImg={drop.coverImg}
                coverVideo={drop.coverVideo}
                id={drop.id}
              />
            ))}
          </div>
        </div>
      </div>
      <Footer />
    </>
  );
}
