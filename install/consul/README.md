# Install Istio using Nomad

Please follow the installation instructions from [istio.io](https://istio.io/docs/setup/consul/).

The install file `istio.yaml` deploys Istio Pilot, Consul, Registrator, and
the Istio API server with etcd as Docker containers.

## Running Istio on Nomad (WIP)

Start Consul

```bash
consul agent -dev
```

Start nomad with the nomad.config file which allows privileged access for docker containers

```bash
nomad agent -dev -config nomad.config
```

Start Istio (etcd, kube api server and pilot).

```bash
nomad run istio.nomad
```

Start bookinfo (with envoy containers)

```bash
nomad run bookinfo.nomad
```

The kube API server keeps crashing because it cannot resolve etcd host probably (the command args might need to be set to etcd.service.consul)
Pilot crashes because it cannot reach Kube API server or the Consul server on port 8500. Need to figure out how to point Pilot to Consul

On OSX, even vanilla bookinfo (without Envoy) keeps churning (reviews containers crash and restart). Also, I am unable to reach any of
the app's forwarded ports. One main problem I see is nomad setting up port forwarding for both tcp and udp. This causes all communication to hang on OSX.
