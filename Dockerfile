FROM tobapramudia/tkpd-demo:onbuild as builder

ADD . $GOPATH/src/github.com/tobapramudia/tkpd-demo

WORKDIR $GOPATH/src/github.com/tobapramudia/tkpd-demo

RUN go get -v \
	&& go build -o tkpd-demo .

# start from fresh alpine
FROM alpine

ENV TZ=Asia/Jakarta

# dependencies tools
RUN apk add --no-cache --no-progress -q \
    tzdata ca-certificates curl && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# copy assets from builder
COPY --from=builder /go/src/github.com/tobapramudia/tkpd-demo/tkpd-demo /app/
COPY --from=builder /go/src/github.com/tobapramudia/tkpd-demo/docker-entrypoint.sh /app/

## base working directory
WORKDIR /app

## healthcheck
HEALTHCHECK --interval=5s --timeout=1s \
  CMD curl -H 'User-Agent: local_health_check' -f http://127.0.0.1:1323/ping || exit 1

## create user uid/pid 1001
RUN addgroup -g 1001 -S app \
	&& adduser -u 1001 -S -D -G app app \
	&& chown -R app:app /app \
	&& chmod +x /app/tkpd-demo \
	&& chmod +x /app/docker-entrypoint.sh

## running as user (disable root on service)
USER app

## port listen
EXPOSE 1323

## add entrypoint
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# exec service
CMD [ "/app/tkpd-demo" ]