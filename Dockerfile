# ================================
# Build image (Ubuntu-based with Swift)
# ================================
FROM swift:6.0-noble AS build

RUN apt-get update -q && apt-get upgrade -y -q \
 && apt-get install -y -q libjemalloc-dev jq

WORKDIR /build

COPY ./Package.* ./
RUN swift package resolve \
    $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

COPY . ./

RUN swift build -c release \
    --product backend \
    --static-swift-stdlib \
    -Xlinker -ljemalloc

WORKDIR /staging

RUN cp "$(swift build --package-path /build -c release --show-bin-path)/backend" ./backend

RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

RUN [ -d /build/Public ] && { cp -r /build/Public ./ && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { cp -r /build/Resources ./ && chmod -R a-w ./Resources; } || true

RUN mkdir -p swift-lib \
 && swift -print-target-info \
    | jq -r '.paths.runtimeLibraryPaths[]' \
    | xargs -I {} find {} -type f -name '*.so' \
    | grep -E '(libswiftCore|libFoundation|libdispatch|libicu|libBlocksRuntime|libswift_|libicuuc|libicudata|libicui18n)' \
    | xargs -I {} cp -v {} swift-lib/ \
 && cp -v /usr/lib/x86_64-linux-gnu/libjemalloc.so.* swift-lib/ || true

# ================================
# Runtime image (Alpine)
# ================================
FROM alpine:3.20

# Create vapor user and group BEFORE any `USER` instructions
RUN addgroup -g 1000 -S vapor && adduser -u 1000 -S vapor -G vapor

# Install required runtime dependencies
RUN apk add --no-cache \
    libgcc \
    libstdc++ \
    jemalloc \
    ca-certificates \
    icu-libs \
    tzdata \
    curl

WORKDIR /app

# Copy app from builder with proper ownership
COPY --from=build /staging /app
RUN chown -R vapor:vapor /app

# Set runtime env vars
ENV SWIFT_BACKTRACE=enable=no,sanitize=yes,threads=all,images=all,interactive=no
ENV LD_LIBRARY_PATH=/app/swift-lib

# Switch to vapor user
USER vapor:vapor

EXPOSE 8080

ENTRYPOINT ["./backend"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
