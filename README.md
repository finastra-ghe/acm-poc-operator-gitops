# ACM Operator repo definitions

## What is ACM

### Why ACM

### Introduction to ACM

## Onboarding

### Cluster onboarding

* [ACM docs](https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.1/html/manage_cluster/importing-a-target-managed-cluster-to-the-hub-cluster#importing-a-managed-cluster-with-the-cli )
* [Onboarding script](https://dev.azure.com/fusionfabric/FusionOperate/_git/acm-automation)

### What does it mean to onboard a Team?

1. New `git` repo created in AzureDevOps, for example `ffdc-gitops` or `fusion-operate-gitops`
1. ACM ServicePrincipal/User granted RO permisions to the repo
1. ACM ServicePrincipal/User credentials added as a secret in a channel namespace. See [examples](https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.2/html-single/manage_applications/index#channel-samples)
1. New tenant added to [projects](/projects) folder
    1. `gitops` repository defined in `channels` section
    1. `helm` repository defined in `channels` section
1. Install tenant helm chart in ACM ARO cluster
    ```bash
    make deploy <project_name>
    ```
1. Respective team group granted viwer permissions to ACM UI

### What does it mean to deploy application?


### Mappings
* Zone -> Cluster
* Tenant -> Namespace


---

## Use

```bash
cd tenants/<project>
helm template <project> . | k apply -f -
```

## Tips

### Force reconcile subscription

```bash
oc label subscriptions.apps.open-cluster-management.io the_subscription_name reconcile=true
```

### Import cluster to ACM 2.1

1. create secret open-cluster-management-image-pull-credentials on the hub
1. modify cluter import resource and add:

```yaml
imagePullSecret: open-cluster-management-image-pull-credentials
```

Notes:

* https://github.com/open-cluster-management/rhacm-docs/blob/a4ef3e17e50cd71a0e82c256e753f795c5de1588/manage_cluster/master.html#L2963
* https://github.com/open-cluster-management/rhacm-docs/blob/2.1_prod/manage_applications/subscribe_git_resources.adoc

### Deploy to multiple namespaces

For this to happen ACM user needs to be added to `open-cluster-management:subscription-admin` `ClusterRoleBinding`

```bash
oc edit clusterrolebinding open-cluster-management:subscription-admin
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  creationTimestamp: "2021-03-02T13:13:27Z"
  name: open-cluster-management:subscription-admin
  resourceVersion: "114971687"
  selfLink: /apis/rbac.authorization.k8s.io/v1/clusterrolebindings/open-cluster-management%3Asubscription-admin
  uid: dd45521c-e26f-4436-be52-abdac064f69b
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: open-cluster-management:subscription-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: vladimir.babichev@dh.com
```

## Onboarding

1. Cluster onboarding. [ACM docs](https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.1/html/manage_cluster/importing-a-target-managed-cluster-to-the-hub-cluster#importing-a-managed-cluster-with-the-cli )
    * API call to create server in ACM
    * API call to retrieve `kubectl` commands
    * Apply `kubectl` commands against target cluster

1. Team/application onboarding
    1. team gitops repo get created: `team1-gitops`
    2. team repo reference get added to `operator-gitops` repo
    3. onboarding script/pipeline triggers addition of a new entry to acm

## Open questions

1. Team deploy apps across multiple namespaces: requires service accoint with admin privs for subscriptions.
    * Pros:
        * one repo - multiple namespaces
        * can remove need of script/pipeline from step `3` in `2`
    * Cons:
        * security implications - devs can deploy to any namespace
        * name collisions/unpredictible behaviour - devs can deploy to any namespace
2. Team deploy apps across multiple namespaces: requires service accont with access to specific namespaces for subscriptions
    * Pros:
        * one repo - multiple namespaces
        * can remove need of script/pipeline from step `3` in `2`
        * security not impacted
        * collisions minimised
    * Cons:
        * service account management cost: addition/updates/deletion
3. Team has gitops repo per namespace, like `ffdc-core-gitops` or `ffdc-devportal-gitops`


## Notes:
oc label subscriptions.apps.open-cluster-management.io kubernetes-external-secrets-dev-westeu-1 reconcile=true

How to import running applications?
How to reconcile applications deployed not by ACM
