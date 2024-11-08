ARG BASE_IMAGE=debian
ARG BASE_IMAGE_TAG=bookworm-slim
FROM $BASE_IMAGE:$BASE_IMAGE_TAG AS base

ARG TARGETOS
ARG TARGETARCH

ARG REPRODUCIBLE_CONTAINERS_VERSION

ADD --chmod=0755 \
    https://raw.githubusercontent.com/reproducible-containers/repro-sources-list.sh/refs/tags/v${REPRODUCIBLE_CONTAINERS_VERSION}/repro-sources-list.sh \
    /usr/local/bin

ENV DEBIAN_FRONTEND=noninteractive

RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    KEEP_CACHE=1 /usr/local/bin/repro-sources-list.sh

ENV APT_INSTALL='\
set -euxo pipefail; \
\
apt_install() { \
    apt-get update; \
\
    apt-get install -y \
    --no-install-recommends \
    --no-install-suggests \
    $@; \
\
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/ldconfig/aux-cache; \
}; \
'

# setup ca-certificates for SSL cert verification
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install ca-certificates
EOF

## setup bash autocompletion
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install bash-completion

cat <<EOT >> ~/.bashrc

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

EOT
EOF

# setup bazelisk
ARG BAZELISK_VERSION
ADD --chmod=755 \
    https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-${TARGETOS}-${TARGETARCH} \
    /usr/bin
RUN ln -s /usr/bin/bazelisk-${TARGETOS}-${TARGETARCH} /usr/bin/bazel

# bazel: git_override
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install git
EOF

## non-root user (rules_python notoriously fails when running as root)
ENV USERNAME=nonroot

RUN /bin/bash <<EOF
set -euxo pipefail

useradd \
    --comment 'Non-root User' \
    --create-home \
    --shell /bin/bash \
    $USERNAME
EOF

USER $USERNAME

# setup bazel: running Bazelisk's bazel will download USE_BAZEL_VERSION
# and will cache it for the current user
ARG BAZEL_VERSION
ARG USE_BAZEL_VERSION=$BAZEL_VERSION
RUN /usr/bin/bazel --version

WORKDIR /home/$USERNAME/.local/share/bazel-completion

# setup bazel autocompletion
ADD --chown=$USERNAME:$USERNAME \
    https://raw.githubusercontent.com/bazelbuild/bazel/$BAZEL_VERSION/scripts/bazel-complete-header.bash .
ADD --chown=$USERNAME:$USERNAME \
    https://raw.githubusercontent.com/bazelbuild/bazel/$BAZEL_VERSION/scripts/bazel-complete-template.bash .

RUN /bin/bash <<EOF
set -euxo pipefail

echo -e '\n# Bazelisk bazel autocompletion hack:' >> ~/.bashrc
echo '# https://github.com/bazelbuild/bazelisk/issues/29#issuecomment-1696326105' >> ~/.bashrc
echo "source ~/.local/share/bazel-completion/bazel-complete-header.bash" >> ~/.bashrc
echo "source ~/.local/share/bazel-completion/bazel-complete-template.bash" >> ~/.bashrc

/usr/bin/bazel help completion > ~/.local/share/bazel-completion/bazel-help-completion.bash
echo "source ~/.local/share/bazel-completion/bazel-help-completion.bash" >> ~/.bashrc
EOF
