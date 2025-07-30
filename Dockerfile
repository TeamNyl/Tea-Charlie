# ================================
# Build image
# ================================
FROM swift:6.0-bookworm AS build

RUN apt-get -q update && apt-get -q install -y libjemalloc-dev

WORKDIR /build
COPY ./Package.* ./
RUN swift package resolve \
    $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

COPY . .
RUN swift build -c release \
    --product backend \
    --static-swift-stdlib \
    -Xlinker -ljemalloc

WORKDIR /staging
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/backend" ./ \
 && cp "/usr/libexec/swift/linux/swift-backtrace-static" ./ \
 && strip ./backend ./swift-backtrace-static || true \
 && find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \; \
 && [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true \
 && [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

# ================================
# Run image
# ================================
FROM debian:bookworm-slim

RUN apt-get -q update && apt-get -q install -y \
    libjemalloc2 \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor
WORKDIR /app

COPY --from=build --chown=vapor:vapor /staging /app

ENV SWIFT_BACKTRACE=enable=no,sanitize=yes,threads=all,images=all,interactive=no

USER vapor:vapor
EXPOSE 8080
ENTRYPOINT ["./backend"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
