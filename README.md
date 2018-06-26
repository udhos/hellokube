# hellokube

# Documentation

https://cloud.google.com/kubernetes-engine/docs/quickstart?hl=en

# Install GCP SDK

More information here: https://cloud.google.com/sdk/docs/#linux

    wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-192.0.0-linux-x86_64.tar.gz
    tar xf google-cloud-sdk-192.0.0-linux-x86_64.tar.gz
    ./google-cloud-sdk/install.sh
    gcloud init

# Install kubctl

    gcloud components update
    gcloud components install kubectl

# Authorize the SDK

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

# Create deployment 'hello-server'

    kubectl run hello-server --image gcr.io/google-samples/hello-app:1.0 --port 8080

# Expose the application to Internet by creating a Service

    kubectl expose deployment hello-server --type LoadBalancer --port 80 --target-port 8080

# Inspect application

    $ kubectl get service hello-server
    NAME           TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
    hello-server   LoadBalancer   10.47.254.157   35.225.112.179   80:31384/TCP   1h

Application is available on TCP 35.225.112.179:30

# Delete resources

## Delete load balancer

    kubectl delete service hello-server

## Delete cluster

    gcloud container clusters delete mycluster-1

--x--

