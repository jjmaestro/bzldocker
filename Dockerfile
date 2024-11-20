ARG BASE_IMAGE=debian
ARG BASE_IMAGE_TAG=stable-slim
FROM $BASE_IMAGE:$BASE_IMAGE_TAG AS debian

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

# install ca-certificates for SSL cert verification
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install ca-certificates
EOF

# install bazelisk
ARG BAZELISK_VERSION
ADD --chmod=755 \
    https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-${TARGETOS}-${TARGETARCH} \
    /usr/bin
RUN ln -s /usr/bin/bazelisk-${TARGETOS}-${TARGETARCH} /usr/bin/bazel

# bazel dependencies: git_override
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install git
EOF

# allow to create a non-root user
# (rules_python notoriously fails when running as root)
ARG USERNAME=nonroot
ARG HOMEDIR=/home/$USERNAME

ENV USERNAME=$USERNAME
ENV HOMEDIR=$HOMEDIR

RUN /bin/bash <<EOF
set -euxo pipefail

[[ "$USERNAME" != "root" ]] && useradd \
    --comment 'Non-root User' \
    --create-home --home-dir "$HOMEDIR" \
    --shell /bin/bash \
    $USERNAME
EOF

# install bazel: running bazel --version triggers Bazelisk to download Bazel
ARG BAZEL_VERSION
ARG USE_BAZEL_VERSION=$BAZEL_VERSION

USER root
RUN /usr/bin/bazel --version

USER $USERNAME
RUN /bin/bash <<EOF
set -euxo pipefail

[[ "$USERNAME" != "root" ]] && /usr/bin/bazel --version
EOF


FROM debian AS debian-cc

USER root

ARG DEPS_CC_TOOLCHAIN="libc6-dev gcc g++"
ENV DEPS_CC_TOOLCHAIN="$DEPS_CC_TOOLCHAIN"

## install dependencies for CC toolchain
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install $DEPS_CC_TOOLCHAIN
EOF

USER $USERNAME


FROM debian-cc AS debian-debug

USER root

# install other tools
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install vim curl grep less file tree bsdextrautils
EOF

## setup bash autocompletion
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install bash-completion
EOF

USER $USERNAME

RUN /bin/bash <<EOF
set -euxo pipefail

if [[ "$(whoami)" == "root" ]]; then
    cat <<EOT >> ~/.bashrc

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

EOT
fi
EOF

WORKDIR $HOMEDIR/.local/share/bazel-completion

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

# misc
RUN /bin/bash <<EOF
set -euxo pipefail

if [[ "$(whoami)" == "root" ]]; then
    echo -e '\nalias ls="ls --color=auto"' >> ~/.bashrc
fi
EOF


FROM debian-debug AS debian-docker

USER root

## install docker
RUN /bin/bash <<EOF
$APT_INSTALL

# --- 8< https://docs.docker.com/engine/install/debian/ ---
# Add Docker's official GPG key:
apt_install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# --- 8< https://docs.docker.com/engine/install/debian/ ---

adduser root docker
if [[ "$USERNAME" != "root" ]]; then
    adduser "$USERNAME" docker
fi
EOF

USER $USERNAME

## setup docker autocompletion: https://docs.docker.com/engine/cli/completion/
RUN /bin/bash <<EOF
set -euxo pipefail

mkdir -p ~/.local/share/bash-completion/completions
docker completion bash > ~/.local/share/bash-completion/completions/docker
EOF
