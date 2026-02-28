import { Home } from "./HomePage";
import "./App.css";
import { NavBar } from "./components/NavBar";

export function App() {
  return (
    <>
      <title>HashFit. Do More</title>
      <div className="app">
        <Home />
      </div>
    </>
  );
}
