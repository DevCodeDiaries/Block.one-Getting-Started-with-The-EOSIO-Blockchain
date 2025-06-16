#!/bin/bash

# 🧼 Update OS packages
sudo apt update

# 📦 Install EOSIO
curl -LO https://github.com/eosio/eos/releases/download/v2.1.0/eosio_2.1.0-1-ubuntu-20.04_amd64.deb
sudo apt install -y ./eosio_2.1.0-1-ubuntu-20.04_amd64.deb

# ✅ Check installation
nodeos --version
cleos version client
keosd -v

# 🚀 Start single-node blockchain in background
nodeos -e -p eosio \
  --plugin eosio::chain_api_plugin \
  --plugin eosio::history_api_plugin \
  --contracts-console >> nodeos.log 2>&1 &

# Wait a few seconds for nodeos to initialize
sleep 5
tail -n 10 nodeos.log

# 🔐 Create wallet
cleos wallet create --name my_wallet --file my_wallet_password
export wallet_password=$(cat my_wallet_password)
cleos wallet unlock --name my_wallet --password $wallet_password

# 🔑 Import eosio private key
cleos wallet import --name my_wallet --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3

# 🛠 Install EOSIO CDT (Contract Development Toolkit)
curl -LO https://github.com/eosio/eosio.cdt/releases/download/v1.8.1/eosio.cdt_1.8.1-1-ubuntu-20.04_amd64.deb
sudo apt install -y ./eosio.cdt_1.8.1-1-ubuntu-20.04_amd64.deb
eosio-cpp --version

# 👤 Create keypair and blockchain account
cleos create key --file my_keypair1
user_private_key=$(grep "Private key:" my_keypair1 | cut -d ' ' -f 3)
user_public_key=$(grep "Public key:" my_keypair1 | cut -d ' ' -f 3)

# 🔐 Import new key to wallet
cleos wallet import --name my_wallet --private-key $user_private_key

# 🧾 Create a new EOSIO account called "bob"
cleos create account eosio bob $user_public_key
