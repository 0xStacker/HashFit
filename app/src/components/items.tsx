import { CardProps } from "./ItemCard";
import { DropProps } from "./Drop";

export type Drop = {
  contract: string;
  coverImg: string;
  coverVideo: string;
};

const today = new Date();

export const premiumDrops = [
  {
    name: "HashFit x Cyfrin",
    totalItems: 50,
    launchDate: today.toLocaleString("default", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }),
    id: "HashFitxCyfrin",
    coverImg: "/assests/collabs/cb1.png",
    coverVideo: "",
  },
  {
    name: "HashFit X Chainlink",
    totalItems: 100,
    launchDate: today.toLocaleString("default", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }),
    id: "HashFitxChainlink",
    coverImg: "/assests/collabs/cb2.png",
    coverVideo: "",
  },
  {
    name: "Gen-P1",
    launchDate: today.toLocaleString("default", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }),
    totalItems: 25,
    id: "x256",
    coverImg: "",
    coverVideo: "/assests/background/cp5.mp4",
  },
  {
    name: "Gen-P2",
    launchDate: today.toLocaleString("default", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }),
    totalItems: 90,
    id: "x-100",
    coverImg: "/assests/background/cp5.png",
    coverVideo: "",
  },
];

export const drops: DropProps[] = [
  {
    name: "Genesis",
    totalItems: 50,
    launchDate: today.toLocaleString("default", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }),
    id: "genesis",
    coverImg: "/assests/background/cp2.png",
    coverVideo: "",
  },
  {
    name: "Cypher X",
    totalItems: 100,
    launchDate: today.toLocaleString("default", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }),
    id: "cypher-x",
    coverImg: "/assests/background/cp3.png",
    coverVideo: "",
  },
  {
    name: "X256",
    launchDate: today.toLocaleString("default", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }),
    totalItems: 25,
    id: "x256",
    coverImg: "",
    coverVideo: "/assests/background/cp5.mp4",
  },
  {
    name: "X-100",
    launchDate: today.toLocaleString("default", {
      year: "numeric",
      month: "long",
      day: "numeric",
    }),
    totalItems: 90,
    id: "x-100",
    coverImg: "/assests/background/cp5.png",
    coverVideo: "",
  },
];

export const items: CardProps[] = [
  {
    name: "Genesis M-50",
    image: "/assests/background/bg2.png",
    price: 25,
    discount: 0,
    gen: "0x60fC61c50186a4012AE9153c47e2643544cdE30C",
    key: crypto.randomUUID(),
  },
  {
    name: "Genesis M-10",
    image: "/assests/background/bg3.png",
    price: 25,
    discount: 0,
    gen: "0x9661A6F57F5Bc7bA370e01C8E1f2BEdF185e06c4",
    key: crypto.randomUUID(),
  },

  {
    name: "Cypher-X",
    image: "/assests/background/bg5.png",
    price: 100,
    discount: 500,
    gen: "0x1703b33d2e6815baf2d69d5e74d37b8da0fc023a",
    key: crypto.randomUUID(),
  },

  {
    name: "Genesis M-1",
    image: "/assests/background/bg4.png",
    price: 25,
    discount: 0,
    gen: "0x52346350618d1Ff566511385BA79e9875c0955Ab",
    key: crypto.randomUUID(),
  },
  {
    name: "Genesis M-10",
    image: "/assests/background/bg3.png",
    price: 25,
    discount: 0,
    gen: "0x9661A6F57F5Bc7bA370e01C8E1f2BEdF185e06c4",
    key: crypto.randomUUID(),
  },
];

export const premiumItems = [
  {
    name: "Genesis M-50",
    image: "/assests/background/bg2.png",
    price: 25,
    discount: 0,
    gen: "0x60fC61c50186a4012AE9153c47e2643544cdE30C",
    key: crypto.randomUUID(),
  },
  {
    name: "Genesis M-10",
    image: "/assests/background/bg3.png",
    price: 25,
    discount: 0,
    gen: "0x9661A6F57F5Bc7bA370e01C8E1f2BEdF185e06c4",
    key: crypto.randomUUID(),
  },

  {
    name: "Cypher-X",
    image: "/assests/background/bg5.png",
    price: 100,
    discount: 500,
    gen: "0x1703b33d2e6815baf2d69d5e74d37b8da0fc023a",
    key: crypto.randomUUID(),
  },

  {
    name: "Genesis M-1",
    image: "/assests/background/bg4.png",
    price: 25,
    discount: 0,
    gen: "0x52346350618d1Ff566511385BA79e9875c0955Ab",
    key: crypto.randomUUID(),
  },
  {
    name: "Genesis M-10",
    image: "/assests/background/bg3.png",
    price: 25,
    discount: 0,
    gen: "0x9661A6F57F5Bc7bA370e01C8E1f2BEdF185e06c4",
    key: crypto.randomUUID(),
  },
];
