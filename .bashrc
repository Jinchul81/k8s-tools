# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export KUBECONFIG=/etc/kubernetes/admin.conf

PEM_FILE=~/.ssh/metatron_2018.pem
k8s_node2=ec2-13-125-155-166.ap-northeast-2.compute.amazonaws.com
k8s_node3=ec2-52-79-136-230.ap-northeast-2.compute.amazonaws.com
k8s_node4=ec2-13-125-209-48.ap-northeast-2.compute.amazonaws.com
k8s_node5=ec2-13-125-110-1.ap-northeast-2.compute.amazonaws.com

alias sshnode2="ssh -i ${PEM_FILE} centos@${k8s_node2}"
alias sshnode3="ssh -i ${PEM_FILE} centos@${k8s_node3}"
alias sshnode4="ssh -i ${PEM_FILE} centos@${k8s_node4}"
alias sshnode5="ssh -i ${PEM_FILE} centos@${k8s_node5}"

function kdelete_() {
  if [[ -z $1 ]]; then
    echo "ERROR: missing the first argument"
    exit 0
  fi
  if [[ -z $2 ]]; then
    echo "ERROR: missing the second argument"
    exit 0
  fi
  kubectl delete $1 $2
}

function kdesc() {
  kubectl describe pod $1
}

function klogs() {
  kubectl logs $1
}

function kgetpodname() {
  kubectl get pods -l k8s-app=$1 -o name
}

function kgetkubepodname() {
  kubectl get pods --namespace=kube-system -l k8s-app=$1 -o name
}

function kdelete_sts() {
  kdelete_ sts $1
}

function kdelete_svc() {
  kdelete_ svc $1
}

function kdelete_pvc() {
  kdelete_ pvc $1
}

function kdelete_pv() {
  kdelete_ pv $1
}

function kdelete_sc() {
  kdelete_ sc $1
}

function kdelete_deploy() {
  kdelete_ deploy $1
}

function kcreate() {
  kubectl create -f $1
}

function kstop_pod() {
  kubectl delete deployment $1 --grace-period=30
}

function kconnect() {
  if [[ -z $2 ]]; then
    KSHELL="/bin/bash"
  else
    KSHELL=$2
  fi

  kubectl exec -ti $1 -- ${KSHELL}
}

#alias ktty="kubectl run -i --tty mytty --image=metatronx/hadoop -it --rm --restart=Never -- bash"
alias ktty_mysql="kubectl run -i --tty mytty-mysql --image=centos/mysql-57-centos7 -it --rm --restart=Never -- bash"
alias kget_nodes="kubectl get nodes --all-namespaces"
alias kget_pods="kubectl get pods --all-namespaces --show-all"
alias kget_all="kubectl get all --all-namespaces --show-all"
alias kget_svc="kubectl get svc --all-namespaces"
alias kget_sts="kubectl get sts --all-namespaces"
alias kget_pvc="kubectl get pvc --all-namespaces"
alias kget_pv="kubectl get pv --all-namespaces"
alias kget_sc="kubectl get sc --all-namespaces"
alias kget_ep="kubectl get ep --all-namespaces"
alias kget_deploy="kubectl get deploy --all-namespaces"
alias kget_clusterrolebinding="kubectl get clusterrolebinding"

alias kdelete_all_pvc="kubectl delete pvc --all"
alias kdelete_all_pv="kubectl delete pv --all"

alias netstatlisten="netstat -anp | grep LISTEN | less"

function kdelete_web() {
  kdelete_sts web
  kdelete_svc nginx
  kdelete_pvc nfs-node1-pvc-web-0 
}

function kdelete_nfs() {
  kstop_pod nfs-provisioner
  kdelete_svc nfs-provisioner
  kdelete_pvc nfs
}

function kdelete_nfs_client() {
  kstop_pod nfs-client-provisioner
  kdelete_svc nfs-client-provisioner
  kdelete_pvc managed-nfs-storage
}

# HELM


function kdelete_tiller() {
  kubectl delete deployment --namespace=kube-system -l name=tiller --grace-period=30
  kget_all_pods
}

export HELM_HOME=/root/.helm

function get_curl() {
  #local TOKEN=8c5b53.a56c711f1f1e7a34
  local TOKEN=sohncw.metatronmetatron
  local API_SERVER="https://13.125.181.112:6443"
  #local API_SERVER="https://localhost:6443"
  #curl -k -X GET -H "Authorization: Bearer ${TOKEN}" ${API_SERVER}/api/v1/nodes
  curl -k -X GET -H "Authorization: Bearer ${TOKEN}" ${API_SERVER}/${1}
}

# Druid

HOST_IP=$(hostname -I | awk '{print $1}')
function druid_ingest() {
  curl -X 'POST' -H 'Content-Type: application/json' -d @${1} ${HOST_IP}:8090/druid/indexer/v1/task
}

function druid_query() {
  curl -L -H 'Content-Type: application/json' -XPOST --data-binary @${1} http://${HOST_IP}:8082/druid/v2/?pretty
}

function chart_delete_druid() {
  helm delete --purge druid
}

function chart_delete_druid_pvc() {
  kget_pvc | grep druid | awk '{print "kubectl delete pvc " $2}' | sh
}

function chart_install_druid_with_load_balance() {
  helm install --name druid \
  --set service.type=LoadBalancer \
  --set service.externalIPs=${HOST_IP} \
  ./druid --debug | tee druid_debug.txt
}

function chart_install_druid() {
  helm install --name druid ./druid --debug | tee druid_debug.txt
}

function chart_dryrun_druid_with_load_balance() {
  helm install --name druid \
  --set service.type=LoadBalancer \
  --set service.externalIPs=${HOST_IP} \
  ./druid --dry-run --debug | tee druid_debug.txt
}

function chart_dryrun_druid() {
  helm install --name druid \
  ./druid --dry-run --debug | tee druid_debug.txt
}


