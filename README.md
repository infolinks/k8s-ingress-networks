# k8s-ingress-networks

[![Build status](https://badge.buildkite.com/6cf1a63094e63e217070a9ed4bbdebf744984160cdd34d4f05.svg)](https://buildkite.com/infolinks/k8s-ingress-networks)

Container for continually ensuring that a Kubernetes Ingress resources is restricted only to a set of whitelisted
networks (CIDR ranges) based on a list of named networks.

This container will:

1. Search for a configuration map (whose name is provided as an environment variable) that will contain a mapping
between network names and CIDR ranges.
2. Watch Ingress resources with the annotation `ingress.infolinks.com/networks`
3. For each such Ingress resource:
    1. Build a CIDR list from the combined CIDR ranges of all networks referenced in `ingress.infolinks.com/networks`
    2. Add/update the Kubernetes annotation `ingress.kubernetes.io/whitelist-source-range` with the CIDR list

## Deployment

When running externally to a Kubernetes cluster, make sure that you configure `kubectl` to properly access your cluster.

If this container is running inside a Kubernetes cluster, you just need to make sure the `Pod` running this container
has the RBAC permissions to use `kubectl`.

## Contributions

Any contribution to the project will be appreciated! Whether it's bug
reports, feature requests, pull requests - all are welcome, as long as
you follow our [contribution guidelines for this project](CONTRIBUTING.md)
and our [code of conduct](CODE_OF_CONDUCT.md).
