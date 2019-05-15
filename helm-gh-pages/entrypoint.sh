#!/usr/bin/env bash

set -o errexit
set -o pipefail

init() {
  helm init --client-only
  mkdir /github/home/pkg
}

package() {
    helm lint ${CHART}
    mkdir /github/home/pkg
    helm package ${CHART} --destination /github/home/pkg/
}

push() {
  git config user.email ${GITHUB_ACTOR}@users.noreply.github.com
  git config user.name ${GITHUB_ACTOR}
  git remote set-url origin ${REPOSITORY}
  git checkout gh-pages
  mv /github/home/pkg/*.tgz .
  helm repo index . --url ${URL}
  git add .
  git commit -m "Publish Helm chart(s)"
  git push origin gh-pages
}

REPOSITORY="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

TARGET=$1
if [[ -z "$TARGET" ]]; then
	echo "Set a target eg './stable', '*', './stable/ambassador'" && exit 1;
fi

URL=$2
if [[ -z $2 ]] ; then
  echo "Helm repository URL parameter needed!" && exit 1;
fi

init

if [[ -f "$TARGET/Chart.yaml" ]]; then
	CHART=$(basename "$TARGET")
	echo "Packaging $CHART from $TARGET"
	package
	exit $?
fi

for dirname in "$TARGET"/*/; do
	if [ ! -e "$dirname/Chart.yaml" ]; then
		echo "No charts found for $TARGET"
		continue
	fi

	CHART=$(basename "$dirname")
	echo "Packaging $CHART from $dirname"
	package || exit $?
done

push
