---
JSIP Crypto-Currency Project
---
This is our final project for the Jane Street Immersion Program. We created a crypto-currency prediction model that is displayed on React powered website.

## Prep work

First, fork this repository clicking on the
green "Create fork" button at the bottom.

Then clone the fork locally (on your AWS machine) to get started. You can clone a repo on
the command line like this (where `$USER` is your GitHub username): $ git clone git@github.com:$USER/jsipcrypto.git.


## Accessing the website

The website is powered using React, so follow the steps to install React.js. In the terminal, $ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash. Then, $ export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh". Finally, reload the shell configuration through  $ source ~/.bashrc and install React $ npm install -g create-react-app.

To access the website, start up the backend server through the 'src' folder located in jsipcrypto, where the CoHttp Server resides. Then, type the command $ dune exec ../bin/main.exe to start up the server. 

Then, to view the frontend, $ cd frontend and $ npm run start. Keep in mind that packages such as Material UI and Visx will have to be installed for all of the visuals to appear. These packages can be installed through $ npm install [package name]. 

The code work using your personal AWS Access Key ID, so it is necessary to follow [these](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html) instructions to get the key. After this, update the fetch requests to be "http://[your key]:8181/api/[coin type]".

The link to access the website will be "http://[your key]:8181/[coin type]."


## Collaborators 

Makda Dejene and Daniel Ige




