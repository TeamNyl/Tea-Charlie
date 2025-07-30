# ================================
# Build image (Ubuntu-based with Swift)
# ================================
FROM swift:6.0-noble AS build

# Install dependencies
RUN apt-get update -q && apt-get upgrade -y -q \
 && apt-get install -y -q libjemalloc-dev jq

WORKDIR /build

# Copy Swift package manifests and resolve dependencies
COPY ./Package.* ./
RUN swift package resolve \
    $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

# Copy rest of source code
COPY . .

# Build optimized binary with jemalloc and static stdlib
RUN swift build -c release \
    --product backend \
    --static-swift-stdlib \
    -Xlinker -ljemalloc

# Prepare staging area
WORKDIR /staging

# Copy main executable
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/backend" ./backend

# Copy any SPM-generated resource bundles
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

# Copy optional Public and Resources directories
RUN [ -d /build/Public ] && { cp -r /build/Public ./ && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { cp -r /build/Resources ./ && chmod -R a-w ./Resources; } || true

# Extract Swift runtime dynamic libraries needed at runtime
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

# Install runtime dependencies
RUN apk add --no-cache \
    libgcc \
    libstdc++ \
    jemalloc \
    ca-certificates \
    icu-libs \
    tzdata \
    curl

# Create non-root user
RUN adduser -S -D -H -h /app vapor

WORKDIR /app

# Copy app binary and libs from builder
COPY --from=build --chown=vapor:vapor /staging /app

# Set Swift runtime environment
ENV SWIFT_BACKTRACE=enable=no,sanitize=yes,threads=all,images=all,interactive=no
ENV LD_LIBRARY_PATH=/app/swift-lib

USER vapor:vapor

EXPOSE 8080

ENTRYPOINT ["./backend"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
