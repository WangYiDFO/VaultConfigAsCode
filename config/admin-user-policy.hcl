# Enable and manage auth methods
path "sys/auth/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage policies
path "sys/policies/acl/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage roles
path "auth/token/roles/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage auth backends and their configurations
path "auth/*/config" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# List existing policies
path "sys/policies/acl" {
  capabilities = ["list"]
}

# Manage auth backends and their roles
path "auth/*/roles/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage identity entities and groups
path "identity/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Deny all access to secret paths, Explicit deny access, add more Denies here
path "secret/*" {
  capabilities = ["deny"]
}
