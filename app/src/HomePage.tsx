import { NavBar } from "./components/NavBar";
import { HeroDesc } from "./components/HeroDescription";
import { ProjectSection } from "./components/ProjectSection";
import "./HomePage.css";
import { useEffect } from "react";

export function Home() {
  return (
    <div className="home">
      <title>HashFit</title>
      <NavBar></NavBar>
      <HeroDesc />
      <ProjectSection />
    </div>
  );
}
