import React from 'react';
import { AppBar, Toolbar, Typography, Button } from '@mui/material';


const Header = () => {
    return (
        <AppBar position="static" sx={{ backgroundColor: '#426d8c', height: '120px', display: 'flex', justifyContent: 'center', mb: 11 }}>
            <Toolbar >
                <Typography variant="h6" sx={{ fontSize: '50px', fontFamily: 'Georgia, serif', mr: 10, ml: 4 }} >
                    Crypto-Pricer
                </Typography>
                <Button color="inherit" sx={{ fontSize: '20px', fontFamily: 'Georgia, serif', m: 3, mt: 4 }} >
                    Bitcoin
                </Button>
                <Button color="inherit" sx={{ fontSize: '20px', fontFamily: 'Georgia, serif', m: 3, mt: 4 }} >
                    Ethereum
                </Button>
                <Button color="inherit" sx={{ fontSize: '20px', fontFamily: 'Georgia, serif', m: 3, mt: 4 }} >
                    XRP
                </Button>
            </Toolbar>
        </AppBar >
    );
};

export default Header;
