provider "vsphere" {
  user           = "administrator@vsphere.local"
  password       = "Kvmware1!"
  vsphere_server = "172.10.0.100"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}
