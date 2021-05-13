data "vsphere_datacenter" "dc" {
  name = "Dev-Datacenter1"
}

data "vsphere_datastore" "datastore" {
  name          = "Unity-350f-Lun01"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "Dev1-Cluster/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network2" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "seg-01"
  
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template2" {
  name          = "KP-Ubuntu20.04"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "KP-tf"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"  

  provisioner "remote-exec" {
    connection {
      user        = "root"
      password    = "VMware123!@#"
      type        = "ssh"
      host        = "172.10.0.121"
      private_key = file("~/.ssh/id_rsa")
      timeout     = "2m"
  }
    inline = [
	"mkdir /Users/kpkim/desktop/abc",
    ]
  }
  
  num_cpus = 2
  memory   = 1024
  guest_id = "${data.vsphere_virtual_machine.template2.guest_id}"

  scsi_type = "${data.vsphere_virtual_machine.template2.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template2.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template2.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template2.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template2.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template2.id}"

    customize {
      linux_options {
        host_name = "terraform-test"
        domain    = "test.internal"
      }

      network_interface {
        ipv4_address="192.168.100.57"
        ipv4_netmask=24


      }
     ipv4_gateway="192.168.100.1"

    }
  }
}
