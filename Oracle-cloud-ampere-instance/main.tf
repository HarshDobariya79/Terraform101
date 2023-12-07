resource "oci_core_instance" "always_free" {
  availability_domain = var.AD
  compartment_id      = var.COMPARTMENT_ID
  shape               = var.SHAPE

  shape_config {
    ocpus         = var.OCPUS
    memory_in_gbs = var.MEMORY
  }

  create_vnic_details {
    subnet_id = var.SUBNET_ID
  }

  source_details {
    source_type = "image"
    source_id = var.IMAGE_ID
  }

  metadata = {
    ssh_authorized_keys = file(var.PUBLIC_KEY_PATH)
  }
}
