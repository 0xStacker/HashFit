// import React, { useEffect } from "react";
import { NavBar } from "./components/NavBar";
import { Footer } from "./components/Footer";
import { DropsPage } from "./components/DropsPage";

export function Shop() {
  return (
    <>
      <NavBar for="shop" />
      <DropsPage />
      <Footer />
    </>
  );
}
