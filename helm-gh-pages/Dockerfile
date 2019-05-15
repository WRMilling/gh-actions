FROM quay.io/helmpack/chart-testing

LABEL "name"="Helm Chart Test Action"
LABEL "maintainer"="Jeff Billimek <jeff@billimek.com>"
LABEL "version"="1.0.0"

LABEL "com.github.actions.icon"="package"
LABEL "com.github.actions.color"="green"
LABEL "com.github.actions.name"="Helm Chart Test"
LABEL "com.github.actions.description"="This is an Action to lint, package, and publish Helm charts to GitHub Pages."


COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
