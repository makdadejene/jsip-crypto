import React from "react";
import Header from "./Header";
import { Outlet } from 'react-router-dom';

const Home = () => {

    return (
        <div>
        <Header></Header>
        <h1>Hello World</h1>
        <Outlet />
        </div>
    )
}

export default Home;