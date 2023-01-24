# helm upgrade --install cilium cilium/cilium --version 1.13.0-rc0 \
#    --namespace kube-system \
#    --set hubble.enabled=true \
#    --set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,http:labelsContext=source_pod}" \
#    --set hubble.relay.enabled=true \
#    --set hubble.ui.enabled=true \
#    --set prometheus.enabled=true \
#    --set operator.prometheus.enabled=true \
#    --set hostServices.enabled=false \
#    --set hostServices.protocols=tcp \
#    --set externalIPs.enabled=true \
#    --set nodePort.enabled=true \
#    --set hostPort.enabled=true \
#    --set bpf.masquerade=false \
#    --set image.pullPolicy=IfNotPresent \
#    --set ipam.mode=kubernetes

helm upgrade --install cilium cilium/cilium --version 1.12.5 \
  --namespace kube-system \
  --set cni.chainingMode=aws-cni \
  --set enableIPv4Masquerade=false \
  --set tunnel=disabled \
  --set endpointRoutes.enabled=true \
  --set nodePort.enabled=true \
  --set hostPort.enabled=true \
  --set hostServices.enabled=false \
  --set hostServices.protocols=tcp \
  --set hubble.enabled=true \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,http:labelsContext=source_pod}" \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set externalIPs.enabled=true \
  --set prometheus.enabled=true \
  --set operator.prometheus.enabled=true 
