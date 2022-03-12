#!/usr/bin/env bash

echo "### apply-istio.sh"
set -x #echo on

VERSION=${1-"1.13.1"}
SETUP_PATH=${1-"/usr/local/bin/setup"}

if [[ $(which envoy) == "" ]]; then
  curl -sL 'https://deb.dl.getenvoy.io/public/gpg.8115BA8E629CC074.key' | gpg --dearmor -o /usr/share/keyrings/getenvoy-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/getenvoy-keyring.gpg] https://deb.dl.getenvoy.io/public/deb/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/getenvoy.list

  apt update -yqq
  apt install -yqq getenvoy-envoy

  apt autoremove -yq
fi

envoy --version

# install istio
export ISTIO_VERSION="${VERSION}"
if [[ ! -f /usr/local/bin/istioctl ]]; then
  cd "${SETUP_PATH}" || echo
  curl -sL "https://istio.io/downloadIstio" | sh -

  mv "istio-${ISTIO_VERSION}" istio

  cp "istio/bin/istioctl" /usr/local/bin/istioctl
  chmod +x /usr/local/bin/istioctl

#  export PATH="$PATH:/usr/local/bin/setup/istio/bin"
fi

istioctl x precheck

# init : istio-operator 네임스페이스 생성, istio-operator 디플로이먼트 생성 - 링크
istioctl operator init

# wait for argocd init.
echo "Wait for argocd init. (3 mins)"
sleep 180

# create profile: https://kim-dragon.tistory.com/124?category=839107
kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: default-istiocontrolplane
spec:
  profile: default
EOF

echo "Wait for argocd init. (3 mins)"
sleep 180

# 버전 확인
istioctl version

# Auto Injection with namespace
kubectl label ns default istio-injection=enabled

#kubectl patch svc -n istio-system istio-ingressgateway -p '{"spec":{"type":"LoadBalancer"}}'
#kubectl patch svc -n istio-system istio-ingressgateway -p '{"spec":{"externalTrafficPolicy":"Local"}}'

istioctl proxy-status

# Addon 설치 : Kiali (키알리) 대시보드
tree "${SETUP_PATH}/istio/samples/addons/"

kubectl apply -f "${SETUP_PATH}/istio/samples/addons" # 디렉터리에 있는 모든 yaml 자원을 생성
kubectl rollout status deployment/kiali -n istio-system

# 확인
kubectl get all,sa -n istio-system

# kiali 서비스 변경
#kubectl patch svc -n istio-system kiali -p '{"spec":{"type":"NodePort"}}'

# kiali 웹 접속 주소 확인
KIALIHostIP=$(kubectl get pod -n istio-system -l app=kiali -o jsonpath='{.items[0].status.hostIP}')
KIALINodePort=$(kubectl get svc -n istio-system kiali -o jsonpath={.spec.ports[0].nodePort})

echo -e "KIALI UI URL = http://$KIALIHostIP:$KIALINodePort"

# Grafana 서비스 변경
#kubectl patch svc -n istio-system grafana -p '{"spec":{"type":"NodePort"}}'

# Grafana 웹 접속 주소 확인 : 미리 6개의 대시보드가 있고 아래 3개의 대시보드 URL 확인
GRAFANAHostIP=$(kubectl get pod -n istio-system -l app=grafana -o jsonpath='{.items[0].status.hostIP}')
GRAFANANodePort=$(kubectl get svc -n istio-system grafana -o jsonpath={.spec.ports[0].nodePort})

echo -e "Grafana - Istio Traffic Dashboard URL = http://$GRAFANAHostIP:$GRAFANANodePort/d/G8wLrJIZk/istio-mesh-dashboard" ;echo
echo -e "Grafana - Istio Service Dashboard URL = http://$GRAFANAHostIP:$GRAFANANodePort/d/LJ_uJAvmk/istio-service-dashboard" ;echo
echo -e "Grafana - Istio Workload Dashboard URL = http://$GRAFANAHostIP:$GRAFANANodePort/d/UbsSZTDik/istio-workload-dashboard" ;echo

# Prometheus 서비스 변경
#kubectl patch svc -n istio-system prometheus -p '{"spec":{"type":"NodePort"}}'

# Prometheus 웹 접속 주소 확인
PROMEHostIP=$(kubectl get pod -n istio-system -l app=prometheus -o jsonpath='{.items[0].status.hostIP}')
PROMENodePort=$(kubectl get svc -n istio-system prometheus -o jsonpath={.spec.ports[0].nodePort})
echo -e "Prometheus Web URL = http://$PROMEHostIP:$PROMENodePort"
