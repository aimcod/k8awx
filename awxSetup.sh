kustomize build . | kubectl apply -f -

kubectl apply -f deploy.yaml

until  kubectl logs --since 5m -f deployments/awx-operator-controller-manager -c awx-manager -n awx | grep -m1 -C1 "failed=0"
do
       echo waiting for deployment to finish
done

kubectl apply -f ingress.yaml

