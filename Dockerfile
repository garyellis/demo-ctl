FROM golang:1.20 AS build

ARG VERSION

WORKDIR /github.com/garyellis/demo-ctl


COPY . /github.com/garyellis/demo-ctl

RUN package=github.com/garyellis/demo-ctl/pkg/cmd VERSION=$VERSION && \
    BUILD_DATE="-X '${package}.BuildDate=$(date)'" && \
    GIT_COMMIT="-X ${package}.GitCommit=$(git rev-list -1 HEAD)" && \
    _VERSION="-X ${package}.Version=$VERSION" && \
    FLAGS="$GIT_COMMIT $_VERSION $BUILD_DATE" && \
    export GOOS=linux GOARCH=amd64 && go build -o /release/demo-ctl-${VERSION}_${GOOS}-${GOARCH} -ldflags "${FLAGS}" && \
    export GOOS=darwin GOARCH=amd64 && go build -o /release/demo-ctl-${VERSION}_${GOOS}-${GOARCH} -ldflags "${FLAGS}"

FROM ubuntu
COPY --from=build /release/ /release/
