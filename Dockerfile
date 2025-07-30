# ================================
# Build image (Ubuntu + Swift)
# ================================
FROM swift:6.0-noble AS build

# 安装依赖
RUN apt-get update -q && apt-get upgrade -y -q \
 && apt-get install -y -q libjemalloc-dev jq file

WORKDIR /build

# 拉取依赖
COPY ./Package.* ./
RUN swift package resolve \
    $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

# 拷贝全部代码并构建
COPY . ./

RUN swift build -c release \
    --product backend \
    --static-swift-stdlib \
    -Xlinker -ljemalloc

# 检查产物是否存在且平台正确
RUN BIN_PATH="$(swift build -c release --show-bin-path)/backend" && \
    file "$BIN_PATH" && \
    cp "$BIN_PATH" /usr/local/bin/backend && \
    strip /usr/local/bin/backend

# 收集资源
RUN mkdir -p /staging && cd /staging && \
    cp /usr/local/bin/backend ./ && \
    find -L "$(swift build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \; && \
    [ -d /build/Public ] && { cp -r /build/Public ./ && chmod -R a-w ./Public; } || true && \
    [ -d /build/Resources ] && { cp -r /build/Resources ./ && chmod -R a-w ./Resources; } || true

# 收集动态库
RUN mkdir -p /staging/swift-lib && \
    swift -print-target-info | jq -r '.paths.runtimeLibraryPaths[]' \
    | xargs -I {} find {} -type f -name '*.so' \
    | grep -E '(libswiftCore|libFoundation|libdispatch|libicu|libBlocksRuntime|libswift_|libicuuc|libicudata|libicui18n)' \
    | xargs -I {} cp -v {} /staging/swift-lib/ && \
    cp -v /usr/lib/x86_64-linux-gnu/libjemalloc.so.* /staging/swift-lib/ || true

# ================================
# Runtime image (Ubuntu-based)
# ================================
FROM swift:6.0-noble-slim

# 安装运行时依赖
RUN apt-get update -q && apt-get install -y -q \
    libjemalloc2 \
    ca-certificates \
    libicu72 \
    tzdata \
    curl && \
    rm -rf /var/lib/apt/lists/*

# 创建用户
RUN addgroup --system vapor && adduser --system --ingroup vapor vapor

WORKDIR /app

# 拷贝构建产物
COPY --from=build /staging /app
RUN chown -R vapor:vapor /app

# 设置环境变量
ENV SWIFT_BACKTRACE=enable=no,sanitize=yes,threads=all,images=all,interactive=no
ENV LD_LIBRARY_PATH=/app/swift-lib

USER vapor

EXPOSE 8080

# 使用 exec 启动，避免 shell 替换问题
ENTRYPOINT ["/app/backend"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
