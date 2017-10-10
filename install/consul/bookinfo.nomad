job "bookinfo" {
  datacenters = ["dc1"]
  type = "service"
  group "productpage-v1" {
    count = 1
    task "productpage-v1" {
      driver = "docker"
      config {
        image = "istio/examples-bookinfo-productpage-v1-envoy:0.2.7"
        privileged = true
        labels = {
          version = "v1"
        }
        port_map = {
          http = 9080
        }
      }
      service {
        name = "productpage"
        port = "http"
        tags = [ "version|v1" ]
      }
      resources {
        network {
          port "http" {}
        }
      }
    }
  }

  group "details-v1" {
    count = 1
    task "details-v1" {
      driver = "docker"
      config {
        image = "istio/examples-bookinfo-details-v1-envoy:0.2.7"
        privileged = true
        labels = {
          version = "v1"
        }
        port_map = {
          http = 9080
        }
      }
      service {
        name = "details"
        port = "http"
        tags = [ "version|v1" ]
      }
      resources {
        network {
          port "http" {}
        }
      }
    }
  }

  group "ratings-v1" {
    count = 1
    task "ratings-v1" {
      driver = "docker"
      config {
        image = "istio/examples-bookinfo-ratings-v1-envoy:0.2.7"
        privileged = true
        labels = {
          version = "v1"
        }
        port_map = {
          http = 9080
        }
      }
      service {
        name = "ratings"
        port = "http"
        tags = [ "version|v1" ]
      }
      resources {
        network {
          port "http" {}
        }
      }
    }
  }

  group "reviews-v1" {
    count = 1
    task "reviews-v1" {
      driver = "docker"
      config {
        image = "istio/examples-bookinfo-reviews-v1-envoy:0.2.7"
        privileged = true
        labels = {
          version = "v1"
        }
        port_map = {
          http = 9080
        }
      }
      service {
        name = "reviews"
        port = "http"
        tags = [ "version|v1" ]
      }
      resources {
        network {
          port "http" {}
        }
      }
    }
  }

  group "reviews-v2" {
    count = 1
    task "reviews-v2" {
      driver = "docker"
      config {
        image = "istio/examples-bookinfo-reviews-v2-envoy:0.2.7"
        privileged = true
        labels = {
          version = "v2"
        }
        port_map = {
          http = 9080
        }
      }
      service {
        name = "reviews"
        port = "http"
        tags = [ "version|v2" ]
      }
      resources {
        network {
          port "http" {}
        }
      }
    }
  }

  group "reviews-v3" {
    count = 1
    task "reviews-v3" {
      driver = "docker"
      config {
        image = "istio/examples-bookinfo-reviews-v3-envoy:0.2.7"
        privileged = true
        labels = {
          version = "v3"
        }
        port_map = {
          http = 9080
        }
      }
      service {
        name = "reviews"
        port = "http"
        tags = [ "version|v3" ]
      }
      resources {
        network {
          port "http" {}
        }
      }
    }
  }
}
