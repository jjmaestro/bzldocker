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

The image is built and deployed to the [GHCR registry].

To build the image run:

```sh
docker buildx build \
    --file Dockerfile \
    --platform "linux/amd64,linux/arm64" \
    --build-arg "BASE_IMAGE=debian" \
    --build-arg "BASE_IMAGE_TAG=bookworm-20240926-slim" \
    --build-arg "REPRODUCIBLE_CONTAINERS_VERSION=0.1.4" \
    --build-arg "BAZELISK_VERSION=1.20.0" \
    --build-arg "BAZEL_VERSION=7.4.0" \
    --label "org.opencontainers.image.source=https://github.com/jjmaestro/bzldocker" \
    --tag "ghcr.io/jjmaestro/bzldocker/debian:20241108" \
    .
```

And to push the image, run:
```sh
docker login --username $USER ghcr.io
docker image push "ghcr.io/jjmaestro/bzldocker/debian:20241108"
```

> [!NOTE]
> Check how to [authenticate with the GH container registry], you will usually
> need to generate a GH Personal Access Token with (at least) `write:packages`
> scope.

[reproducible-containers/repro-sources-list.sh]: https://github.com/reproducible-containers/repro-sources-list.sh
[Reproducible Builds]: https://reproducible-builds.org
[`git_repository`]: https://bazel.build/rules/lib/repo/git#git_repository
[`git_override`]: https://bazel.build/rules/lib/globals#git_override
[GHCR registry]: https://github.com/jjmaestro/bzldocker/pkgs/container/bzldocker%2Fdebian
[authenticate with the GH container registry]: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry
