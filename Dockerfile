FROM buildpack-deps:bullseye-curl AS distroless

# Debian rootfs download
ARG BULLSEYE_ROOTFS="https://github.com/debuerreotype/docker-debian-artifacts/raw/de5fb2efd50a009baa2aaccd2b7874ec728bd7a9/bullseye/slim/rootfs.tar.xz"
# ARG BOOKWORM_ROOTFS="https://github.com/debuerreotype/docker-debian-artifacts/raw/de5fb2efd50a009baa2aaccd2b7874ec728bd7a9/bookworm/slim/rootfs.tar.xz"

WORKDIR /debianroot
RUN apt-get update && apt-get install -y xz-utils
# download and extract debian rootfs into workdir
RUN curl -SL ${BULLSEYE_ROOTFS} -o rootfs.tar.xz
# extract only the minimum that is necessary to execute NodeJS
RUN tar xvf rootfs.tar.xz usr/lib/locale lib/x86_64-linux-gnu lib64 etc/os-release etc/ld.so.conf.d etc/debian_version usr/lib/x86_64-linux-gnu usr/lib/os-release --same-owner

# remove downloaded archive
RUN rm rootfs.tar.xz

FROM buildpack-deps:bullseye-curl AS nodejs

# Target NodeJS version in the docker image
ARG NODEJS_VERSION="v16.14.0"
# Base URL for the download
ARG NODEJS_BASE_URL="https://nodejs.org/download/release"

# Download and unpack NodeJS
RUN mkdir -p /nodejs \
    && curl -fsSL -o /tmp/nodejs.tar.gz ${NODEJS_BASE_URL}/${NODEJS_VERSION}/node-${NODEJS_VERSION}-linux-x64.tar.gz \
    && tar -xzf /tmp/nodejs.tar.gz -C /nodejs --strip-components=1 \
    && chown root:root -R /nodejs
# create symlinks to executables
RUN mkdir -p /symlink \
    && ln -s /nodejs/bin/node /symlink/node && ln -s /nodejs/bin/npm /symlink/npm && ln -s /nodejs/bin/npx /symlink/npx && ln -s /nodejs/bin/corepack /symlink/corepack

FROM scratch
# copy debian rootfs parts
COPY --from=distroless /debianroot /
# copy unpacked NodeJS
COPY --from=nodejs /nodejs /nodejs
# copy symlink
COPY --from=nodejs /symlink /usr/bin

# adjust image settings (default user, locales)
ENV LC_ALL=C.UTF-8
USER 1001
ENTRYPOINT [ "/usr/bin/node" ]
