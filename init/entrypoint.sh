#!/bin/bash
set -e

# Check if ENV and NODE_ID are set, otherwise default to 'dev' and 'node1'
ENV=${ENV:-dev}
NODE_ID=${NODE_ID:-node1}

# Start Vault in the background with the appropriate config file
vault server -config=/vault/config/$ENV/$NODE_ID/vault.hcl &

# Wait for Vault to be ready
sleep 5

# Initialize and unseal Vault on the first node
if [ "$NODE_ID" == "node1" ]; then
#  # Initialize Vault only if it's not already initialized
  if ! vault status -format=json | jq -e .initialized; then
    vault operator init -key-shares=1 -key-threshold=1 > /vault/init/keys.txt
  fi
#  vault operator init -key-shares=1 -key-threshold=1 > /vault/init/keys.txt
  UNSEAL_KEY=$(grep 'Unseal Key 1:' /vault/init/keys.txt | awk '{print $NF}')
  ROOT_TOKEN=$(grep 'Initial Root Token:' /vault/init/keys.txt | awk '{print $NF}')
  export VAULT_TOKEN=$ROOT_TOKEN
  # Unseal Vault if it's sealed
  if vault status -format=json | jq -e .sealed; then
    vault operator unseal $UNSEAL_KEY
  fi


  # Run the common configuration script
  /vault/init/common/configure_vault.sh $ENV
else
  # For other nodes, wait for the leader to be ready and join the cluster
  sleep 10
  if vault status | grep -q 'Sealed'; then
      UNSEAL_KEY=$(grep 'Unseal Key 1:' /vault/init/keys.txt | awk '{print $NF}')
      vault operator unseal $UNSEAL_KEY
  fi

fi

# Bring Vault to foreground
wait
