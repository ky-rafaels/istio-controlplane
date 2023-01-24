#!/bin/bash

echo "Enter context of cluster"
read CONTEXT
echo "Enter cluster name"
read CLUSTER

echo "Installing istio in context ${CONTEXT} with trustDomain ${CLUSTER}"
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
kubectl --context ${CONTEXT} create ns istio-system
helm --kube-context=${CONTEXT} upgrade --install istio-base istio/base -n istio-system --set defaultRevision=1-16

helm --kube-context=${CONTEXT} upgrade --install istio-1.16.1 istio/istiod -n istio-system --values - <<EOF
revision: 1-16
global:
  meshID: mesh1
  multiCluster:
    enabled: true
    clusterName: ${CLUSTER}
  network: us-east-1-A-network
  logging:
    level: "debug"
telemetry:
  v2:
    prometheus:
      configOverride:
        gateway:
          debug: false
          metrics:
          - name: response_bytes
            tags_to_remove:
            - response_code
            - response_flags
            - source_cluster
            - destination_cluster
          - name: request_bytes
            tags_to_remove:
            - response_code
            - response_flags
            - source_cluster
            - destination_cluster
          - name: request_duration_milliseconds
            tags_to_remove:
            - response_code
            - response_flags
            - source_cluster
            - destination_cluster
          - tags_to_remove:
            - destination_canonical_service
            - source_canonical_service
            - destination_principal
            - source_principal
            - connection_security_policy
            - grpc_response_status
            - source_version
            - destination_version
            - request_protocol
            - source_canonical_revision
            - destination_canonical_revision
            - source_cluster
            - destination_cluster
          stat_prefix: istio
        outboundSidecar:
          debug: false
          metrics:
          - name: response_bytes
            tags_to_remove:
            - response_code
            - response_flags
            - source_cluster
            - destination_cluster
          - name: request_bytes
            tags_to_remove:
            - response_code
            - response_flags
            - source_cluster
            - destination_cluster
          - name: request_duration_milliseconds
            tags_to_remove:
            - response_code
            - response_flags
            - source_cluster
            - destination_cluster
          - tags_to_remove:
            - destination_canonical_service
            - source_canonical_service
            - destination_principal
            - source_principal
            - connection_security_policy
            - grpc_response_status
            - source_version
            - destination_version
            - request_protocol
            - source_canonical_revision
            - destination_canonical_revision
            - source_cluster
            - destination_cluster
          stat_prefix: istio
        inboundSidecar:
          debug: false
          metrics:
          - name: response_bytes
            tags_to_remove:
            - response_code
            - response_flags
            - source_cluster
            - destination_cluster
          - name: request_bytes
            tags_to_remove:
            - response_code
            - response_flags
            - source_cluster
            - destination_cluster
          - name: request_duration_milliseconds
            tags_to_remove:
            - response_code
            - response_flags
            - source_cluster
            - destination_cluster
          - tags_to_remove:
            - destination_canonical_service
            - source_canonical_service
            - destination_principal
            - source_principal
            - connection_security_policy
            - grpc_response_status
            - source_version
            - destination_version
            - request_protocol
            - source_canonical_revision
            - destination_canonical_revision
            - source_cluster
            - destination_cluster
          stat_prefix: istio
meshConfig:
  trustDomain: ${CLUSTER}
  accessLogFile: /dev/stdout
  enableAutoMtls: true
  defaultConfig:
    proxyMetadata:
      ISTIO_META_DNS_CAPTURE: "true"
      ISTIO_META_DNS_AUTO_ALLOCATE: "true"
pilot:
  env:
    PILOT_ENABLE_K8S_SELECT_WORKLOAD_ENTRIES: "false"
    PILOT_SKIP_VALIDATE_TRUST_DOMAIN: "true"
EOF

echo "Would you like to install ingress gateway? [yes] or [no]"
read INGRESS

if [[ $INGRESS == "yes" ]]; then
kubectl --context ${CONTEXT} create ns istio-ingress
kubectl --context ${CONTEXT} label namespace istio-ingress istio.io/rev=1-16
helm --kube-context=${CONTEXT} upgrade --install istio-ingressgateway istio/gateway -n istio-ingress --values - <<EOF
name: istio-ingressgateway
labels:
  istio: ingressgateway
service:
  type: LoadBalancer
  ports:
  - name: http2
    port: 80
    targetPort: 8080
  - name: https
    port: 443
    targetPort: 8443
  loadBalancerSourceRanges:
  - 52.5.112.38/32
  - 52.3.84.75/32
  - 52.3.133.42/32
  - 52.32.179.208/32
  - 52.32.179.120/32
  - 52.32.97.144/32
  - 52.32.179.149/32
  - 52.32.176.206/32
  - 52.32.179.255/32
  - 52.32.179.122/32
  - 52.32.179.124/32
  - 52.32.179.141/32
EOF
else
echo "aborting install of ingress gateway"
fi

echo "Would you like to install eastwest gateway? [yes] or [no]"
read EASTWEST

if [[ $EASTWEST == "yes" ]]; then
kubectl --context ${CONTEXT} create ns istio-eastwest
kubectl --context ${CONTEXT} label namespace istio-eastwest istio.io/rev=1-16
helm --kube-context=${CONTEXT} upgrade --install istio-eastwestgateway istio/gateway -n istio-eastwest --values - <<EOF
name: istio-eastwestgateway
labels:
  istio: eastwestgateway
  topology.istio.io/network: us-east-1-A-network
service:
  type: LoadBalancer
  ports:
  - name: tcp-status-port
    port: 15021
    targetPort: 15021
  - name: tls
    port: 15443
    targetPort: 15443
  - name: tcp-istiod
    port: 15012
    targetPort: 15012
  - name: tcp-webhook
    port: 15017
    targetPort: 15017
env:
  ISTIO_META_ROUTER_MODE: "sni-dnat"
  ISTIO_META_REQUESTED_NETWORK_VIEW: "us-east-1-A-network"
EOF
else
echo "aborting install of eastwest gateway"
fi