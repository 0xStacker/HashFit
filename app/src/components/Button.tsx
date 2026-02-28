import "./Button.css";

export type ButtonProps = {
  name: string;
};

export function Button(props: ButtonProps) {
  return <button>{props.name}</button>;
}
