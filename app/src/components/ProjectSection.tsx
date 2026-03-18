import "./ProjectSection.css";
import { Link } from "react-router-dom";
export function ProjectSection() {
  return (
    <div className="project-section">
      <h2>Performance Engineered On-Chain</h2>
      <p className="project-description">
        HashFit combines high-performance athletic apparel with
        blockchain-native infrastructure. We release limited collections
        purchasable in crypto, while integrating smart contracts directly into
        the core architecture of the brand. Ownership, progression and ecosystem
        coordination are anchored on-chain, not as marketing layer, but as
        foundational primitives. Every purchase extends beyond apparel, becoming
        a recorded position within a performance-driven ecosystem built for
        long-term alignment.{" "}
        <a href="/">
          <b>See</b>
        </a>{" "}
        how we're using blockchain techs like ERC1155, ERC721 to facilitate
        on-chain commerce and apparel culture.
      </p>
      <div className="mock-section">
        <img className="mock" src="/assests/mocks/main.png" alt="" />
        <Link className="shop-button" to="/shop">
          Shop Now
        </Link>
        <p className="shop-cta">Outwork The Croud</p>
        {/* <img className="mock" src="/assests/mocks/mock2.png" alt=""></img>
        <img className="mock" src="/assests/mocks/mock3.png" alt=""></img> */}
        {/* <img className="mock" src="/assests/mocks/mock4.png" alt=""></img>
        <img className="mock" src="/assests/mocks/mock5.png" alt=""></img> */}
      </div>
    </div>
  );
}
