#!/usr/bin/env sh

set -o errexit
set -o pipefail

init() {
  # helm init --client-only
  mkdir /github/home/pkg
}

lint() {
  echo "Linting in $PWD"
  ls -al
  ct lint --chart-dirs . || exit $?
}

package() {
  helm package ${1} --destination /github/home/pkg/
}

push() {
  if [[ $(find /github/home/pkg/ -type f -name "*.tgz") ]]; then
    echo "Processing $(find /github/home/pkg/ -type f -name "*.tgz")"
    git config user.email ${GITHUB_ACTOR}@users.noreply.github.com
    git config user.name ${GITHUB_ACTOR}
    git remote set-url origin ${REPOSITORY}
    git checkout gh-pages
    mv /github/home/pkg/*.tgz .
    helm repo index . --url ${URL}
    git add .
    git commit -m "Publish Helm chart(s)"
    git push origin gh-pages
  else
    echo "Nothing changed - no new packages to push!"
    exit 78
  fi 
}

REPOSITORY="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

# TARGET=$1
# if [[ -z "$TARGET" ]]; then
# 	echo "Set a target eg './stable', '*', './stable/ambassador'" && exit 1;
# fi

URL=$1
if [[ -z $1 ]] ; then
  echo "Helm repository URL parameter needed!" && exit 1;
fi

init

lint

for chart_dir in $(ct list-changed --chart-dirs .); do
  echo "Processing $chart_dir"
  package "$chart_dir"
done

push
