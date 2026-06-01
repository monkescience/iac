# State (and plan) encryption — this component keeps a committed local state in a
# public repo, so the state is encrypted at rest. The passphrase is NOT stored here;
# it is supplied via the TF_ENCRYPTION env var (see the Makefile / TOFU_STATE_PASSPHRASE).
terraform {
  encryption {
    key_provider "pbkdf2" "default" {}

    method "aes_gcm" "default" {
      keys = key_provider.pbkdf2.default
    }

    state {
      method = method.aes_gcm.default
    }

    plan {
      method = method.aes_gcm.default
    }
  }
}
