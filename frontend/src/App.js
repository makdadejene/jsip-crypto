import Bitcoin, { bitcoinLoader } from "./Bitcoin";
import Ethereum, { ethereumLoader } from "./Ethereum";
import Xrp, { xrpLoader } from "./Xrp";
import Bnb, { bnbLoader } from "./Bitcoin";
import Cardano, { cardanoLoader } from "./Ethereum";
import Solana, { solanaLoader } from "./Xrp";
import Header from "./Header";
import Home from "./Home";
import NoPage from "./NoPage";

import ReactDOM from 'react-dom';
import { Outlet } from 'react-router-dom';

import { BrowserRouter, Routes, Route, createBrowserRouter, createRoutesFromElements } from "react-router-dom";
// import { ethereumLoader } from "./Ethereum";


export const router = createBrowserRouter(
    createRoutesFromElements(
        <Route path="/" element={<Home />}>
            <Route path="bitcoin/:window" loader={bitcoinLoader} element={<Bitcoin />} />
            <Route path="ethereum/:window" loader={ethereumLoader} element={<Ethereum />} />
            <Route path="xrp/:window" loader={xrpLoader} element={<Xrp />} />
            <Route path="bnb/:window" loader={bnbLoader} element={<Bnb />} />
            <Route path="cardano/:window" loader={cardanoLoader} element={<Cardano />} />
            <Route path="solana/:window" loader={solanaLoader} element={<Solana />} />
            <Route path="*" element={<NoPage />} />
        </Route>
    )
)