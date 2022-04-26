#!/usr/bin/env bash

# exit from script if error was raised.
set -e

export SQUEAKNODE_BITCOIN_RPC_HOST=bitcoind.embassy
export SQUEAKNODE_BITCOIN_RPC_PORT=8332
export SQUEAKNODE_BITCOIN_RPC_USER=$(yq e '.bitcoind.user' /root/.lightning/start9/config.yaml)
export SQUEAKNODE_BITCOIN_RPC_PASS=$(yq e '.bitcoind.password' /root/.lightning/start9/config.yaml)
export SQUEAKNODE_LND_HOST=lnd.embassy
export SQUEAKNODE_LND_RPC_PORT=10009
export SQUEAKNODE_LND_TLS_CERT_PATH=
export SQUEAKNODE_LND_MACAROON_PATH=
export SQUEAKNODE_TOR_PROXY_IP=
export SQUEAKNODE_TOR_PROXY_PORT=
export SQUEAKNODE_WEBADMIN_ENABLED=
export SQUEAKNODE_WEBADMIN_USERNAME=
export SQUEAKNODE_WEBADMIN_PASSWORD=
export SQUEAKNODE_NODE_NETWORK=
export SQUEAKNODE_NODE_SQK_DIR_PATH=
export SQUEAKNODE_NODE_MAX_SQUEAKS=
export SQUEAKNODE_SERVER_EXTERNAL_ADDRESS=

# Start using the run server command
if [ -f config.ini ]; then
    exec squeaknode \
	 --config config.ini \
	 --log-level INFO
else
    exec squeaknode \
	 --log-level INFO
fi
