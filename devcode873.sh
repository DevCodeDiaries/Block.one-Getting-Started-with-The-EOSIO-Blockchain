#!/bin/bash
echo "🌟 Pulling EOSIO Docker image v2.0.13..."
docker pull eosio/eos:v2.0.13

echo "🚀 Running EOSIO container..."
docker run --name eosio-container -d -p 8888:8888 -p 9876:9876 eosio/eos:v2.0.13 \
  /bin/bash -c "nodeos -e -p eosio \
  --plugin eosio::producer_plugin \
  --plugin eosio::chain_api_plugin \
  --plugin eosio::http_plugin \
  --access-control-allow-origin='*' \
  --contracts-console \
  --http-validate-host=false"

echo "✅ EOSIO Docker container is running!"
