#!/usr/bin/env sh

set -o errexit
set -o pipefail

init() {
  helm init --client-only
  mkdir /github/home/pkg
}

lint() {
  echo "Linting in $PWD"
  if [[ -z $SKIP_LINTING ]] ; then
    echo "Skipping Linting of all helm charts"
  else
    ct lint --chart-dirs . --all || exit $?
  fi
}

lint_pr() {
  echo "Linting in $PWD for a pull request"
  ct lint --chart-dirs . || exit $?
}

package() {
  helm package $(find . -type f -name "Chart.yaml" -exec dirname {} \;) --destination /github/home/pkg/
}

push() {
  if find /github/home/pkg/ -type f -name "*.tgz" > /dev/null; then    
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

if [[ -z $PR ]] ; then
  URL=$1
  if [[ -z $1 ]] ; then
    echo "Helm repository URL parameter needed!" && exit 1;
  fi
  init
  lint && package && push
else
  echo "Processing pull request"
  lint_pr
fi
