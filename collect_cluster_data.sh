#!/bin/bash
#if [ -z ${1} ]; then
#    echo
#    echo "Please, add the number of the TAM Case to run this script"
#    echo "example: ./collect_data.sh <TAMCAserNumber>"
#    echo "         ./collect_data.sh 1234567890"
#    echo
#    exit 0
#fi

echo "Collecting must-gaher data"
oc adm must-gather &> must-gather_$(date '+%Y%m%d%H%M%S').logs

echo "Compressing the must-gather data creating .tar.gz files"
for name in $(find must* -prune -type d) ; do tar cvaf ${name}.tar.gz ${name} must-gather_*.logs; rm -rf ${name}; done

echo "Collecting pods information"
oc get pods --all-namespaces -o wide &> oc.get.pod.all-namespaces.wide.log

echo "Collecting metrics"
oc get --raw /metrics &> oc.metrics.log

echo "Collecting top nodes"
oc adm top nodes &> oc.adm.top.nodes.log

echo "Collecting nodes"
oc get nodes -o wide &> oc.nodes.log

echo "Collecting describe nodes"
for ocpnode in $(oc get nodes -o=custom-columns=:.metadata.name); do oc describe node $ocpnode &> oc.describe.node.$ocpnode.log ; done

echo "Collecting csr info"
oc get csr &> oc.csr.log

echo "Collecting Storage class informations"
oc get sc &> oc.sc.log

echo "Collecting Image Registry project informations"
oc describe project openshift-image-registry &> oc.openshift-image-regristry.describe.project.log

echo "Collecting Image Registry informations"
oc get pods -n openshift-image-registry &> oc.openshift-image-registry.pods.log

echo "Collecting Monitoring stack information"
oc get all -n openshift-monitoring &> oc.openshift-monitoring.all.log

echo "Collecting Monitoring PVC information"
oc get -n openshift-monitoring pvc &> oc.openshift-monitoring.pvc.log

echo "Collecting Logging information"
oc get pods -n openshift-logging &> oc.openshift-logging.pods.log

echo "Collecting Logging PVC information"
oc get -n openshift-logging pvc &> oc.openshift-logging.pvc.log

echo "Collecting Ingresscontroller information"
oc get ingresscontroller -n openshift-ingress-operator &> oc.get.openshift-ingress-operator.ingresscontroller.log

echo "Collecting oc adm top pods with CPU sort"
oc adm top pods -A --sort-by='cpu' &> oc.adm.top.pods.cpu.log

echo "Collecting oc adm top pods with Memory sort"
oc adm top pods -A --sort-by='memory' &> oc.adm.top.pods.memory.log

echo "Compressing the collected data"
tar cvaf oc-data.tar.gz *.log
rm *.log
rm *.logs

#echo "Sending the collected data into the case"
#for enviar in *.gz; do echo  redhat-support-tool addattachment -c $1 $enviar; done

#echo "Please, check if this files was attached into the case:"
echo "Please, attach this files into the case:"
echo
for enviar in *.gz; do echo $enviar; done
echo
#echo "if not, please attach this files into the case."
