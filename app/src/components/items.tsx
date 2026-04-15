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
    id: "",
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
    gen: "0x4e7d1b6c9dAAB8b3CF88bA42d631860295Cc69B5",
    key: crypto.randomUUID(),
    itemId: 0,
    priceInKeys: 0,
  },
  {
    name: "Genesis M-10",
    image: "/assests/background/bg3.png",
    price: 25,
    discount: 0,
    gen: "0x4e7d1b6c9dAAB8b3CF88bA42d631860295Cc69B5",
    key: crypto.randomUUID(),
    itemId: 1,
    priceInKeys: 0,
  },

  {
    name: "Cypher-X",
    image: "/assests/background/bg5.png",
    price: 100,
    discount: 500,
    gen: "0x4e7d1b6c9dAAB8b3CF88bA42d631860295Cc69B5",
    key: crypto.randomUUID(),
    itemId: 2,
    priceInKeys: 0,
  },

  {
    name: "Genesis M-1",
    image: "/assests/background/bg4.png",
    price: 25,
    discount: 0,
    gen: "0x4e7d1b6c9dAAB8b3CF88bA42d631860295Cc69B5",
    key: crypto.randomUUID(),
    itemId: 3,
    priceInKeys: 0,
  },
  {
    name: "Genesis M-10",
    image: "/assests/background/bg3.png",
    price: 25,
    discount: 0,
    gen: "0x4e7d1b6c9dAAB8b3CF88bA42d631860295Cc69B5",
    key: crypto.randomUUID(),
    itemId: 4,
    priceInKeys: 0,
  },
];

export const premiumItems: CardProps[] = [
  {
    name: "Genesis M-50",
    image: "/assests/background/bg2.png",
    price: 25,
    discount: 0,
    gen: "0xdE8974b2bFF0c20f648669Bc0899E23960EEf445",
    key: crypto.randomUUID(),
    priceInKeys: 3,
    itemId: 0,
  },
  {
    name: "Genesis M-10",
    image: "/assests/background/bg3.png",
    price: 25,
    discount: 0,
    gen: "0xdE8974b2bFF0c20f648669Bc0899E23960EEf445",
    key: crypto.randomUUID(),
    priceInKeys: 1,
    itemId: 1,
  },

  {
    name: "Cypher-X",
    image: "/assests/background/bg5.png",
    price: 100,
    discount: 500,
    gen: "0xdE8974b2bFF0c20f648669Bc0899E23960EEf445",
    key: crypto.randomUUID(),
    priceInKeys: 1,
    itemId: 2,
  },

  {
    name: "Genesis M-1",
    image: "/assests/background/bg4.png",
    price: 25,
    discount: 0,
    gen: "0xdE8974b2bFF0c20f648669Bc0899E23960EEf445",
    key: crypto.randomUUID(),
    priceInKeys: 2,
    itemId: 3,
  },
  {
    name: "Genesis M-10",
    image: "/assests/background/bg3.png",
    price: 25,
    discount: 0,
    gen: "0xdE8974b2bFF0c20f648669Bc0899E23960EEf445",
    key: crypto.randomUUID(),
    priceInKeys: 1,
    itemId: 4,
  },
];
