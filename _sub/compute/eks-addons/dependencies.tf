# Apply specific versions of Kubernetes add-ons depending on EKS version
# https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html 

locals {
    kubeproxy_version_map = "${map(
        "1.11", "1.11.8",
        "1.12", "1.12.6",
        "1.13", "1.13.10",
        "1.14", "1.14.6"
    )}"
    coredns_version_map = "${map(
        "1.11", "1.1.3",
        "1.12", "1.2.2",
        "1.13", "1.2.6",
        "1.14", "1.3.1"
    )}"
    vpccni_version_map = "${map(
        "1.11", "1.5",
        "1.12", "1.5",
        "1.13", "1.5",
        "1.14", "1.5"
    )}"
}


# Lookup actual add-on versions
locals {
    kubeproxy_version = "${local.kubeproxy_version_map[var.cluster_version]}"
    coredns_version = "${local.coredns_version_map[var.cluster_version]}"
    vpccni_version = "${local.vpccni_version_map[var.cluster_version]}"
}