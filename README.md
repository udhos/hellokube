# hellokube

# Cheat sheet

https://kubernetes.io/docs/reference/kubectl/cheatsheet/

# Install GCP SDK

More information here: https://cloud.google.com/sdk/docs/#linux

    wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-192.0.0-linux-x86_64.tar.gz
    tar xf google-cloud-sdk-192.0.0-linux-x86_64.tar.gz
    ./google-cloud-sdk/install.sh
    gcloud init

# Install kubectl

    gcloud components update
    gcloud components install kubectl

# Authorize the SDK

    gcloud auth list
    gcloud auth login

# Create cluster 'mycluster-1'

    gcloud container clusters create mycluster-1

## Output

    $ gcloud container clusters create mycluster-1
    WARNING: Currently node auto repairs are disabled by default. In the future this will change and they will be enabled by default. Use `--[no-]enable-autorepair` flag  to suppress this warning.
    WARNING: Starting in Kubernetes v1.10, new clusters will no longer get compute-rw and storage-ro scopes added to what is specified in --scopes (though the latter will remain included in the default --scopes). To use these scopes, add them explicitly to --scopes. To use the new behavior, set container/new_scopes_behavior property (gcloud config set container/new_scopes_behavior true).
    Creating cluster mycluster-1...done.
    Created [https://container.googleapis.com/v1/projects/proj-research/zones/us-central1-b/clusters/mycluster-1].
    To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/us-central1-b/mycluster-1?project=proj-research
    kubeconfig entry generated for mycluster-1.
    NAME         LOCATION       MASTER_VERSION  MASTER_IP      MACHINE_TYPE   NODE_VERSION  NUM_NODES  STATUS
    mycluster-1  us-central1-b  1.8.10-gke.0    35.224.225.63  n1-standard-1  1.8.10-gke.0  3          RUNNING

# Resize cluster

https://cloud.google.com/sdk/gcloud/reference/container/clusters/resize

    gcloud container clusters resize mycluster-1 --size=2

# Enable cluster autoscaling

One can define cluster autoscaling at creation:

    gcloud container clusters create mycluster-1 --num-nodes 3 --enable-autoscaling --min-nodes 2 --max-nodes 5

Or later:

    gcloud container clusters update mycluster-1 --enable-autoscaling --min-nodes 1 --max-nodes 5 --node-pool default-pool

Notice the cluster autoscaling is defined for every node pool.

# Verify cluster

    gcloud container clusters describe mycluster-1

Verify cluster autoscaling:

    $ gcloud container clusters describe mycluster-1 | grep -A 5 autoscaling
    - autoscaling:
        enabled: true
        maxNodeCount: 5
        minNodeCount: 1
      config:
        diskSizeGb: 100

Verify node count:

    $ gcloud container clusters describe mycluster-1 | grep Node
    currentNodeCount: 2
    currentNodeVersion: 1.8.10-gke.0
        maxNodeCount: 5
        minNodeCount: 1
      initialNodeCount: 3

# Disable cluster autoscaling

    gcloud container clusters update mycluster-1 --no-enable-autoscaling --node-pool default-pool

# Add another node pool

    gcloud container node-pools create pool-2 --cluster mycluster-1 --enable-autoscaling --min-nodes 1 --max-nodes 3

## Output

    $ gcloud container node-pools create pool-2 --cluster mycluster-1 --enable-autoscaling --min-nodes 1 --max-nodes 3
    WARNING: Currently node auto repairs are disabled by default. In the future this will change and they will be enabled by default. Use `--[no-]enable-autorepair` flag  to suppress this warning.
    WARNING: Starting in Kubernetes v1.10, new clusters will no longer get compute-rw and storage-ro scopes added to what is specified in --scopes (though the latter will remain included in the default --scopes). To use these scopes, add them explicitly to --scopes. To use the new behavior, set container/new_scopes_behavior property (gcloud config set container/new_scopes_behavior true).
    Creating node pool pool-2...done.
    Created [https://container.googleapis.com/v1/projects/proj-research/zones/us-central1-b/clusters/mycluster-1/nodePools/pool-2].
    NAME    MACHINE_TYPE   DISK_SIZE_GB  NODE_VERSION
    pool-2  n1-standard-1  100           1.8.10-gke.0

# Show nodes

    $ kubectl get nodes
    NAME                                         STATUS    ROLES     AGE       VERSION
    gke-mycluster-1-default-pool-fe9bc936-jq4l   Ready     <none>    4h        v1.8.10-gke.0
    gke-mycluster-1-default-pool-fe9bc936-v7cb   Ready     <none>    4h        v1.8.10-gke.0
    gke-mycluster-1-pool-2-6d597c7f-79vm         Ready     <none>    1h        v1.8.10-gke.0

# Build image

## Authorize docker

    gcloud auth configure-docker

## Build and push

    project_id="$(gcloud config get-value project -q)"
    docker build -t gcr.io/$project_id/hello-app:v1 .
    docker images
    docker push gcr.io/$project_id/hello-app:v1

## Explore image contents interactively

    docker run -it gcr.io/$project_id/hello-app:v1 sh

## Test image

    docker run --rm -p 8080:8080 gcr.io/$project_id/hello-app:v1

    $ curl http://localhost:8080
    Hello, world!
    Version: 1.0.0
    Hostname: f42424a8d554

## Deploy the application

    kubectl run hello-web --image=gcr.io/$project_id/hello-app:v1 --port 8080

## List deployments

    kubectl get deployments

## List pods

Notice there is a single replica because the app has been deployment with default replica number.

    $ kubectl get pods
    NAME                         READY     STATUS    RESTARTS   AGE
    hello-web-78fdd597bc-bw9kp   1/1       Running   0          8m

## Expose application to Internet

    kubectl expose deployment hello-web --type=LoadBalancer --port 80 --target-port 8080

## List services

    $ kubectl get services
    NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
    hello-web    LoadBalancer   10.47.250.102   35.225.5.98   80:32137/TCP   1m
    kubernetes   ClusterIP      10.47.240.1     <none>        443/TCP        6h

## Test service

Open http://35.225.5.98

## Verify application scale

    $ kubectl get deployment hello-web
    NAME        DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
    hello-web   1         1         1            1           4m

## Scale up application

    kubectl scale deployment hello-web --replicas=3

    $ kubectl get deployment hello-web
    NAME        DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
    hello-web   3         3         3            3           6m

Notice there are 3 replicas:

    $ kubectl get pods
    NAME                         READY     STATUS    RESTARTS   AGE
    hello-web-78fdd597bc-bw9kp   1/1       Running   0          7m
    hello-web-78fdd597bc-qptws   1/1       Running   0          1m
    hello-web-78fdd597bc-xspcr   1/1       Running   0          1m

## Create and push image v2

    docker build -t gcr.io/$project_id/hello-app:v2 .
    docker push gcr.io/$project_id/hello-app:v2

## Apply rolling update to deployment

    kubectl set image deployment/hello-web hello-web=gcr.io/$project_id/hello-app:v2

Check http://35.225.5.98/

## Delete resources

Delete service:

    kubectl delete service hello-web

Wait until the load balancer is deleted by using:

    gcloud compute forwarding-rules list

Delete deployment:

    kubectl delete deployment hello-web

Delete images in registry:

    $ gcloud container images list
    NAME
    gcr.io/proj-research/hello-app
    Only listing images in gcr.io/proj-research. Use --repository to list images in other repositories.

    $ gcloud container images list-tags gcr.io/proj-research/hello-app
    DIGEST        TAGS   TIMESTAMP
    d1c50bc05b2e  v1,v2  2018-06-26T18:47:59
    88b076cd90f4         2018-06-26T18:38:12
    4f2dacbeca43         2018-06-26T18:17:34

    gcloud container images delete gcr.io/proj-research/hello-app@sha256:d1c50bc05b2e --force-delete-tags
    gcloud container images delete gcr.io/proj-research/hello-app@sha256:88b076cd90f4 --force-delete-tags
    gcloud container images delete gcr.io/proj-research/hello-app@sha256:4f2dacbeca43 --force-delete-tags

# Create deployment 'hello-server'

    kubectl run hello-server --image gcr.io/google-samples/hello-app:1.0 --port 8080

# Show deployments

    $ kubectl get deployments
    NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
    hello-server   1         1         1            1           3h

# Show pods

    $ kubectl get pod
    NAME                            READY     STATUS    RESTARTS   AGE
    hello-server-66cb56b679-88sxq   1/1       Running   0          3h

# Expose the application to Internet by creating a Service

    kubectl expose deployment hello-server --type LoadBalancer --port 80 --target-port 8080

# List services

    $ kubectl get services
    NAME           TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
    hello-server   LoadBalancer   10.47.241.238   35.193.87.157  80:31906/TCP   34m
    kubernetes     ClusterIP      10.47.240.1     <none>          443/TCP        2h

# Inspect application

    $ kubectl get service hello-server
    NAME           TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
    hello-server   LoadBalancer   10.47.241.238   35.193.87.157   80:31384/TCP   1h

Application is available on TCP 35.225.112.179:30

# Delete resources

## Delete load balancer

    kubectl delete service hello-server

## Delete pod

    kubectl delete pod hello-server-66cb56b679-88sxq

## Delete deployment

    kubectl delete deployment hello-server

## Delete cluster

    gcloud container clusters delete mycluster-1

--x--

