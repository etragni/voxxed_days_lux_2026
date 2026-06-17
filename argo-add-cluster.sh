# 2. Get the Argo CD password and Server pod name
ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
ARGOCD_POD=$(kubectl get pod -n argocd -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].metadata.name}')

# 3. Create the internal kubeconfig
cp ~/.kube/config kubeconfig-internal.yaml
EU_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kargo-eu-control-plane)
US_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kargo-us-control-plane)

KUBECONFIG=kubeconfig-internal.yaml kubectl config set-cluster kind-kargo-eu --server=https://${EU_IP}:6443
KUBECONFIG=kubeconfig-internal.yaml kubectl config set-cluster kind-kargo-us --server=https://${US_IP}:6443

# 4. Stream the kubeconfig directly into the Argo CD pod
cat kubeconfig-internal.yaml | kubectl exec -i -n argocd $ARGOCD_POD -- sh -c "cat > /tmp/kubeconfig"

# 5. Execute the cluster add commands FROM INSIDE the pod
kubectl exec -n argocd $ARGOCD_POD -- sh -c "
  argocd login localhost:8080 --username admin --password $ARGOCD_PASS --insecure &&
  KUBECONFIG=/tmp/kubeconfig argocd cluster add kind-kargo-eu --name kargo-eu -y &&
  KUBECONFIG=/tmp/kubeconfig argocd cluster add kind-kargo-us --name kargo-us -y
"

# 6. Clean up
rm kubeconfig-internal.yaml