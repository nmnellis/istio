#!/usr/bin/env bash

export HUB="gcr.io/istio-testing"
export TAG="89ec48242aec6cc6881413d5c09b5438a8aa07e8"

#make e2e_all E2E_ARGS="--auth_enable=false --v1alpha3=true --egress=false --ingress=false --rbac_enable=true --v1alpha1=false --cluster_wide --use-automatic-injection=false --mixer_hub=$HUB --mixer_tag=$TAG --pilot_hub=$HUB --pilot_tag=$TAG --proxy_hub=$HUB --proxy_tag=$TAG --ca_hub=$HUB --ca_tag=$TAG"

make test/local/noauth/e2e_pilotv2 E2E_ARGS="--auth_enable=false --v1alpha3=true --egress=false --ingress=false --rbac_enable=true --v1alpha1=false --cluster_wide --use-automatic-injection=false --mixer_hub=$HUB --mixer_tag=$TAG --pilot_hub=$HUB --pilot_tag=$TAG --proxy_hub=$HUB --proxy_tag=$TAG --ca_hub=$HUB --ca_tag=$TAG"