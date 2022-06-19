# ----------------------------------------------------------------------------
# Name:         rhel9.pkr.hcl
# Description:  Build definition for RedHat Enterprise Linux 8
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         24/01/2022
# ----------------------------------------------------------------------------

# -------------------------------------------------------------------------- #
#                           Packer Configuration                             #
# -------------------------------------------------------------------------- #
packer {
    required_version = ">= 1.7.7"
    required_plugins {
        vsphere = {
            version = ">= v1.0.2"
            source  = "github.com/hashicorp/vsphere"
        }
    }
}

# -------------------------------------------------------------------------- #
#                              Local Variables                               #
# -------------------------------------------------------------------------- #
locals {
    build_version   = formatdate("YY.MM", timestamp())
    build_date      = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
}

# -------------------------------------------------------------------------- #
#                       Template Source Definitions                          #
# -------------------------------------------------------------------------- #
source "vsphere-iso" "rhel9" {
    # vCenter
    vcenter_server              = var.vcenter_server
    username                    = var.vcenter_username
    password                    = var.vcenter_password
    insecure_connection         = var.vcenter_insecure
    datacenter                  = var.vcenter_datacenter
    #cluster                     = var.vcenter_cluster
    host                        = var.vcenter_host
    #folder                      = var.vcenter_folder
    datastore                   = var.vcenter_datastore

    # Content Library and Template Settings
    convert_to_template         = var.vcenter_convert_template
    create_snapshot             = var.vcenter_snapshot
    snapshot_name               = var.vcenter_snapshot_name
#    dynamic "content_library_destination" {
#        for_each = var.vcenter_content_library != null ? [1] : []
#            content {
#                library         = var.vcenter_content_library
#                name            = "${ source.name }"
#                ovf             = var.vcenter_content_library_ovf
#                destroy         = var.vcenter_content_library_destroy
#                skip_import     = var.vcenter_content_library_skip
#            }
#    }

    # Virtual Machine
    guest_os_type               = var.vm_guestos_type
    vm_name                     = "${ source.name }-${ local.build_version }"
    notes                       = "VER: ${ local.build_version }\nDATE: ${ local.build_date }"
    firmware                    = var.vm_firmware
    CPUs                        = var.vm_cpu_sockets
    cpu_cores                   = var.vm_cpu_cores
    CPU_hot_plug                = var.vm_cpu_hotadd
    RAM                         = var.vm_mem_size
    RAM_hot_plug                = var.vm_mem_hotadd
    cdrom_type                  = var.vm_cdrom_type
    remove_cdrom                = var.vm_cdrom_remove
    disk_controller_type        = var.vm_disk_controller
    storage {
        disk_size               = var.vm_disk_size
        disk_thin_provisioned   = var.vm_disk_thin
    }
    network_adapters {
        network                 = var.vcenter_network
        network_card            = var.vm_nic_type
    }

    # Removeable Media
    iso_paths                   = ["[${ var.os_iso_datastore }] ${ var.os_iso_path }/${ var.os_iso_file }"]

    # Boot and Provisioner
    http_directory              = var.http_directory
    http_port_min               = var.http_port_min
    http_port_max               = var.http_port_max
    boot_order                  = var.vm_boot_order
    boot_wait                   = var.vm_boot_wait
    boot_command                = [
                                    "<up><tab> ip=10.221.216.75::10.221.216.1:255.255.248.0:packervm1:ens192:none nameserver=172.16.8.32 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${ var.http_file }",
                                    "<wait><enter>" ]
    ip_wait_timeout             = var.vm_ip_timeout
    communicator                = "ssh"
    ssh_username                = var.build_username
    ssh_password                = var.build_password
    shutdown_command            = "sudo shutdown -P now"
    shutdown_timeout            = var.vm_shutdown_timeout
}

# -------------------------------------------------------------------------- #
#                             Build Management                               #
# -------------------------------------------------------------------------- #
build {
    # Build sources
    sources                 = [ "source.vsphere-iso.rhel9" ]

    # Shell Provisioner to execute scripts
    provisioner "shell" {
        execute_command     = "echo '${ var.build_password }' | {{.Vars}} sudo -E -S sh -eu '{{.Path}}'"
        expect_disconnect = "true"
        start_retry_timeout = "30m"
  #      environment_vars    = [ "RHSM_USER=${ var.rhsm_user }",
  #                              "RHSM_PASS=${ var.rhsm_pass }" ]
        scripts             = var.script_files
    }

    post-processor "manifest" {
        output              = "manifest.txt"
        strip_path          = true
        custom_data         = {
                                vcenter_fqdn    = "${ var.vcenter_server }"
                                vcenter_folder  = "${ var.vcenter_folder }"
                                iso_file        = "${ var.os_iso_file }"
                                build_repo      = "${ var.build_repo }"
                                build_branch    = "${ var.build_branch }"
        }
    }
}
