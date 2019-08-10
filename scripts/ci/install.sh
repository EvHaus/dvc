#!/bin/bash

set -x
set -e

scriptdir="$(dirname $0)"

# NOTE: it is not uncommon for pip to hang on travis for what seems to be
# networking issues. Thus, let's retry a few times to see if it will eventially
# work or not.
$scriptdir/retry.sh pip install --upgrade pip setuptools wheel
$scriptdir/retry.sh pip install .[all,tests]
# Installing specific packages to workaround some bugs. Please see [1] and [2]
#
# [1] https://github.com/iterative/dvc/issues/2284
# [2] https://github.com/iterative/dvc/issues/2387
$scriptdir/retry.sh pip uninstall -y azure-storage-blob
$scriptdir/retry.sh pip install psutil azure-storage-blob==1.5.0

git config --global user.email "dvctester@example.com"
git config --global user.name "DVC Tester"

if [[ "$TRAVIS_PULL_REQUEST" == "false" && \
      "$TRAVIS_SECURE_ENV_VARS" == "true" ]]; then
	aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
	aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
	aws configure set region us-east-2

	openssl enc -d -aes-256-cbc -md md5 -k $GCP_CREDS -in scripts/ci/gcp-creds.json.enc -out scripts/ci/gcp-creds.json
fi
