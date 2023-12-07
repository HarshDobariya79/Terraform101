provider "oci" {
  tenancy_ocid = var.TENACY_OCID
  user_ocid = var.USER_OCID
  private_key_path = var.PRIVATE_KEY_PATH
  fingerprint = var.FINGERPRINT
  region = var.REGION
}