# CKA Exam Preparation Questions for practice with solutions



## Section 2
* Create a service account named `api-access` in a new namespace called `apps`.
    
    ```shell
    # Create namespace
    $ kubectl create namespace apps
    
    # create ServiceAccount
    $ kubectl create serviceaccount api-access
    ```

    ```yaml
    apiVersion: v1
    kind: Namespace
    metadata:
      name: apps
    ```

    ```yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata: 
      name: api-access
    ```


* Create a ClusterRole with name `api-clusterrole`, and create a ClusterRolebinding named `api-clusterrolebinding`. Map the ServiceAccount `api-acess` to the API resources `pods` with the operations `watch`, `list`, and `get`.**

    ```shell
    $ kubectl create clusterrole api-clusterrole --verb=get,list-watch --resource=pods
    $ kubectl create clusterrolebinding api-clusterrolebinding --clusterrole=api-clusterrole --serviceaccount=apps:api-access
    ```
    ```yaml
    apiVersion: v1
    kind: ClusterRole
    metadata:
      name: api-clusterrole
    rules:
      - apiGroups: ""
      - resources: [pods]
      - verbs: [watch, list, get]
    ```

    ```yaml
    apiVersion: v1
    kind: ClusterRoleBinding
    metadata:
      name: api-clusterrolebinding
    roleRef:
      apiGroup: rbac.authorizations.k8s.io
      kind: ClusterRole
      name: api-clusterrole
    subjects:
      - kind: ServiceAccount
        name: api-access
        namespace: apps
    ```

* Create a pod named `operator` with the image `nginx:1.21.1` in the namespace `apps`. Expose the container port 80. Assign the ServiceAccount `api-accesss` to the pod. Create a another pod named `disposable` with the image `nignx:1.21.1` in the namespace `rm`. Do not assign the ServiceAccount to the Pod. 

  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: operator
  namespace: apps
spec:
  containers:
    - name: nginx
      image: nginx:1.21.1
  serviceAccountName: api-access
```

```bash
$ kubectl create namespace rm
$ kubectl run disposable --image=nginx:1.21.1 --port=80 --namespace=rm

$ kubectl get pods -n rm
NAME         READY   STATUS    RESTARTS   AGE
disposable   1/1     Running   0          26s
```

