import { Link } from "react-router-dom";
import "./Drop.css";

export type DropProps = {
  name: string;
  launchDate: string;
  totalItems: number | Number;
  coverImg?: string;
  coverVideo?: string;
  id: string;
};

export function Drop(props: DropProps) {
  return (
    <Link className="shop-link" to={`/drops/${props.id}`}>
      <div className="drop-container">
        <div className="img-sec">
          {props.coverImg && (
            <img
              className="cover-img"
              src={props.coverImg}
              alt={`${props.name} cover`}
            />
          )}
          {props.coverVideo !== "" && (
            <video autoPlay muted loop className="cover-img">
              <source src={props.coverVideo} type="video/mp4" />
            </video>
          )}
        </div>
        <div className="drop-details">
          <div className="drop-name">
            <svg
              fill="#1e1e1e"
              width="10px"
              height="10px"
              viewBox="0 0 36 36"
              version="1.1"
              preserveAspectRatio="xMidYMid meet"
              xmlns="http://www.w3.org/2000/svg"
            >
              <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
              <g
                id="SVGRepo_tracerCarrier"
                stroke-linecap="round"
                stroke-linejoin="round"
              ></g>
              <g id="SVGRepo_iconCarrier">
                {" "}
                <title>details-solid</title>{" "}
                <path d="M32,6H4A2,2,0,0,0,2,8V28a2,2,0,0,0,2,2H32a2,2,0,0,0,2-2V8A2,2,0,0,0,32,6ZM19,22H9a1,1,0,0,1,0-2H19a1,1,0,0,1,0,2Zm8-4H9a1,1,0,0,1,0-2H27a1,1,0,0,1,0,2Zm0-4H9a1,1,0,0,1,0-2H27a1,1,0,0,1,0,2Z"></path>{" "}
                <rect
                  x="0"
                  y="0"
                  width="36"
                  height="36"
                  fill-opacity="0"
                ></rect>{" "}
              </g>
            </svg>
            <p className="">{props.name}</p>
          </div>
          <div className="items-left">
            <svg
              fill="#1e1e1e"
              width="10px"
              height="10px"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
              stroke="#000000"
            >
              <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
              <g
                id="SVGRepo_tracerCarrier"
                stroke-linecap="round"
                stroke-linejoin="round"
              ></g>
              <g id="SVGRepo_iconCarrier">
                <path d="M7 0H6L0 3v6l4-1v12h12V8l4 1V3l-6-3h-1a3 3 0 0 1-6 0z"></path>
              </g>
            </svg>
            <p className="">{props.totalItems as any} Unique Items</p>
          </div>

          <div className="release-date">
            <svg
              viewBox="0 0 16 16"
              width="10px"
              height="10px"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
              <g
                id="SVGRepo_tracerCarrier"
                stroke-linecap="round"
                stroke-linejoin="round"
              ></g>
              <g id="SVGRepo_iconCarrier">
                {" "}
                <path
                  fill-rule="evenodd"
                  clip-rule="evenodd"
                  d="M8 16C12.4183 16 16 12.4183 16 8C16 3.58172 12.4183 0 8 0C3.58172 0 0 3.58172 0 8C0 12.4183 3.58172 16 8 16ZM7 3V8.41421L10.2929 11.7071L11.7071 10.2929L9 7.58579V3H7Z"
                  fill="#1e1e1e"
                ></path>{" "}
              </g>
            </svg>
            <p className="">{props.launchDate}</p>
          </div>
        </div>
      </div>
    </Link>
  );
}
