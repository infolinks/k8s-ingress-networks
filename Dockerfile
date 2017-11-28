FROM infolinks/cloud-sdk:178.0.0-alpine
MAINTAINER Arik Kfir <arik@infolinks.com>
RUN apk --no-cache --update add jq tree bash python3 && \
    gcloud components install kubectl
COPY update_ingresses.py scan-ingress-networks.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/scan-ingress-networks.sh /usr/local/bin/update_ingresses.py
ENTRYPOINT ["/usr/local/bin/scan-ingress-networks.sh"]
