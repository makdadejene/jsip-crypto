import Bitcoin from "./Bitcoin";
import Ethereum from "./Ethereum";
import Xrp from "./Xrp";
import Header from "./Header";
import NoPage from "./NoPage";

import ReactDOM from 'react-dom';

import { BrowserRouter, Routes, Route } from "react-router-dom";

export default function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<Bitcoin />} />
                <Route path="/bitcoin" element={<Bitcoin />} />
                <Route path="/ethereum" element={<Ethereum />} />
                <Route path="/xrp" element={<Xrp />} />
                <Route path="*" element={<NoPage />} />
            </Routes>
        </BrowserRouter>);
}
