import React from 'react';
import { Container, Typography, CssBaseline } from '@mui/material';
import backgroundImage from '/usr/local/home/jsipuser/jsipcrypto/frontend/src/desktop-wallpaper-solid-navy-blue-backgrounds-becuo-2120x1192-for-your-mobile-tablet-plain-blue-aesthetic.jpg';

const containerStyle = {
  backgroundImage: `url(${backgroundImage})`,
  width: '1100px',
  backgroundPosition: 'center',
  display: 'flex',
  flexDirection: 'column',
  justifyContent: 'center',
  alignItems: 'center',
  minHeight: '50vh',

};

function HomePage() {
  return (
    <React.Fragment>
      <CssBaseline />
      <main>
        <div>
          <Container maxWidth="200" style={containerStyle}>
            <Typography component="h1" variant="h2" align="center" color="#ffffff" sx={{ fontSize: '60px', fontFamily: 'Georgia, serif' }} gutterBottom>
              Welcome to Crypto-Pricer
            </Typography>
            <Typography variant="h5" align="center" color="#ffffff" sx={{ fontSize: '25px', fontFamily: 'Georgia, serif' }} paragraph>
              A tool for accurate cryptocurrency pricing.
            </Typography>
          </Container>
        </div>
      </main>
    </React.Fragment>
  );
}

export default HomePage;
