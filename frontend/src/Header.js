import { LinkOff } from '@mui/icons-material';
import { AppBar, Toolbar, Typography, Button } from '@mui/material';
import React from "react";
import { BrowserRouter, Route, Link } from "react-router-dom";

const Header = () => {
    return (
        <div>
            <AppBar position="static" sx={{ backgroundColor: '#426d8c', height: '120px', display: 'flex', justifyContent: 'center', mb: 11 }}>
                <Toolbar >
                    <Typography variant="h6" sx={{ fontSize: '50px', fontFamily: 'Georgia, serif', mr: 10, ml: 4 }} >
                        <Link to="/"> Crypto-Pricer</Link>
                    </Typography>
                    <Button color="inherit" sx={{ fontSize: '20px', fontFamily: 'Georgia, serif', m: 3, mt: 4 }} >
                        <Link to="/bitcoin"> Bitcoin</Link>
                    </Button>
                    <Button color="inherit" sx={{ fontSize: '20px', fontFamily: 'Georgia, serif', m: 3, mt: 4 }} >
                        <Link to="/ethereum"> Ethereum</Link>
                    </Button>
                    <Button color="inherit" sx={{ fontSize: '20px', fontFamily: 'Georgia, serif', m: 3, mt: 4 }} >
                        <Link to="/xrp"> Xrp</Link>
                    </Button>
                </Toolbar>
            </AppBar >
        </div >
    );
};

export default Header;
