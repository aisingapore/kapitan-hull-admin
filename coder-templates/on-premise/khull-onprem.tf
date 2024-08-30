terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

locals {
  namespace             = "runai-proj"
  common_pvc_name       = "pvc-data"
  codeserver_image_repo = "registry.aisingapore.net/mlops-pub/code-server:stable"
  common_pvc_path       = "/pvc-data"
  # Uncomment the node_selector block in main.spec.template.spec if it is to be used
  #node_selector_key     = ""
  #node_selector_value   = ""
}

provider "coder" {
}

variable "use_kubeconfig" {
  type        = bool
  description = <<-EOF
  Use host kubeconfig? (true/false)

  Set this to false if the Coder host is itself running as a Pod on the same
  Kubernetes cluster as you are deploying workspaces to.

  Set this to true if the Coder host is running outside the Kubernetes cluster
  for workspaces.  A valid "~/.kube/config" must be present on the Coder host.
  EOF
  default     = false
}

data "coder_parameter" "cpu" {
  name         = "cpu"
  display_name = "CPU"
  description  = "The number of CPU cores"
  default      = "2"
  icon         = "/icon/memory.svg"
  mutable      = true
  option {
    name  = "2 Cores"
    value = "2"
  }
  option {
    name  = "4 Cores"
    value = "4"
  }
  option {
    name  = "6 Cores"
    value = "6"
  }
  option {
    name  = "8 Cores"
    value = "8"
  }
}

data "coder_parameter" "memory" {
  name         = "memory"
  display_name = "Memory"
  description  = "The amount of memory in GB"
  default      = "4"
  icon         = "/icon/memory.svg"
  mutable      = true
  option {
    name  = "4 GB"
    value = "4"
  }
  option {
    name  = "8 GB"
    value = "8"
  }
  option {
    name = "16 GB"
    value = "16"
  }
}

provider "kubernetes" {
  # Authenticate via ~/.kube/config or a Coder-specific ServiceAccount, depending on admin preferences
  config_path = var.use_kubeconfig == true ? "~/.kube/config" : null
}

data "coder_workspace" "me" {}
data "coder_workspace_owner" "user" {}

resource "coder_agent" "main" {
  os             = "linux"
  arch           = "amd64"
  startup_script =<<-EOT
    #!/bin/bash
    set -e

    if [[ ! -f /home/coder/.bashrc ]]; then
      echo "Unable to find user profile in home directory, initialising home directory..."
      cp -R /etc/skel/. /home/coder/
      sudo chown coder:coder -R /home/coder/
      /miniconda3/bin/conda init bash
    fi

    if ! grep -q 'export PATH=${local.common_pvc_path}/utils:$PATH' "/home/coder/.bashrc"; then
      echo "Unable to find PATH import in user profile, appending PATH..."
      echo 'export PATH=${local.common_pvc_path}/utils:$PATH' >> /home/coder/.bashrc
    fi

    if ! grep -q 'export PIP_CACHE_DIR=${local.common_pvc_path}/.pip/cache' "/home/coder/.bashrc"; then
      echo "Unable to find PIP_CACHE_DIR in user profile, appending env var..."
      echo 'export PIP_CACHE_DIR=${local.common_pvc_path}/.pip/cache' >> /home/coder/.bashrc
    fi

    if ! grep -q 'export HF_DATASETS_CACHE=${local.common_pvc_path}/.huggingface/datasets' "/home/coder/.bashrc"; then
      echo "Unable to find HF_DATASETS_CACHE in user profile, appending env var..."
      echo 'export HF_DATASETS_CACHE=${local.common_pvc_path}/.huggingface/datasets' >> /home/coder/.bashrc
    fi

    if [[ ! -d /home/coder/.runai_config ]]; then
      echo "Unable to find runai configuration in home directory, initialising runai configuration file..."
      mkdir -p /home/coder/.runai_config
      cp /etc/runai/runai-sso.yaml /home/coder/.runai_config/
      sudo chown -R coder:coder /home/coder/.runai_config
    fi

    if [[ ! -f /home/coder/.condarc ]]; then
      echo "Unable to find conda configuration in home directory, initialising conda configuration file..."
      /miniconda3/bin/conda config --append pkgs_dirs ${local.common_pvc_path}/.conda/pkgs/
      /miniconda3/bin/conda config --append envs_dirs ${local.common_pvc_path}/.conda/envs/
      /miniconda3/bin/conda config --set env_prompt '({name})'
    fi

    if [[ ! -f /home/coder/config.json ]]; then
      echo "Unable to find image repository credentials in home directory, writing credential file (read-only).."
      echo -n $HARBOR_CREDENTIALS >> /home/coder/config.json
      sudo chmod 400 /home/coder/config.json
    fi
    
    /usr/bin/code-server --disable-telemetry --auth none --port 13337 >/tmp/code-server.log 2>&1 &

  EOT
  # The following metadata blocks are optional. They are used to display
  # information about your workspace in the dashboard. You can remove them
  # if you don't want to display any information.
  # For basic resources, you can use the `coder stat` command.
  # If you need more control, you can write your own script.
  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Home Disk"
    key          = "2_home_disk"
    script       = "coder stat disk --path /home/coder"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "Common Workspace Disk"
    key          = "3_workspace_disk"
    script       = "coder stat disk --prefix Ti --path ${local.common_pvc_path}"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "CPU Usage (Host)"
    key          = "4_cpu_usage_host"
    script       = "coder stat cpu --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Memory Usage (Host)"
    key          = "5_mem_usage_host"
    script       = "coder stat mem --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Load Average (Host)"
    key          = "6_load_host"
    # get load avg scaled by number of cores
    script       = <<EOT
      echo "`cat /proc/loadavg | awk '{ print $1 }'` `nproc`" | awk '{ printf "%0.2f", $1/$2 }'
    EOT
    interval     = 60
    timeout      = 1
  }
}

# code-server
resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "code-server"
  icon         = "/icon/code.svg"
  url          = "http://localhost:13337?folder=/home/coder"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 3
    threshold = 10
  }
}

resource "kubernetes_persistent_volume_claim" "home" {
  metadata {
    name      = "coder-${lower(data.coder_workspace.me.name)}"
    namespace = local.namespace
    labels    = {
      "app.kubernetes.io/name"     = "coder-user-pvc"
      "app.kubernetes.io/instance" = "coder-pvc-${lower(data.coder_workspace.me.name)}"
      "app.kubernetes.io/part-of"  = "coder"
      // Coder-specific labels
      "com.coder.resource"         = "true"
      "com.coder.workspace.id"     = data.coder_workspace.me.id
      "com.coder.workspace.name"   = data.coder_workspace.me.name
      "com.coder.user.id"          = data.coder_workspace_owner.user.id
      "com.coder.user.username"    = data.coder_workspace_owner.user.name
    }
    annotations = {
      "com.coder.user.email"       = data.coder_workspace_owner.user.email
    }
  }
  wait_until_bound = false
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "8Gi"
      }
    }
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "kubernetes_deployment" "main" {
  count      = data.coder_workspace.me.start_count
  depends_on = [
    kubernetes_persistent_volume_claim.home
  ]
  wait_for_rollout = false
  metadata {
    name      = "coder-${lower(data.coder_workspace_owner.user.name)}-${lower(data.coder_workspace.me.name)}"
    namespace = local.namespace
    labels    = {
      "app.kubernetes.io/name"     = "coder-workspace"
      "app.kubernetes.io/instance" = "coder-workspace-${lower(data.coder_workspace_owner.user.name)}-${lower(data.coder_workspace.me.name)}"
      "app.kubernetes.io/part-of"  = "coder"
      "com.coder.resource"         = "true"
      "com.coder.workspace.id"     = data.coder_workspace.me.id
      "com.coder.workspace.name"   = data.coder_workspace.me.name
      "com.coder.user.id"          = data.coder_workspace_owner.user.id
      "com.coder.user.username"    = data.coder_workspace_owner.user.name
    }
    annotations = {
      "com.coder.user.email"       = data.coder_workspace_owner.user.email
    }
  }

  spec {
    # replicas = data.coder_workspace.me.start_count
    replicas = 1
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "coder-workspace-${lower(data.coder_workspace_owner.user.name)}-${lower(data.coder_workspace.me.name)}"
      }
    }
    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "coder-workspace-${lower(data.coder_workspace_owner.user.name)}-${lower(data.coder_workspace.me.name)}"
        }
      }
      spec {
        security_context {
          run_as_user            = 2222
          fs_group               = 2222
          fs_group_change_policy = "OnRootMismatch"
        }
        #node_selector = {
        #  (local.node_selector_key) = local.node_selector_value
        #}
        init_container {
          name    = "runai-init"
          image   = "busybox:1.36"
          command = ["/bin/sh", "-c", "cp /secrets/runai-sso.yaml /etc/runai/runai-sso.yaml && chmod 0766 /etc/runai/runai-sso.yaml"]
          volume_mount {
            mount_path = "/secrets"
            name       = "from-secret"
          }
          volume_mount {
            mount_path = "/etc/runai"
            name       = "common-mount"
          }
        }
        container {
          name              = "dev"
          image             = local.codeserver_image_repo
          image_pull_policy = "Always"
          command           = ["bash", "-c", coder_agent.main.init_script]
          security_context {
            run_as_user = "2222"
          }
          env {
            name  = "CODER_AGENT_TOKEN"
            value = coder_agent.main.token
          }
          env {
            name  = "KUBECONFIG"
            value = "/home/coder/.runai_config/runai-sso.yaml"
          }
          env {
            name = "AWS_ACCESS_KEY_ID"
            value_from {
              secret_key_ref {
                name = "s3-credentials"
                key  = "accessKeyId"
              }
            }
          }
          env {
            name = "AWS_SECRET_ACCESS_KEY"
            value_from {
              secret_key_ref {
                name = "s3-credentials"
                key  = "secretAccessKey"
              }
            }
          }
          env {
            name = "S3_ENDPOINT_URL"
            value_from {
              secret_key_ref {
                name = "s3-credentials"
                key  = "ecsS3EndpointURL"
              }
            }
          }
          env {
            name = "HARBOR_CREDENTIALS"
            value_from {
              secret_key_ref {
                name = "harbor-credentials"
                key  = ".dockerconfigjson"
              }
            }
          }
          resources {
            requests = {
              "cpu"    = "250m"
              "memory" = "${data.coder_parameter.memory.value}Gi"
            }
            limits = {
              "cpu"    = "${data.coder_parameter.cpu.value}"
              "memory" = "${data.coder_parameter.memory.value}Gi"
            }
          }
          volume_mount {
            mount_path = "${local.common_pvc_path}"
            name       = "workspace"
            read_only  = "false"
          }
          volume_mount {
            mount_path = "/etc/runai"
            name       = "common-mount"
          }
          volume_mount {
            mount_path = "/home/coder"
            name       = "home"
          }
        }
        volume {  
          name = "workspace"
          persistent_volume_claim {
            claim_name = "${local.common_pvc_name}"
            read_only  = false
          }
        }
        volume {
          name = "home"
          persistent_volume_claim {
            claim_name = "${kubernetes_persistent_volume_claim.home.metadata[0].name}"
            read_only  = false
          }
        }
        volume {
          name = "common-mount"
          empty_dir {}
        }
        volume {
          name = "from-secret"
          secret {
            secret_name = "runai-sso"
            optional    = false
          }
        }
        affinity {
          // This affinity attempts to spread out all workspace pods evenly across
          // nodes.
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 1
              pod_affinity_term {
                topology_key = "kubernetes.io/hostname"
                label_selector {
                  match_expressions {
                    key      = "app.kubernetes.io/name"
                    operator = "In"
                    values   = ["coder-workspace"]
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
