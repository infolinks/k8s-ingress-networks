#!/usr/bin/env python2
import json
import subprocess

import sys

# URL constants
WHITELIST_ANN_NAME = 'ingress.kubernetes.io/whitelist-source-range'


def main():
    # read JSON from stdin
    try:
        context = json.loads('\n'.join(sys.stdin.readlines()))
    except:
        sys.stderr.write("Failed reading JSON from stdin!\n")
        sys.stderr.flush()
        raise

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
                ing_desired_whitelist.extend(networks[network_name] if network_name in networks else [])
        else:
            ing_desired_whitelist = ["0.0.0.0/0"]

        # if actual & desired whitelists are different, update ingress
        if ing_actual_whitelist != ing_desired_whitelist:
            print "Ingress '%s/%s' has differing actual & desired CIDR whitelist:" % (ing_namespace, ing_name)
            print "   Actual: %s" % ing_actual_whitelist
            print "  Desired: %s" % ing_desired_whitelist
            whitelist_string = ','.join(ing_desired_whitelist)
            subprocess.check_call(
                "kubectl annotate --namespace=\"%s\" ingress/%s --overwrite %s=\"%s\"" % (ing_namespace,
                                                                                          ing_name,
                                                                                          WHITELIST_ANN_NAME,
                                                                                          whitelist_string),
                shell=True)


if __name__ == "__main__":
    main()
