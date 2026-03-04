import { Home } from "./HomePage";
import { Shop } from "./Shop";
import { Routes, Route } from "react-router-dom";

export function App() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/shop/drop" element={<Shop />} />
    </Routes>
  );
}
