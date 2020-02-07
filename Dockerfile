FROM crystallang/crystal:0.26.1 as build
WORKDIR /src/
COPY . .
RUN shards install
RUN crystal build --release --link-flags="-static" src/server.cr

# hadolint ignore=DL3007
FROM alpine:latest

# hadolint ignore=DL3018
RUN apk -U add --no-cache curl jq bash
COPY --from=build /src/startup.sh /startup.sh
COPY --from=build /src/server /server
COPY --from=build /src/code_hash.txt /code_hash.txt
HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -f -s http://localhost:3000/health || exit 1
EXPOSE 3000
ENTRYPOINT ["bash", "/startup.sh"]
