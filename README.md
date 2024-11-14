[![build-docker-images](https://github.com/jjmaestro/bzldocker/actions/workflows/build-docker-images.yaml/badge.svg?branch=main&event=push)](https://github.com/jjmaestro/bzldocker/actions/workflows/build-docker-images.yaml)

# Bazel Docker Image

Debian multi-platform Bazel Docker images with:
  * platforms: `amd64`, `arm64`
  * [reproducible-containers/repro-sources-list.sh] for [Reproducible
    Builds]
  * non-root user (so e.g. `rules_python` works without
    `ignore_root_user_error = True`)
  * Bazelisk with Bazel cached for the non-root user
  * `ca-certificates` for SSL cert verification
  * `git` for Bazel's [`git_repository`], [`git_override`], etc.
  * `.bashrc` with bash and Bazel autocompletion

## Building and pushing the images

The [`build-docker-images`] [Github Actions workflow] builds the
images, pushes them to the [GHCR registry] and links them with this
repo.

## Image "flavors"

The workflow builds different "flavors" (types of images). Each
"flavor" corresponds with a [Docker named build stage] (`... AS
<NAME>`) in the [`Dockerfile`].

### Triggers

The workflow is triggered when a push to the `main` or `testing`
branch contains changes to the `Dockerfile`. It can also be [triggered
manually] via the [Actions web UI], the GH REST API or the GH CLI web
UI, the GH REST API or the GH CLI tool, e.g.:
```sh
gh workflow run build-docker-images
```

#### `push`

When triggered by a `push` event the action will:

1. Determine which `Dockerfile`s are affected.

2. For those `Dockerfile`s, determine the build targets in it.

3. Filter the build targets:
   * first with `RE_TARGET_INCLUDE`, which defaults to empty so it
     will match all build targets.
   * then with `RE_TARGET_EXCLUDE`: set by default to remove some of
     the build targets (those marked with `\-nobuild`).

4. Finally, it will spawn a `docker/build-push-action` job for each of
   the build targets. For every image built it will push to the
   registry three image tags:
   * a `sha` tag with the short hash of the commit that triggered the
     push
   * a `date` tag with the current date in ISO format (`YYYYMMDD`)
   * a `latest` tag

#### `workflow_dispatch` (manual)

When triggered manually (`workflow_dispatch` event) the workflow will
default to "running in test mode": it will follow the same steps as a
`push` run but with different default values (see
`workflow_dispatch.inputs`):
  * `RE_TARGET_INCLUDE` set to `^debian$` and
  * `RE_TARGET_EXCLUDE` set to the same pattern as in the `push` event

This effectively limits the build targets to only the "base" `debian`
image.

The "test run" also limits the `PLATFORMS` to `linux/amd64`, to
further reduce the cost and time of a test run.

Finally, it will build that target but **it won't tag `latest` or push
any of the image tags to the registry**.

This "test mode" behavior can be changed by setting the
`workflow_dispatch.inputs` variables: `RE_TARGET_EXCLUDE`,
`RE_TARGET_INCLUDE`, `PLATFORMS`, `TAG_DATE`, `TAG_LATEST` and `PUSH`,
e.g.:
```sh
gh workflow run build-ci-docker-images \
  -f RE_TARGET_INCLUDE=ubuntu2404 -f TAG_DATE=20241101
```

[reproducible-containers/repro-sources-list.sh]: https://github.com/reproducible-containers/repro-sources-list.sh
[Reproducible Builds]: https://reproducible-builds.org
[`git_repository`]: https://bazel.build/rules/lib/repo/git#git_repository
[`git_override`]: https://bazel.build/rules/lib/globals#git_override
[`build-docker-images`]: https://github.com/jjmaestro/bzldocker/blob/main/.github/workflows/build-docker-images.yaml
[Github Actions workflow]: https://docs.github.com/actions
[GHCR registry]: https://github.com/jjmaestro/bzldocker/pkgs/container/bzldocker%2Fdebian
[Docker named build stage]: https://docs.docker.com/build/building/multi-stage/#name-your-build-stages
[`Dockerfile`]: https://github.com/jjmaestro/bzldocker/blob/main/Dockerfile
[triggered manually]: https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows#workflow_dispatch
[Actions web UI]: https://github.com/jjmaestro/bzldocker/actions/workflows/build-docker-images.yaml
