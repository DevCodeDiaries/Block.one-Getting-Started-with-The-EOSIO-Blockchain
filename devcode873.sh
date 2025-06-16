#!/bin/bash
# DevCode117 EOSIO Lab Automated Setup (GSP873)

echo "🌟 Starting EOSIO full setup..."

# 1. Update system
sudo apt update

# 2. Install EOSIO
curl -LO https://github.com/eosio/eos/releases/download/v2.1.0/eosio_2.1.0-1-ubuntu-20.04_amd64.deb
sudo apt install -y ./eosio_2.1.0-1-ubuntu-20.04_amd64.deb

# 3. Verify installation
nodeos --version
cleos version client
keosd -v

# 4. Start single-node blockchain
nodeos -e -p eosio \
  --plugin eosio::chain_api_plugin \
  --plugin eosio::history_api_plugin \
  --contracts-console >> nodeos.log 2>&1 &
sleep 5
tail -n 10 nodeos.log

# 5. Create wallet
cleos wallet create --name my_wallet --file my_wallet_password
export wallet_password=$(cat my_wallet_password)
cleos wallet unlock --name my_wallet --password $wallet_password

# 6. Import default development key
cleos wallet import --name my_wallet --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3

# 7. Install EOSIO.CDT
curl -LO https://github.com/eosio/eosio.cdt/releases/download/v1.8.1/eosio.cdt_1.8.1-1-ubuntu-20.04_amd64.deb
sudo apt install -y ./eosio.cdt_1.8.1-1-ubuntu-20.04_amd64.deb
eosio-cpp --version

# 8. Generate key-pair and create account
cleos create key --file my_keypair1
priv=$(grep "Private key:" my_keypair1 | cut -d ' ' -f 3)
pub=$(grep "Public key:" my_keypair1 | cut -d ' ' -f 3)
cleos wallet import --name my_wallet --private-key $priv
cleos create account eosio bob $pub

echo "✅ Setup complete by DevCode117!"
