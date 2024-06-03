path "secret/data/+/offline-token" {
  capabilities = ["read"]
}

path "secret/metadata/+/*" {
  capabilities = ["list"]
}