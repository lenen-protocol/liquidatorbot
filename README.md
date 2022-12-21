# Liquidator bot
this repo is a liquidator bot for lenen protocol.

# Configuration
use `key.js` instead of `.env`
set up private key, public key. then can start

## Node
nodejs version must higher than ``16.16.0``

## Run
```
npm install
node looplisten.js
```

## Build in docker
```
docker build -t liqbot:v1 .
docker run liqbot
```

