FROM golang:alpine AS build-env

# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN mkdir /go/src/app && apk update && apk add git

ADD main.go config.json go.mod go.sum /go/src/app/

WORKDIR /go/src/app

# ENV GOPROXY=https://goproxy.io

#RUN go mod download && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o app .
RUN go mod download

ENV CGO_ENABLED=0

ENV GOOS=linux

RUN go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o app .

FROM scratch

WORKDIR /app

COPY --from=build-env /go/src/app/app .

COPY --from=build-env /go/src/app/config.json .

ENTRYPOINT ["./app"]