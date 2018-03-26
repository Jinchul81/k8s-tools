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

alias ktty="kubectl run -i --tty mytty --image=metatronx/hadoop -it --rm --restart=Never -- bash"
alias ktty_mysql="kubectl run -i --tty mytty-mysql --image=centos/mysql-57-centos7 -it --rm --restart=Never -- bash"
alias kget_nodes="kubectl get nodes --all-namespaces"
alias kget_pods="kubectl get pods --all-namespaces --show-all"
alias kget_all="kubectl get all --all-namespaces --show-all"
alias kget_svc="kubectl get svc --all-namespaces"
alias kget_sts="kubectl get sts --all-namespaces"
alias kget_pvc="kubectl get pvc --all-namespaces"
alias kget_pv="kubectl get pv --all-namespaces"
alias kget_sc="kubectl get sc --all-namespaces"
alias kget_deploy="kubectl get deploy --all-namespaces"
alias kget_clusterrolebinding="kubectl get clusterrolebinding"

alias kdelete_all_pvc="kubectl delete pvc --all"
alias kdelete_all_pv="kubectl delete pv --all"

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

