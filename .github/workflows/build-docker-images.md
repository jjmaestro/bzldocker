# [`build-docker-images.yaml`]

Workflow to build and push Docker images from the [`Dockerfile`] in the repo.

The workflow builds the images, pushes them to the GHCR registry and links them
with the repo.

## ⚡ Triggers

The workflow is triggered by changes that modify the `Dockerfile` or the
workflow YAML file, via pushes to any branch (except `wip/**` branches) or pull
request to the `main` branch.

It can also be [triggered manually] via the [Actions web UI], the GH REST API
or the GH CLI tool, e.g.:

```sh
gh workflow run build-docker-images
```

### 🔀 `push` or PR

When triggered by a `push` or PR event the action will:

1. Determine which `Dockerfile`s are affected (defaults to all).

2. For those `Dockerfile`s, determine the build targets ("image flavors") in
   it.

3. Filter the build targets:

   * first with `RE_TARGET_INCLUDE`, which defaults to empty so it will match
     all build targets.
   * then with `RE_TARGET_EXCLUDE`: set by default to remove some of the build
     targets (those marked with `\-nobuild`).

4. Spawn a `docker/build-push-action` job for each build target. Each image
   will be pushed to the registry with three tags:

   * a `sha` tag with the short hash of the commit that triggered the push
   * a `date` tag with the current date in ISO format (`YYYYMMDD`)
   * a `latest` tag

### 🕹️ `workflow_dispatch` (manual)

When triggered manually (`workflow_dispatch` event) the workflow defaults to
"running in test mode" (it will follow the same steps as a `push` run but with
different default values, see `workflow_dispatch.inputs`):

* `RE_TARGET_INCLUDE` set to `^debian$` and
* `RE_TARGET_EXCLUDE` set to the same pattern as in the `push` event

This effectively limits the build targets to only the "base flavor" (the
`debian` image).

The "test run" also limits the `PLATFORMS` to `linux/amd64`, to further reduce
the time and cost of a test run.

Finally, it will build that target but **it won't tag `latest` or push any of
the image tags to the registry**.

This "test mode" behavior can be changed by setting the
`workflow_dispatch.inputs` variables: `PLATFORMS`, `RE_TARGET_INCLUDE`,
`RE_TARGET_EXCLUDE`, `TAG_DATE`, `TAG_LATEST` and `PUSH`, e.g.:

```sh
gh workflow run build-docker-images \
  -f RE_TARGET_INCLUDE=debian -f TAG_DATE=20241111
```

[Actions web UI]: https://github.com/jjmaestro/bzldocker/actions/workflows/build-docker-images.yaml
[`Dockerfile`]: https://github.com/jjmaestro/bzldocker/blob/main/Dockerfile
[`build-docker-images.yaml`]: build-docker-images.yaml
[triggered manually]: https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows#workflow_dispatch
