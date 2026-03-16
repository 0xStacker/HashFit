import { NavBar } from "./components/NavBar";
import { HeroDesc } from "./components/HeroDescription";
import { ProjectSection } from "./components/ProjectSection";
import { Footer } from "./components/Footer";
import "./HomePage.css";
import { useEffect } from "react";
import { Bag, BagItemData } from "./App";
import { items } from "./components/items";

export function Home() {
  return (
    <div className="home">
      <title>HashFit</title>
      <NavBar
        for="home"
        bag={{ items: new Map<string, BagItemData>(), subTotal: 0 }}
        keys={{ legendary: 0, mythic: 0 }}
      />
      <HeroDesc />
      <ProjectSection />
      <Footer />
    </div>
  );
}
