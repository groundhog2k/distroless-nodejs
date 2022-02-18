# distroless-nodejs

This project creates a distroless NodeJS container image (for a headless usage)

It's based on NodeJS and the needed libraries which are taken from latest Debian-Slim image.

## How it was created

The Dockerfile contains of 3 sections:

1. Download and unpack necessary files from Debian rootfs - (distroless layer)
2. Get latest NodeJS - (nodejs layer)
3. Merge content of "distroless layer" and "nodejs layer" into a new blank image
4. Make sure the default user of the image is not a root user. (UID 1001)

## Important to know

The image has a predefined entrypoint which is important for final usage:

`ENTRYPOINT [ "/nodejs/bin/node" ]`

The default user of this image has the UID `1001`.

## How to use

Simplest scenario is to create an own image by using this image as a base and add the compiled Java application (.JAR) as another layer.
An example Dockerfile would look like this:

Simplest scenario is to create an own image by using this image as a base and add webpackage as another layer.
An example Dockerfile would look like this:

```Dockerfile
FROM groundhog2k/distroless-nodejs:latest
WORKDIR /usr/app
COPY /webpackage /usr/app
CMD [ "index.js" ]
```

An alternative is to overwrite the entrypoint like this:

`ENTRYPOINT [ "/nodejs/bin/node", "index.js" ]`
