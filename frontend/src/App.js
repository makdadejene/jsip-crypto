import Bitcoin, { bitcoinLoader } from "./Bitcoin";
import Ethereum, { ethereumLoader } from "./Ethereum";
import Xrp, { xrpLoader } from "./Xrp";
import Header from "./Header";
import Home from "./Home";
import NoPage from "./NoPage";

import ReactDOM from 'react-dom';
import { Outlet } from 'react-router-dom';

import { BrowserRouter, Routes, Route, createBrowserRouter, createRoutesFromElements } from "react-router-dom";
// import { ethereumLoader } from "./Ethereum";

const Root = () => {
    return (
        <div>
            <Outlet />
        </div>
    )
}

export const router = createBrowserRouter(
    createRoutesFromElements(
        <Route path="/" element={<Root />}>
            <Route path="bitcoin/:window" loader={bitcoinLoader} element={<Bitcoin />} />
            <Route path="ethereum/:window" loader={ethereumLoader} element={<Ethereum />} />
            <Route path="xrp/:window" loader={xrpLoader} element={<Xrp />} />
            <Route path="*" element={<NoPage />} />
        </Route>
    )
)