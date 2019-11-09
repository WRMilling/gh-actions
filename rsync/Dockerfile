FROM gcr.io/cloud-builders/kubectl

LABEL "name"="Rsync Action"
LABEL "maintainer"="Winston R. Milling <Winston@Milli.ng>"
LABEL "version"="1.0.0"

LABEL "com.github.actions.icon"="terminal"
LABEL "com.github.actions.color"="gray-dark"
LABEL "com.github.actions.name"="rsync"
LABEL "com.github.actions.description"="This is an Action to run Rsync commands."


RUN apt-get update && apt-get -y --no-install-recommends install rsync openssh-client

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

