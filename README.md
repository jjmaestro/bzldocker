[![build-docker-images](https://github.com/jjmaestro/bzldocker/actions/workflows/build-docker-images.yaml/badge.svg?branch=main&event=push)](https://github.com/jjmaestro/bzldocker/actions/workflows/build-docker-images.yaml)

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

## Building and pushing the images

The images are built and deployed to the [GHCR registry] by the
[`build-docker-images`] GH Action.

### Image Flavors

The GH Action builds three different "flavors" (types of images): `base`,
`main` and `debug`.

The workflow will dynamically compose the Dockerfile to build the images. It
will use the `base.Dockerfile` as a "preamble" that will be concatenated to the
`<FLAVOR>.Dockerfile.flavor` to create the final `Dockerfile` that will be used
for building the image.

So, each image will be built from the following Dockerfiles (in order):
  * `base`: `base.Dockerfile`
  * `main`: `base.Dockerfile`, `main.Dockerfile.flavor`
  * `debug`: `base.Dockerfile`, `main.Dockerfile.flavor`, `debug.Dockerfile.flavor`

### Action Triggers

The `build-docker-images` action is triggered by a push to the `main` branch when it
affects the [`Dockerfile`]s (`base` or any of the flavors). It can also be
[triggered manually] via the [Actions web UI], the GH REST API or the GH CLI
tool:
```sh
gh workflow run build-docker-images
```

#### `push`

When triggered by a push, it will push to the GH registry two image tags for
every "image flavor":
  * a `version` tag where the version is the current date in ISO format
    (`YYYYMMDD`)
  * a `latest` tag pointing to the version tag

#### `workflow_dispatch` (manual)

When triggered by hand, the workflow will run as a `dry-run` by default. That
is, it will still set the `version` tag to the current date in ISO format but
**it won't tag `latest` or push the tags to the registry**.

To override these defaults, use the `IMAGE_VERSION`, `TAG_LATEST` and `PUSH`
variables, e.g.:
```sh
gh workflow run build-docker-images -f IMAGE_VERSION=20241101-testing
```

[reproducible-containers/repro-sources-list.sh]: https://github.com/reproducible-containers/repro-sources-list.sh
[Reproducible Builds]: https://reproducible-builds.org
[`git_repository`]: https://bazel.build/rules/lib/repo/git#git_repository
[`git_override`]: https://bazel.build/rules/lib/globals#git_override
[GHCR registry]: https://github.com/jjmaestro/bzldocker/pkgs/container/bzldocker%2Fdebian
[`build-docker-images`]: https://github.com/jjmaestro/bzldocker/blob/main/.github/workflows/build-docker-images.yaml
[`Dockerfile`]: https://github.com/jjmaestro/bzldocker/blob/main/Dockerfile
[triggered manually]: https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows#workflow_dispatch
[Actions web UI]: https://github.com/jjmaestro/bzldocker/actions/workflows/build-docker-images.yaml
