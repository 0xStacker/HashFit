import { NavBar } from "./components/NavBar";
import { HeroDesc } from "./components/HeroDescription";
import { ProjectSection } from "./components/ProjectSection";
import { Footer } from "./components/Footer";
import "./HomePage.css";
import { useEffect } from "react";

export function Home() {
  return (
    <div className="home">
      <title>HashFit</title>
      <NavBar for="home"></NavBar>
      <HeroDesc />
      <ProjectSection />
      <Footer />
    </div>
  );
}
