resource "random_string" "token_id" {
  length  = 6
  special = false
  upper   = false
  numeric = true
  lower   = true
}

resource "random_string" "token_secret" {
  length  = 16
  special = false
  upper   = false
  numeric = true
  lower   = true
}

locals {
  kubeadm_token = "${random_string.token_id.result}.${random_string.token_secret.result}"
}
