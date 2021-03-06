APP?=hook
PORT?=8000
PROJECT?=github.com/gotoolkit/hook

RELEASE?=0.0.1
COMMIT?=$(shell git rev-parse --short HEAD)
BUILD_TIME?=$(shell date -u '+%Y-%m-%d_%H:%M:%S')

GOOS?=linux
GOARCH?=amd64

CONTAINER_IMAGE?=containerize/${APP}

clean:
	rm -f ${APP}

build: clean
	CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} go build \
		-ldflags "-s -w -X ${PROJECT}/pkg/version.Release=${RELEASE} \
		-X ${PROJECT}/pkg/version.Commit=${COMMIT} \
		-X ${PROJECT}/pkg/version.BuildTime=${BUILD_TIME} " \
		-o ${APP}

run: build
	PORT=${PORT} ./${APP}

test:
	go test -v -race ./...


container: build
	docker build -t ${CONTAINER_IMAGE}:${RELEASE} .

rund: container
	docker stop ${APP} || true && docker rm ${APP} || true
	docker run --name ${APP} -p ${PORT}:${PORT} --rm -e "PORT=${PORT}" ${CONTAINER_IMAGE}:${RELEASE}

push: container
	docker push ${CONTAINER_IMAGE}:${RELEASE}