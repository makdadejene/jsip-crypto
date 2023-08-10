import React from 'react';
import { Container, Typography, CssBaseline } from '@mui/material';


function HomePage() {

  return (
    <React.Fragment>
      <CssBaseline />
      <main>
        <div >
          <Container maxWidth="sm">
            <Typography component="h1" variant="h2" align="center" color="textPrimary" gutterBottom>
              Crypto-Pricer
            </Typography>
            <Typography variant="h5" align="center" color="textSecondary" paragraph>
               A tool for accurate cryptocurrency pricing.
            </Typography>
          </Container>
        </div>
      </main>
    </React.Fragment>
  );
}

export default HomePage;
