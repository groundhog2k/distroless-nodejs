FROM buildpack-deps:bookworm-curl AS nodejs

# Target NodeJS version in the docker image
ARG NODEJS_VERSION
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

FROM groundhog2k/distroless-base-image:bookworm
# copy unpacked NodeJS
COPY --from=nodejs /nodejs /nodejs
# copy symlink
COPY --from=nodejs /symlink /usr/bin

# adjust image settings (default user, locales)
ENV LC_ALL=C.UTF-8
USER 1001
ENTRYPOINT [ "/usr/bin/node" ]
