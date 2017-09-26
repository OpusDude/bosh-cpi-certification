#!/usr/bin/env bash

set -e

: ${DIRECTOR_VARS_FILE:?}
: ${INFRASTRUCTURE:?}

source pipelines/shared/utils.sh

metadata="$( cat environment/metadata )"

additional_director_vars=""
if [[ -e pipelines/${INFRASTRUCTURE}/assets/director-vars ]]; then \
  additional_director_vars="-l <( pipelines/${INFRASTRUCTURE}/assets/director-vars environment/metadata )"
fi

bosh2 int \
  -o bosh-deployment/${INFRASTRUCTURE}/cpi.yml \
  -o bosh-deployment/local-dns.yml \
  -o bosh-deployment/jumpbox-user.yml \
  -o pipelines/shared/assets/ops/custom-releases.yml \
  -o pipelines/${INFRASTRUCTURE}/assets/ops/custom-cpi-release.yml \
  $( echo ${OPTIONAL_OPS_FILE} ) \
  -v bosh_release_uri="file://$(echo bosh-release/*.tgz)" \
  -v cpi_release_uri="file://$(echo cpi-release/*.tgz)" \
  -v stemcell_uri="file://$(echo stemcell/*.tgz)" \
  -v director_name=bosh \
  -l <( echo "${DIRECTOR_VARS_FILE}" ) \
  $(echo ${additional_director_vars}) \
  bosh-deployment/bosh.yml > /tmp/director.yml

bosh2 int \
  -l environment/metadata \
  /tmp/director.yml > director-config/director.yml
