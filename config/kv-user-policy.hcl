path "secret/data/{{identity.entity.id}}/*" {
  capabilities = ["create", "update", "patch", "read", "delete"]
}

path "secret/metadata/{{identity.entity.id}}/*" {
  capabilities = ["list"]
}