resource "kubernetes_deployment" "sleepybox" {
  metadata {
    name = "sleepybox"
    labels = {
      app = "sleepybox"
    }
  }

  spec {
    replicas = var.deployment_size

    selector {
      match_labels = {
        app = "sleepybox"
      }
    }

    template {
      metadata {
        labels = {
          app = "sleepybox"
        }
      }

      spec {
        node_selector = {
          "kubernetes.azure.com/agentpool" = "scaled"
        }
        container {
          image   = var.deployment_container
          name    = "sleepybox"
          command = ["/bin/sh", "-c", "--"]
          args    = ["echo `date` --- sleepytime; while true; do echo `date` --- sleeping 1 hour && sleep 3600; done"]

          resources {
            limits = {
              cpu    = "1500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "1500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}
