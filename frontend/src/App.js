import Bitcoin, { bitcoinLoader } from "./Bitcoin";
import Ethereum, { ethereumLoader } from "./Ethereum";
import Xrp, { xrpLoader } from "./Xrp";
import Bnb, { bnbLoader } from "./Bnb";
import Cardano, { cardanoLoader } from "./Cardano";
import Solana, { solanaLoader } from "./Solana";
import Header from "./Header";
import Home from "./Home";
import NoPage from "./NoPage";
import HomeHelper from "./HomeHelper";

import ReactDOM from 'react-dom';
import { Outlet } from 'react-router-dom';

import { BrowserRouter, Routes, Route, createBrowserRouter, createRoutesFromElements } from "react-router-dom";
// import { ethereumLoader } from "./Ethereum";




export const router = createBrowserRouter(
    createRoutesFromElements(
        <Route path="/" element={<Home />}>
            <Route index element={<HomeHelper />} />
            <Route path="bitcoin" loader={bitcoinLoader} element={<Bitcoin />} />
            <Route path="ethereum" loader={ethereumLoader} element={<Ethereum />} />
            <Route path="xrp" loader={xrpLoader} element={<Xrp />} />
            <Route path="bnb" loader={bnbLoader} element={<Bnb />} />
            <Route path="cardano" loader={cardanoLoader} element={<Cardano />} />
            <Route path="solana" loader={solanaLoader} element={<Solana />} />
            <Route path="*" element={<NoPage />} />
        </Route>
    )
)