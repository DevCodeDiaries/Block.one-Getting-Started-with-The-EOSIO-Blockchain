#!/bin/bash

echo "🌟 Starting full EOSIO setup on GCP VM..."

# 1. Create VM if not exists
gcloud compute instances describe my-vm-1 &>/dev/null || {
  echo "🚀 Creating my-vm-1 in us-east4-c..."
  gcloud compute instances create my-vm-1 \
    --zone=us-east4-c \
    --machine-type=e2-standard-2 \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-balanced
  echo "⏱ Waiting 90s for VM to initialize..."
  sleep 90
}

# 2. Install EOSIO inside the VM
gcloud compute ssh my-vm-1 --zone=us-east4-c --command="bash -s" <<'EOF'
sudo apt update
curl -LO https://github.com/eosio/eos/releases/download/v2.1.0/eosio_2.1.0-1-ubuntu-20.04_amd64.deb
sudo apt install -y ./eosio_2.1.0-1-ubuntu-20.04_amd64.deb
nodeos --version && cleos version client && keosd -v
nodeos -e -p eosio --plugin eosio::chain_api_plugin --plugin eosio::history_api_plugin --contracts-console >> nodeos.log 2>&1 &
sleep 5 && tail -n 5 nodeos.log
cleos wallet create --name my_wallet --file my_wallet_password
export wallet_password=\$(cat my_wallet_password)
cleos wallet unlock --name my_wallet --password \$wallet_password
cleos wallet import --name my_wallet --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
curl -LO https://github.com/eosio/eosio.cdt/releases/download/v1.8.1/eosio.cdt_1.8.1-1-ubuntu-20.04_amd64.deb
sudo apt install -y ./eosio.cdt_1.8.1-1-ubuntu-20.04_amd64.deb
eosio-cpp --version
cleos create key --file my_keypair1
prv=\$(grep "Private key:" my_keypair1 | cut -d ' ' -f 3)
pub=\$(grep "Public key:" my_keypair1 | cut -d ' ' -f 3)
cleos wallet import --name my_wallet --private-key \$prv
cleos create account eosio bob \$pub
echo "✅ EOSIO setup complete on VM!"
EOF
