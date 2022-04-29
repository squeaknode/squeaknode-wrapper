#!/bin/bash
set -e
_term() {
  echo "Caught SIGTERM signal!"
  kill -TERM "$backend_process" 2>/dev/null
}


bitcoind_type=$(yq e '.bitcoind.type' /root/start9/config.yaml)
bitcoind_user=$(yq e '.bitcoind.user' /root/start9/config.yaml)
bitcoind_pass=$(yq e '.bitcoind.password' /root/start9/config.yaml)
# configure mempool to use just a bitcoind backend
if [ "$bitcoind_type" = "internal-proxy" ]; then
	bitcoind_host="btc-rpc-proxy.embassy"
	echo "Running on Bitcoin Proxy..."
else
	bitcoind_host="bitcoind.embassy"
	echo "Running on Bitcoin Core..."
fi


TOR_ADDRESS=$(yq e '.tor-address' /root/start9/config.yaml)
PEER_TOR_ADDRESS=$(yq e '.peer-tor-address' /root/start9/config.yaml)
LAN_ADDRESS=$(yq e '.lan-address' /root/start9/config.yaml)
LND_ADDRESS='lnd.embassy'
SQUEAKNODE_ADDRESS='squeaknode.embassy'
SQUEAKNODE_PASS=$(yq e '.password' /root/start9/config.yaml)
HOST_IP=$(ip -4 route list match 0/0 | awk '{print $3}')


export SQUEAKNODE_BITCOIN_RPC_HOST=$bitcoind_host
export SQUEAKNODE_BITCOIN_RPC_PORT=8332
export SQUEAKNODE_BITCOIN_RPC_USER=$bitcoind_user
export SQUEAKNODE_BITCOIN_RPC_PASS=$bitcoind_pass
export SQUEAKNODE_LND_HOST=$LND_ADDRESS
export SQUEAKNODE_LND_RPC_PORT=10009
export SQUEAKNODE_LND_TLS_CERT_PATH="/mnt/lnd/tls.cert"
export SQUEAKNODE_LND_MACAROON_PATH="/mnt/lnd/data/chain/bitcoin/mainnet/admin.macaroon"
export SQUEAKNODE_TOR_PROXY_IP=$HOST_IP
export SQUEAKNODE_TOR_PROXY_PORT=9050
export SQUEAKNODE_WEBADMIN_ENABLED="true"
export SQUEAKNODE_WEBADMIN_USERNAME='squeaknode-admin'
export SQUEAKNODE_WEBADMIN_PASSWORD=$SQUEAKNODE_PASS
export SQUEAKNODE_NODE_NETWORK='mainnet'
export SQUEAKNODE_NODE_SQK_DIR_PATH='/root/sqk'
export SQUEAKNODE_NODE_MAX_SQUEAKS=10000
export SQUEAKNODE_SERVER_EXTERNAL_ADDRESS=$PEER_TOR_ADDRESS


# Creating duplicate directory for the lnd macaroon files
mkdir -p /mnt/lnd/data/chain/bitcoin/mainnet
cp /mnt/lnd/*.macaroon /mnt/lnd/data/chain/bitcoin/mainnet

# Properties Page showing password to be used for login
  echo 'version: 2' >> /root/start9/stats.yaml
  echo 'data:' >> /root/start9/stats.yaml
  echo '  Username: ' >> /root/start9/stats.yaml
        echo '    type: string' >> /root/start9/stats.yaml
        echo '    value: squeaknode-admin' >> /root/start9/stats.yaml
        echo '    description: This is your admin username for Squeaknode' >> /root/start9/stats.yaml
        echo '    copyable: true' >> /root/start9/stats.yaml
        echo '    masked: false' >> /root/start9/stats.yaml
        echo '    qr: false' >> /root/start9/stats.yaml
  echo '  Password: ' >> /root/start9/stats.yaml
        echo '    type: string' >> /root/start9/stats.yaml
        echo "    value: \"$SQUEAKNODE_PASS\"" >> /root/start9/stats.yaml
        echo '    description: This is your admin password for Squeaknode. Please use caution when sharing this password, you could lose your funds!' >> /root/start9/stats.yaml
        echo '    copyable: true' >> /root/start9/stats.yaml
        echo '    masked: true' >> /root/start9/stats.yaml
        echo '    qr: false' >> /root/start9/stats.yaml

# Starting Squeaknode process
echo "starting squeaknode..."
exec squeaknode --log-level INFO
