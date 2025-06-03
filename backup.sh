#!/bin/bash

NAMESPACE=kuma
DEPLOYMENT=kuma-deploy
BACKUP_POD=kuma-backup
BACKUP_FILE=$(date +%Y\%m\%d_\%H\%M\%S)_kuma-data.tar.gz

kubectl scale deployment $DEPLOYMENT --replicas=0 -n $NAMESPACE

kubectl wait --for=delete pod -l app=$DEPLOYMENT -n $NAMESPACE --timeout=60s || true

kubectl apply -f /home/anonymous/kuma/4_backup_pod.yaml

kubectl wait --for=condition=Ready pod/$BACKUP_POD -n $NAMESPACE --timeout=120s

sleep 30

kubectl -n $NAMESPACE cp $BACKUP_POD:/backup/kuma-data.tar.gz /home/anonymous/kuma/backup/$BACKUP_FILE 

kubectl delete pod $BACKUP_POD -n $NAMESPACE
kubectl scale deployment $DEPLOYMENT --replicas=1 -n $NAMESPACE
