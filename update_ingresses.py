#!/usr/bin/env python3

import json
import subprocess

import sys

# URL constants
WHITELIST_ANN_NAME = 'ingress.kubernetes.io/whitelist-source-range'


def main():
    # read JSON from stdin
    context = json.loads('\n'.join(sys.stdin.readlines()))

    # iterate ingresses, and for each one, construct the list of whitelisted CIDRs (from its whitelisted networks)
    # then annotate the ingress to whitelist only the CIDRs collected from those whitelisted networks
    networks = context['networks']
    for ing in context['ingresses']:
        ing_namespace = ing['namespace']
        ing_name = ing['name']
        ing_actual_whitelist = ing['whitelist']

        # collect CIDRs from the ingress's whitelisted networks
        if ing['networks']:
            ing_desired_whitelist = []
            for network_name in ing['networks']:
                network_name = network_name.strip()
                ing_desired_whitelist.extend(networks[network_name] if network_name in networks else [])
        else:
            ing_desired_whitelist = ["0.0.0.0/0"]

        # if actual & desired whitelists are different, update ingress
        if ing_actual_whitelist != ing_desired_whitelist:
            print(f"Ingress '{ing_namespace}/{ing_name}' has differing actual & desired CIDR whitelist:")
            print(f"   Actual: {ing_actual_whitelist}")
            print(f"  Desired: {ing_desired_whitelist}")
            whitelist_string = ','.join(ing_desired_whitelist)
            subprocess.check_call(f"kubectl annotate --namespace=\"{ing_namespace}\" ingress/{ing_name} "
                                  f"                 --overwrite {WHITELIST_ANN_NAME}=\"{whitelist_string}\"",
                                  shell=True)


if __name__ == "__main__":
    main()
