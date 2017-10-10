job "istio" {
  datacenters = ["dc1"]
  type = "service"
  group "istio" {
    count = 2
    task "etcd" {
      driver = "docker"
      config {
        image = "quay.io/coreos/etcd:latest"
        port_map = {
          foo = 4001
          bar = 2380
          http = 2379          
        }
        command = "/usr/local/bin/etcd"
        args = [
          "-advertise-client-urls=http://0.0.0.0:2379",
          "-listen-client-urls=http://0.0.0.0:2379"
        ]
      }
      service {
        name = "etcd"
        port = "http"
      }
      resources {
        network {
          port "foo" {}
          port "bar" {}
          port "http" {}
        }
      }
    }

    task "apiserver" {
      driver = "docker"
      config {
        image = "gcr.io/google_containers/kube-apiserver-amd64:v1.7.3"
        #privileged = true
        port_map = {
          http = 8080
        }
        command = "kube-apiserver"
        args = [
          "--etcd-servers", "http://etcd:2379",
          "--service-cluster-ip-range", "10.99.0.0/16",
          "--insecure-port", "8080",
          "-v", "2",
          "--insecure-bind-address", "0.0.0.0"
        ]
      }
      service {
        name = "apiserver"
        port = "http"
      }
      resources {
        network {
          port "http" {}
        }
      }
    }

    task "pilot" {
      driver = "docker"
      config {
        image = "gcr.io/istio-testing/pilot:a8dec7b84d253b3e9d532090e2e150175b991211"
        port_map = {
          http = 8080
        }
        command = "discovery"
        args = [
          "-v", "2",
          "--registries", "Consul",
          "--consulserverURL", "http://consul:8500",
          "--kubeconfig", "/etc/istio/config/kubeconfig"
        ]
        volumes = [
          "./kubeconfig:/etc/istio/config/kubeconfig"
        ]
      }
      service {
        name = "istio-pilot"
        port = "http"
      }
      resources {
        network {
          port "http" {}
        }
      }
    }
  }
}
