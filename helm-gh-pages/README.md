# helm-gh-pages

This is a GitHub Action that publishes Helm charts to a Helm repository hosted on GitHub Pages.

The Helm gh-pages action takes 3 arguments:
1. Target path (eg './stable', '*', './stable/ambassador') (required)
2. GitHub Pages URL (required)

In order to use this action your Git repository should have a `gh-pages` branch published on GitHub Pages.

### Workflow

Package and push the Helm chart located at `chart/app` to the `gh-pages` branch on Git tag:

```terraform
workflow "Publish Helm chart" {
  on = "push"
  resolves = ["Helm gh-pages"]
}

action "Helm gh-pages" {
  uses = "billimek/gh-actions/helm-gh-pages@master"
  args = ["chart/app","https://user.github.io/app"]
  secrets = ["GITHUB_TOKEN"]
}
```

### Usage

Assuming your GitHub repository has a Helm chart named `app` located at `chart/app` the release procedure could be:

```bash
# make changes to the chart/app and bump the version inside Chart.yaml
> git commit -m "Bump chart version to 1.0.0"
> git push origin master
```

When you push the tag, GitHub will start the workflow and the helm-gh-pages will do the following:

* validates the chart by running Helm lint
* packages the chart(s) to `/github/home/pkg/app-1.0.0.tgz`
* checks out the `gh-pages` branch
* copies the `app-1.0.0.tgz` from `/github/home` to `/github/workspace`
* updates the Helm repository index using the GitHub pages URL
* commits the chart package and the Helm repository index
* pushed the changes to `gh-pages` using the GitHub token secret

In couple of seconds GitHub will publish the change to GitHub Pages and your chart v1.0.0 will be available for download.
