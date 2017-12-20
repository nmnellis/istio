# Logstash compatible mixer adapter
Logs data to a logstash compatible json file using [lumberjack](https://github.com/natefinch/lumberjack)
Log files are rotated and cleaned up based on size and date.



## Example logstash access loggging
The below setup writes access logs from the istio proxies to a file called `/accesslogs/accesslogs-v1.json`

## Kubernetes CRD

```yaml
kind: CustomResourceDefinition
apiVersion: apiextensions.k8s.io/v1beta1
metadata:
  name: logstash.config.istio.io
  labels:
    package: logstash
    istio: mixer-adapter
spec:
  group: config.istio.io
  names:
    kind: logstash
    plural: logstash
    singular: logstash
  scope: Namespaced
  version: v1alpha2
```

## Example Logentry

```yaml
apiVersion: "config.istio.io/v1alpha2"
kind: logentry
metadata:
 name: elk-accesslog
 namespace: istio-system
spec:
  severity: '"Default"'
  timestamp: request.time | timestamp("1979-01-01T00:00:00Z")
  variables:
    request_path: request.path | ""
    request_protocol: request.scheme | "http"
    request_method: request.method | ""
    request_host: request.host | ""
    source_ip: source.ip | ip("0.0.0.0")
    source_name: source.name | "unknown"
    source_namespace: source.namespace | "unknown"
    source_service: source.service | "unknown"
    source_version: source.labels["version"] | "unknown"
    destination_ip: destination.ip | ip("0.0.0.0")
    destination_name: destination.name | "unknown"
    destination_namespace: destination.namespace | "unknown"
    destination_service: destination.service | "unknown"
    destination_version: destination.labels["version"] | "unknown"
    response_code: response.code | 0
    request_size: request.size | 0
    respose_duration: response.duration | "0ms"
    response_size: response.size | 0
    tcp_bytes_sent: connection.sent.bytes | 0
    tcp_bytes_received: connection.received.bytes | 0
  monitored_resource_type: '"UNSPECIFIED"'
```

## Adapter Config

```yaml
apiVersion: "config.istio.io/v1alpha2"
kind: logstash
metadata:
  name: handler
  namespace: istio-system
spec:
  file_path: "/accesslogs/accesslogs-v1.json"
```

## Rule

```yaml
apiVersion: "config.istio.io/v1alpha2"
kind: rule
metadata:
  name: logstash
  namespace: istio-system
spec:
 match: "true"
  actions:
  - handler: handler.logstash
    instances:
    - elk-accesslog.logentry
```


## Example logstash config


```
input {
  file { 
    path => [  "${LOG_DIR}/accesslogs-v1.json"]
    type => "access" 
    discover_interval => "5" 
    start_position => "beginning" 
  }
}

filter {
    json {source => "message"}
}

output {
  if "_grokparsefailure" in [tags] {
    file {
      path => "/var/log/logstash/failed_groks.log"
    }
  }

  if [type] == "access" {
    amazon_es {
      hosts => ["${ELK_URL}"]
      region => "${ELK_REGION}"
      index => "access-%{+YYYY.MM.dd}"
    }
  }
}

```