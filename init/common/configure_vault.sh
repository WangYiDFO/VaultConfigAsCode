#!/bin/bash
set -e

# Function to load all policy files
load_policies() {
  local ENV=$1
  local POLICY_DIR="/vault/init/$ENV/policies"

  if [ -d "$POLICY_DIR" ]; then
    for policy_file in "$POLICY_DIR"/*.hcl; do
      policy_name=$(basename "$policy_file" .hcl)
      echo "Loading policy: $policy_name from $policy_file"
      vault policy write "$policy_name" "$policy_file"
    done
  else
    echo "Policy directory $POLICY_DIR does not exist"
  fi
}

# Function to configure auth methods and roles
configure_auth_methods() {
  local ENV=$1
  local AUTH_DIR="/vault/init/$ENV/auth"

  if [ -d "$AUTH_DIR" ]; then
    for auth_instance in "$AUTH_DIR"/*/*; do
      if [ -d "$auth_instance" ]; then
        local AUTH_PATH=$(basename $(dirname "$auth_instance"))
        local AUTH_TYPE=$(basename "$auth_instance")
        local CONFIG_FILE="$auth_instance/config.json"
        local ROLE_DIR="$auth_instance/roles"

        if [ -f "$CONFIG_FILE" ]; then
          echo "Configuring $AUTH_TYPE auth at path $AUTH_PATH from $CONFIG_FILE"
          if ! vault auth list -format=json | jq -e "has(\"${AUTH_PATH}/\")"; then
            echo "Enabling auth method at path: ${AUTH_PATH}"
            vault auth enable -path=${AUTH_PATH} ${AUTH_TYPE}
          else
            echo "Auth method at path ${AUTH_PATH} is already enabled"
          fi
          echo "Config auth method at path ${AUTH_PATH}, using $CONFIG_FILE"
          vault write auth/${AUTH_PATH}/config @${CONFIG_FILE}
        fi

        if [ -d "$ROLE_DIR" ]; then
          for role_file in "$ROLE_DIR"/*.json; do
            role_name=$(basename "$role_file" .json)
            echo "Creating $AUTH_TYPE role: $role_name from $role_file"
            vault write auth/${AUTH_PATH}/role/${role_name} @${role_file}
          done
        fi
      fi
    done
  else
    echo "Auth configuration directory $AUTH_DIR does not exist"
  fi
}

# Load common policies
vault policy write admin-policy /vault/init/common/policies/admin-policy.hcl

# Create an admin role with the admin policy
vault write auth/token/roles/admin-role allowed_policies="admin-policy"

# Load environment-specific policies
load_policies "$ENV"

# Configure auth methods and roles
configure_auth_methods "$ENV"


