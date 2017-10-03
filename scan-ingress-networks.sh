#!/usr/bin/env bash

CONFIG_MAP_NAMESPACE=${CONFIG_MAP_NAMESPACE}
if [[ -z "${CONFIG_MAP_NAMESPACE}" ]]; then
    echo "Environment variable 'CONFIG_MAP_NAMESPACE' not defined" >&2
    exit 1
fi

CONFIG_MAP_NAME=${CONFIG_MAP_NAME}
if [[ -z "${CONFIG_MAP_NAME}" ]]; then
    echo "Environment variable 'CONFIG_MAP_NAME' not defined" >&2
    exit 1
fi

while true; do
    NETWORKS=$(kubectl get "configmap/${CONFIG_MAP_NAME}" -n "${CONFIG_MAP_NAMESPACE}" --output=json | jq '.data | map_values(. | split(","))')
    if [[ $? != 0 ]]; then
        exit 1
    fi

    RESTRICTED_INGRESSES=$(kubectl get ingress --all-namespaces --output=json | jq '
                [
                    .items[] |
                    {
                        "namespace": .metadata.namespace,
                        "name": .metadata.name,
                        "networks": (.metadata.annotations["ingress.infolinks.com/networks"] // "") | split(","),
                        "whitelist": (.metadata.annotations["ingress.kubernetes.io/whitelist-source-range"] // "") | split(",")
                    }
                ]')
    if [[ $? != 0 ]]; then
        exit 1
    fi

    # example resulting context:
    # {
    #   "networks": {
    #     "arik": [ "81.218.196.247/32", "31.168.217.84/32" ],
    #     "office": [ "212.143.214.138/32", "82.80.146.176/32" ]
    #   },
    #   "ingresses": [
    #     {
    #       "namespace": "app",
    #       "name": "echoserver",
    #       "networks": [ "arik", "office" ],
    #       "whitelist": [ "1.2.3.4/5", "6.7.8.9/0" ]
    #     },
    #     {
    #       "namespace": "app",
    #       "name": "echoserver",
    #       "networks": [],
    #       "whitelist": [ "0.0.0.0/0" ]
    #     }
    #   ]
    # }
    echo -nE "{ \"networks\": ${NETWORKS}, \"ingresses\": ${RESTRICTED_INGRESSES} }" | $(dirname $0)/update_ingresses.py
    if [[ $? != 0 ]]; then
        echo "Updating Ingress resources failed!" >&2
        exit 1
    fi

    # rinse & repeat
    sleep 10
    if [[ $? != 0 ]]; then
        echo "Interrupted" >&2
        exit 0
    fi
done
