# Bazel Docker Image

Multi-platform Bazel Docker image:
  * platforms: `amd64`, `arm64`
  * [reproducible-containers/repro-sources-list.sh] for [Reproducible Builds]
  * non-root user (so e.g. `rules_python` works without
    `ignore_root_user_error = True`)
  * Bazelisk with Bazel cached for the non-root user
  * `ca-certificates` for SSL cert verification
  * `git` for Bazel's [`git_repository`], [`git_override`], etc.
  * `.bashrc` with bash and Bazel autocompletion

## Building and pushing the image

The image is built and deployed to the [GHCR registry] by the [`docker-image`]
GH Action.

This action is triggered by a push to the `main` branch when it affects the
[`Dockerfile`]. It can also be [triggered manually] via the [Actions web UI],
the GH REST API or the GH CLI tool:
```sh
gh workflow run docker-image
```

When triggered by a push, it will push to the GH registry two image tags:
  * a `version` tag where the version is the current date in ISO format
    (`YYYYMMDD`)
  * a `latest` tag pointing to the version tag

When triggered by hand, the workflow will run as a `dry-run` by default. That
is, it will still set the `version` tag to the current date in ISO format but
**it won't tag `latest` or push the tags to the registry**.

To override these defaults, use the `IMAGE_VERSION`, `TAG_LATEST` and `PUSH`
variables, e.g.:
```sh
gh workflow run docker-image -f IMAGE_VERSION=20241101-testing
```

[reproducible-containers/repro-sources-list.sh]: https://github.com/reproducible-containers/repro-sources-list.sh
[Reproducible Builds]: https://reproducible-builds.org
[`git_repository`]: https://bazel.build/rules/lib/repo/git#git_repository
[`git_override`]: https://bazel.build/rules/lib/globals#git_override
[GHCR registry]: https://github.com/jjmaestro/bzldocker/pkgs/container/bzldocker%2Fdebian
[`docker-image`]: https://github.com/jjmaestro/bzldocker/blob/main/.github/workflows/docker-image.yaml
[`Dockerfile`]: https://github.com/jjmaestro/bzldocker/blob/main/Dockerfile
[triggered manually]: https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows#workflow_dispatch
[Actions web UI]: https://github.com/jjmaestro/bzldocker/actions/workflows/docker-image.yaml
