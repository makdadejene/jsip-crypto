import { LinkOff } from '@mui/icons-material';
import { AppBar, Toolbar, Typography, Button } from '@mui/material';
import React from "react";
import { BrowserRouter, Route, Link } from "react-router-dom";

const Header = () => {
    return (
        <div>
            <AppBar position="static" sx={{ backgroundColor: '#343a40', height: '120px', display: 'flex', justifyContent: 'center', mb: 11 }}>
                <Toolbar >
                    <Typography variant="h6" sx={{ fontSize: '50px', fontFamily: 'Georgia, serif', mr: 10, ml: 4 }} >
                        <Link to="/" style={{ textDecoration: 'none', color: 'white' }} > Crypto-Pricer</Link>
                    </Typography>
                    <Button color="inherit" sx={{ fontSize: '20px', fontFamily: 'Georgia, serif', m: 3, mt: 4 }} >
                        <Link to="/bitcoin" style={{ textDecoration: 'none', color: 'white' }}> Bitcoin</Link>
                    </Button>
                    <Button color="inherit" sx={{ fontSize: '20px', fontFamily: 'Georgia, serif', m: 3, mt: 4 }} >
                        <Link to="/ethereum" style={{ textDecoration: 'none', color: 'white' }}> Ethereum</Link>
                    </Button>

                    <Button color="inherit" sx={{ fontSize: '20px', fontFamily: 'Georgia, serif', m: 3, mt: 4 }} >
                        <Link to="/xrp" style={{ textDecoration: 'none', color: 'white' }}> Xrp</Link>
                    </Button>
                    <Button color="inherit" sx={{ fontSize: '20px', fontFamily: 'Georgia, serif', m: 3, mt: 4 }} >
                        <Link to="/bnb" style={{ textDecoration: 'none', color: 'white' }}> Bnb</Link>
                    </Button>
                    <Button color="inherit" sx={{ fontSize: '20px', fontFamily: 'Georgia, serif', m: 3, mt: 4 }} >
                        <Link to="/cardano" style={{ textDecoration: 'none', color: 'white' }}> Cardano</Link>
                    </Button>
                    <Button color="inherit" sx={{ fontSize: '20px', fontFamily: 'Georgia, serif', m: 3, mt: 4 }} >
                        <Link to="/solana" style={{ textDecoration: 'none', color: 'white' }}> Solana</Link>
                    </Button>
                </Toolbar>
            </AppBar >
        </div >
    );
};

export default Header;
