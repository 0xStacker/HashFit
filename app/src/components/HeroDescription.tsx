import "./HeroDescription.css";
import { Button } from "./Button";
import { useState, useEffect } from "react";

// note: the images should be placed in the public assets folder (app/public/assests/background)
// or imported directly from src if you prefer.
const slides = [
  "/assests/background/bg1.png",
  "/assests/background/bg2.png",
  "/assests/background/bg3.png",
  "/assests/background/bg4.png",
  "/assests/background/bg5.png",
];

export function HeroDesc() {
  const [current, setCurrent] = useState(0);

  useEffect(() => {
    const iv = setInterval(() => {
      setCurrent((c) => (c + 1) % slides.length);
    }, 2000); // change slide every 3s
    return () => clearInterval(iv);
  }, []);

  return (
    <div className="description">
      <div className="call-to-action">
        <h1 className="catch-phrase">GENESIS</h1>
        <p className="desc-text">
          The HashFit genesis represents the origin layer of HashFit. It is the
          first and definitive access point into a performance-driven ecosystem
          designed for long-term believers. Entry is limited. Recognition is
          permanent.
        </p>
        <button className="cta-button"> Coming soon </button>
      </div>
      <div className="graphics">
        <img className="cover" src={slides[current]} alt={`slide-${current}`} />
      </div>
    </div>
  );
}
