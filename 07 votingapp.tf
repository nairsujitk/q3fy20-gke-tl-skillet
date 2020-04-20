resource "kubernetes_pod" "voting_app_pod" {
  metadata {
    name = "voting-app-pod"

    labels = {
      app = "voting-app"

      name = "voting-app-pod"
    }
  }

  spec {
    container {
      name  = "voting-app"
      image = "dockersamples/examplevotingapp_vote"

      port {
        container_port = 80
      }
    }
  }
  depends_on = [null_resource.delay_pod_creation]
}

resource "kubernetes_service" "voting_service" {
  metadata {
    name = "voting-service"

    labels = {
      app = "voting-app"

      name = "voting-service"
    }
  }

  spec {
    port {
      port        = 80
      target_port = "80"
    }

    selector = {
      app = "voting-app"

      name = "voting-app-pod"
    }

    type = "LoadBalancer"
  }
  depends_on = [null_resource.delay_pod_creation]
}

resource "kubernetes_pod" "redis_pod" {
  metadata {
    name = "redis-pod"

    labels = {
      app = "voting-app"

      name = "redis-pod"
    }
  }

  spec {
    container {
      name  = "redis"
      image = "redis"

      port {
        container_port = 6379
      }
    }
  }
  depends_on = [null_resource.delay_pod_creation]
}

resource "kubernetes_service" "redis" {
  metadata {
    name = "redis"

    labels = {
      app = "voting-app"

      name = "redis-service"
    }
  }

  spec {
    port {
      port        = 6379
      target_port = "6379"
    }

    selector = {
      app = "voting-app"

      name = "redis-pod"
    }
  }
  depends_on = [null_resource.delay_pod_creation]
}

resource "kubernetes_pod" "worker_app_pod" {
  metadata {
    name = "worker-app-pod"

    labels = {
      app = "voting-app"

      name = "worker-app-pod"
    }
  }

  spec {
    container {
      name  = "worker-app"
      image = "dockersamples/examplevotingapp_worker"
    }
  }
  depends_on = [null_resource.delay_pod_creation]
}

resource "kubernetes_pod" "postgress_pod" {
  metadata {
    name = "postgress-pod"

    labels = {
      app = "voting-app"

      name = "postgress-pod"
    }
  }

  spec {
    container {
      name  = "postgress"
      image = "postgres:latest"

      env {
        name = "POSTGRES_USER"
        value = "admin"
        name = "POSTGRES_PASSWORD"
        value = "admin123" 
      }

      port {
        container_port = 5432
      }
    }
  }
  depends_on = [null_resource.delay_pod_creation]
}

resource "kubernetes_service" "db" {
  metadata {
    name = "db"

    labels = {
      app = "voting-app"

      name = "db-service"
    }
  }

  spec {
    port {
      port        = 5432
      target_port = "5432"
    }

    selector = {
      app = "voting-app"

      name = "postgress-pod"
    }
  }
  depends_on = [null_resource.delay_pod_creation]
}

resource "kubernetes_pod" "result_app_pod" {
  metadata {
    name = "result-app-pod"

    labels = {
      app = "voting-app"

      name = "result-app-pod"
    }
  }

  spec {
    container {
      name  = "result-app"
      image = "dockersamples/examplevotingapp_result"

      port {
        container_port = 80
      }
    }
  }
  depends_on = [null_resource.delay_pod_creation]
}

resource "kubernetes_service" "result_service" {
  metadata {
    name = "result-service"

    labels = {
      app = "voting-app"

      name = "result-service"
    }
  }

  spec {
    port {
      port        = 80
      target_port = "80"
    }

    selector = {
      app = "voting-app"

      name = "result-app-pod"
    }

    type = "LoadBalancer"
  }
  depends_on = [null_resource.delay_pod_creation]
}

