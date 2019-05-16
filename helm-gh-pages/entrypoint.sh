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
    ct lint --chart-dirs . --all || exit $?
  else
    echo "Skipping Linting of all helm charts"
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

echo "PR is: $PR"
echo "GITHUB_REF is: $GITHUB_REF"
echo "GITHUB_EVENT_NAME is: $GITHUB_EVENT_NAME"

# only consider a pull request
if [[ "$GITHUB_EVENT_NAME" == "pull_request" ]]; then
  echo "Processing pull request"
  lint_pr
  exit 0
# only consider a push event on the master branch
elif [[ "$GITHUB_EVENT_NAME" == "push" ]] && [[ "$GITHUB_EVENT_NAME" == "refs/heads/master" ]]; then
  URL=$1
  if [[ -z $1 ]] ; then
    echo "Helm repository URL parameter needed!" && exit 1;
  fi
  init
  lint && package && push
  exit 0
fi
exit 78
