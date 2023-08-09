import Bitcoin, { bitcoinLoader } from "./Bitcoin";
import Ethereum from "./Ethereum";
import Xrp from "./Xrp";
import Header from "./Header";
import NoPage from "./NoPage";

import ReactDOM from 'react-dom';

import { BrowserRouter, Routes, Route, createBrowserRouter, createRoutesFromElements } from "react-router-dom";

export const router = createBrowserRouter(
    createRoutesFromElements(
        <Route path="/" element={<Bitcoin />}>
            <Route path="/bitcoin" element={<Bitcoin />} />
            <Route path="/bitcoin/:window" loader={bitcoinLoader} element={<Bitcoin />} />
            <Route path="/ethereum" element={<Ethereum />} />
            <Route path="/xrp" element={<Xrp />} />
            <Route path="*" element={<NoPage />} />
        </Route>
    )
)