<!-- markdownlint-capture -->
<!-- markdownlint-disable MD013 MD033 MD041 -->
<p style="text-align: left;">
    <img src="logo.svg" alt="bzldocker logo" title="logo" align="left" height="60" />
</p>
<!-- markdownlint-restore -->

# `bzldocker`

[![pre-commit](
    ../../actions/workflows/pre-commit.yaml/badge.svg
)](../../actions/workflows/pre-commit.yaml)

Multi-platform (`amd64`, `arm64`) Bazel Docker image.

## ✨ Features

* Debian based
* Multi-platform: `amd64`, `arm64`
* `nonroot` user
* Bazelisk with Bazel cached
* Uses [reproducible-containers/repro-sources-list.sh] for installing packages
  from a snapshot to help [Reproducible Builds].

## 🧱 Building

To build the Docker image run:

<!-- markdownlint-disable MD013 -->
```sh
docker buildx build \
    --file Dockerfile \
    --platform "linux/amd64,linux/arm64" \
    --build-arg "BASE_IMAGE=debian" \
    --build-arg "BASE_IMAGE_TAG=stable-20241111-slim" \
    --build-arg "REPRODUCIBLE_CONTAINERS_VERSION=0.1.4" \
    --build-arg "BAZELISK_VERSION=1.20.0" \
    --build-arg "BAZEL_VERSION=7.3.1" \
    --label "org.opencontainers.image.source=https://github.com/jjmaestro/bzldocker" \
    --tag "ghcr.io/jjmaestro/bzldocker/debian:20241111" \
    .
```
<!-- markdownlint-enable -->

To push it to the [GHCR registry] run

```sh
docker login --username $USER ghcr.io
docker image push "ghcr.io/jjmaestro/bzldocker/debian:20241111"
```

> [!NOTE]
> Check how to [authenticate with the GH container registry], you will usually
> need to generate a GH Personal Access Token with (at least) `write:packages`
> scope.

## 💡 Contributing

Please feel free to open [issues] and [PRs], contributions are always welcome!
See [CONTRIBUTING.md] for more info on how to work with this repo.

[CONTRIBUTING.md]: CONTRIBUTING.md
[GHCR registry]: https://github.com/jjmaestro/bzldocker/pkgs/container/bzldocker%2Fdebian
[PRs]: ../../pulls
[Reproducible Builds]: https://reproducible-builds.org
[authenticate with the GH container registry]: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry
[issues]: ../../issues
[reproducible-containers/repro-sources-list.sh]: https://github.com/reproducible-containers/repro-sources-list.sh
