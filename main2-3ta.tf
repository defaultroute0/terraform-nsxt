# Configure the VMware NSX Provider
terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
    }
  }
}

provider "nsxt" {
    host = "fqdn here"
    username = "username"
    password = "xxx"
    allow_unverified_ssl = true
}

# Apply Tags:
    # Scope:Tag
        # app:3-tier-app
        # tier:web
        # tier:app
        # tier:db
        # env:prod

# VM's with ID's:
    # Web01 - 503e1f48-7d08-6809-4a70-6ded706cffc4
    # Web02 - 503ef86f-1b6d-38ac-7ea8-b7ad121b5b36
    # App01 - 503e664a-a4b1-0c05-27f1-f5e4f59c8900
    # App02 - 503e481b-6e49-99d2-61e3-f2522da3c54d
    # DB01 - 503ef0f3-16de-90fd-8016-5e035003fb6f

# Web01:
resource "nsxt_policy_vm_tags" "web01_prd_tags" {
  instance_id = "503e1f48-7d08-6809-4a70-6ded706cffc4"

  tag {
    scope = "app"
    tag   = "3-tier-app"
  }

    tag {
    scope = "tier"
    tag   = "web"
  }

  tag {
    scope = "env"
    tag   = "prd"
  }

}

# Web02:
resource "nsxt_policy_vm_tags" "web02_prd_tags" {
  instance_id = "503ef86f-1b6d-38ac-7ea8-b7ad121b5b36"

  tag {
    scope = "app"
    tag   = "3-tier-app"
  }

    tag {
    scope = "tier"
    tag   = "web"
  }

  tag {
    scope = "env"
    tag   = "prd"
  }

}

# App01:
resource "nsxt_policy_vm_tags" "app01_prd_tags" {
  instance_id = "503e664a-a4b1-0c05-27f1-f5e4f59c8900"

  tag {
    scope = "app"
    tag   = "3-tier-app"
  }

    tag {
    scope = "tier"
    tag   = "app"
  }

  tag {
    scope = "env"
    tag   = "prd"
  }

}

# App02:
resource "nsxt_policy_vm_tags" "app02_prd_tags" {
  instance_id = "503e481b-6e49-99d2-61e3-f2522da3c54d"

  tag {
    scope = "app"
    tag   = "3-tier-app"
  }

    tag {
    scope = "tier"
    tag   = "app"
  }

  tag {
    scope = "env"
    tag   = "prd"
  }

}

# DB01:
resource "nsxt_policy_vm_tags" "db01_prd_tags" {
  instance_id = "503ef0f3-16de-90fd-8016-5e035003fb6f"

  tag {
    scope = "app"
    tag   = "3-tier-app"
  }

    tag {
    scope = "tier"
    tag   = "db"
  }

  tag {
    scope = "env"
    tag   = "prd"
  }

}

# DFW Demo Security Groups:
  # dfw-3-tier-app-prd-app-lb - app tier lb vip
  # dfw-3-tier-app-prd-app-snat - app tier lb snat
  # dfw-3-tier-app - all VM's and IP's
  # dfw-3-tier-app-prd - all prd VM's
  # dfw-3-tier-app-prd-web - all web prd VM's
  # dfw-3-tier-app-prd-app - all app prd VM's
  # dfw-3-tier-app-prd-db - all db prd VM's

# App Tier LB VIP Group
resource "nsxt_policy_group" "dfw-3-tier-app-prd-app-lb" {
    display_name = "DFW-3-Tier-App-Prd-App-LB"
    description = "Security Group covering Prod App LB 3-Tier-App"

    criteria {
      ipaddress_expression {
        ip_addresses = ["40.40.40.200"]
    }
  }
}

# App Tier LB SNAT Group
resource "nsxt_policy_group" "dfw-3-tier-app-prd-app-snat" {
    display_name = "DFW-3-Tier-App-Prd-App-SNAT"
    description = "Security Group covering Prod App SNAT 3-Tier-App"

    criteria {
      ipaddress_expression {
        ip_addresses = ["100.64.184.1"]
    }
  }
}

# DFW-3-tier-app group
resource "nsxt_policy_group" "dfw-3-tier-app" {
    display_name = "DFW-3-Tier-App"
    description = "Security Group covering 3-Tier-App VMs across all environments"

    criteria {
        condition {
            key = "Tag"
            member_type = "VirtualMachine"
            operator = "EQUALS"
            value = "app|3-tier-app"
        }
    }
}

# DFW-3-tier-app-prd group
resource "nsxt_policy_group" "dfw-3-tier-app-prd" {
    display_name = "DFW-3-Tier-App-Prd"
    description = "Security Group covering Prod 3-Tier-App VMs across all environments"

    criteria {
        condition {
            key = "Tag"
            member_type = "VirtualMachine"
            operator = "EQUALS"
            value = "app|3-tier-app"
        }
        condition {
            key = "Tag"
            member_type = "VirtualMachine"
            operator = "EQUALS"
            value = "env|prd"
        }
    }
    conjunction {
      operator = "OR"
    }
    criteria {
      path_expression {
        member_paths = [nsxt_policy_group.dfw-3-tier-app-prd-app-lb.path]
      }
    }
    conjunction {
      operator = "OR"
    }
    criteria {
      path_expression {
        member_paths = [nsxt_policy_group.dfw-3-tier-app-prd-app-snat.path]
      }
    }
}

# DFW-3-tier-app-prd-web group
resource "nsxt_policy_group" "dfw-3-tier-app-prd-web" {
    display_name = "DFW-3-Tier-App-Prd-Web"
    description = "Security Group covering Prod Web 3-Tier-App VMs across all environments"

    criteria {
        condition {
            key = "Tag"
            member_type = "VirtualMachine"
            operator = "EQUALS"
            value = "app|3-tier-app"
        }
        condition {
            key = "Tag"
            member_type = "VirtualMachine"
            operator = "EQUALS"
            value = "env|prd"
        }
        condition {
            key = "Tag"
            member_type = "VirtualMachine"
            operator = "EQUALS"
            value = "tier|web"
        }
    }
}

# DFW-3-tier-app-prd-app group
resource "nsxt_policy_group" "dfw-3-tier-app-prd-app" {
    display_name = "DFW-3-Tier-App-Prd-App"
    description = "Security Group covering Prod App 3-Tier-App VMs across all environments"

    criteria {
        condition {
            key = "Tag"
            member_type = "VirtualMachine"
            operator = "EQUALS"
            value = "app|3-tier-app"
        }
        condition {
            key = "Tag"
            member_type = "VirtualMachine"
            operator = "EQUALS"
            value = "env|prd"
        }
        condition {
            key = "Tag"
            member_type = "VirtualMachine"
            operator = "EQUALS"
            value = "tier|app"
        }
    }
}

# DFW-3-tier-app-prd-db group
resource "nsxt_policy_group" "dfw-3-tier-app-prd-db" {
    display_name = "DFW-3-Tier-App-Prd-DB"
    description = "Security Group covering Prod DB 3-Tier-App VMs across all environments"

    criteria {
        condition {
            key = "Tag"
            member_type = "VirtualMachine"
            operator = "EQUALS"
            value = "app|3-tier-app"
        }
        condition {
            key = "Tag"
            member_type = "VirtualMachine"
            operator = "EQUALS"
            value = "env|prd"
        }
        condition {
            key = "Tag"
            member_type = "VirtualMachine"
            operator = "EQUALS"
            value = "tier|db"
        }
    }
}

# Services
  # HTTP - tcp/80
  # MySQL - tcp/3306

# HTTP
resource "nsxt_policy_service" "HTTP_80" {
  description  = "HTTP on TCP port 80"
  display_name = "HTTP_80"

  l4_port_set_entry {
    display_name      = "HTTP_80"
    description       = "TCP port 80 entry"
    protocol          = "TCP"
    destination_ports = ["80"]
  }
}

# MySQL
resource "nsxt_policy_service" "MySQL_3306" {
  description  = "MySQL on TCP port 3306"
  display_name = "MySQL_3306"

  l4_port_set_entry {
    display_name      = "MySQL_3306"
    description       = "TCP port 3306 entry"
    protocol          = "TCP"
    destination_ports = ["3306"]
  }
}

# Policies and Rules
# Application Category
# Any to Web Tier
resource "nsxt_policy_security_policy" "dfw-3-tier-app-prd-policy" {
  display_name = "Prod 3 Tier App Segmentation Policy"
  description  = "Rules to allow 3 Tier App inter-communication"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = false
  # Limiting to group dfw-3-tier-app-prd
  scope        = [nsxt_policy_group.dfw-3-tier-app-prd.path]

  rule {
    display_name       = "Any access to Web Tier"
    destination_groups = [nsxt_policy_group.dfw-3-tier-app-prd-web.path]
    action             = "ALLOW"
    logged             = true
    disabled           = false
    scope              = [nsxt_policy_group.dfw-3-tier-app-prd.path]
    services           = [nsxt_policy_service.HTTP_80.path]
    profiles           = [var.HTTP]
    log_label          = "3ta_prd_any_to_web"
  }
  rule {
    display_name       = "Web Tier to App Tier LB VIP access"
    source_groups      = [nsxt_policy_group.dfw-3-tier-app-prd-web.path]
    destination_groups = [nsxt_policy_group.dfw-3-tier-app-prd-app-lb.path]
    action             = "ALLOW"
    logged             = true
    disabled           = false
    scope              = [nsxt_policy_group.dfw-3-tier-app-prd.path]
    services           = [nsxt_policy_service.HTTP_80.path]
    profiles           = [var.HTTP]
    log_label          = "3ta_prd_web_to_app_lb"
  }
  rule {
    display_name       = "LB SNAT to App Tier access"
    source_groups      = [nsxt_policy_group.dfw-3-tier-app-prd-app-snat.path]
    destination_groups = [nsxt_policy_group.dfw-3-tier-app-prd-app.path]
    action             = "ALLOW"
    logged             = true
    disabled           = false
    scope              = [nsxt_policy_group.dfw-3-tier-app-prd.path]
    services           = [nsxt_policy_service.HTTP_80.path]
    profiles           = [var.HTTP]
    log_label          = "3ta_prd_snat_to_app"
  }
  rule {
    display_name       = "App Tier to DB Tier access"
    source_groups      = [nsxt_policy_group.dfw-3-tier-app-prd-app.path]
    destination_groups = [nsxt_policy_group.dfw-3-tier-app-prd-db.path]
    action             = "ALLOW"
    logged             = true
    disabled           = false
    scope              = [nsxt_policy_group.dfw-3-tier-app-prd.path]
    services           = [nsxt_policy_service.MySQL_3306.path]
    profiles           = [var.MYSQL]
    log_label          = "3ta_prd_app_to_db"
  }
  rule {
    display_name       = "Deny all to 3 Tier App"
    destination_groups = [nsxt_policy_group.dfw-3-tier-app-prd.path]
    action             = "DROP"
    logged             = true
    disabled           = false
    scope              = [nsxt_policy_group.dfw-3-tier-app-prd.path]
    log_label          = "3ta_prd_drop_to_3ta"
  }
  rule {
    display_name       = "Deny all from 3 Tier App"
    source_groups = [nsxt_policy_group.dfw-3-tier-app-prd.path]
    action             = "DROP"
    logged             = true
    disabled           = false
    scope              = [nsxt_policy_group.dfw-3-tier-app-prd.path]
    log_label          = "3ta_prd_drop_from_3ta"
  }
}
