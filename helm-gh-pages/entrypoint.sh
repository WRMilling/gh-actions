#!/usr/bin/env sh

set -o errexit
set -o pipefail

init() {
  helm init --client-only
  mkdir /github/home/pkg
}

lint() {
  echo "Linting in $PWD"
  # ct lint --chart-dirs . --all || exit $?
}

package() {
  helm package $(find . -type f -name "Chart.yaml" -exec dirname {} \;) --destination /github/home/pkg/
}

push() {
  echo "pushing charts: "
  echo $(find /github/home/pkg/ -type f -name "*.tgz")
  if find /github/home/pkg/ -type f -name "*.tgz" > /dev/null; then    
    git config user.email ${GITHUB_ACTOR}@users.noreply.github.com
    git config user.name ${GITHUB_ACTOR}
    git remote set-url origin ${REPOSITORY}
    git checkout gh-pages
    cd ..
    helm repo index --url "$URL" --merge workspace/index.yaml /github/home/pkg
    cd workspace
    mv /github/home/pkg/*.tgz .
    mv /github/home/pkg/index.yaml .
    # helm repo index . --url ${URL}
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

lint && package && push

# for chart_dir in $(ct list-changed --chart-dirs .); do
#   echo "Processing $chart_dir"
#   package "$chart_dir"
# done
