import React from 'react';
import ReactDOM from 'react-dom';
import { createRoot } from "react-dom/client";
import { router } from './App';
import { RouterProvider } from 'react-router-dom';


const root = createRoot(document.getElementById('root'));

root.render(
    <React.StrictMode>
        <RouterProvider router={router} />
    </React.StrictMode>
);
