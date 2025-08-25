# ---- 构建阶段 ----
FROM rust:1.88-bookworm AS builder
# 如果你要 nightly，可以改成： rustlang/rust:nightly-bookworm

# 安装 cargo-binstall，用于安装 cargo-leptos
RUN wget https://github.com/cargo-bins/cargo-binstall/releases/latest/download/cargo-binstall-x86_64-unknown-linux-musl.tgz \
    && tar -xvf cargo-binstall-x86_64-unknown-linux-musl.tgz \
    && cp cargo-binstall /usr/local/cargo/bin

# 安装依赖工具
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends clang pkg-config libssl-dev

# 安装 cargo-leptos
RUN cargo binstall cargo-leptos -y

# 添加 WASM 目标
RUN rustup target add wasm32-unknown-unknown

# 拷贝源码
WORKDIR /app
COPY . .

# 构建 release
RUN cargo leptos build --release -vv

# ---- 运行阶段 ----
FROM debian:bookworm-slim AS runtime
WORKDIR /app

# 安装运行依赖
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends openssl ca-certificates \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

# 拷贝编译好的二进制
COPY --from=builder /app/target/release/leptos-ani /app/

# 拷贝静态资源
COPY --from=builder /app/target/site /app/site

# 拷贝 Cargo.toml（如果运行时用到）
COPY --from=builder /app/Cargo.toml /app/

# 环境变量（你也可以在 docker run 时覆盖）
ENV RUST_LOG="info"
ENV LEPTOS_SITE_ADDR="0.0.0.0:8001"
ENV LEPTOS_SITE_ROOT="site"

# 暴露端口（跟上面的 LEPTOS_SITE_ADDR 一致）
EXPOSE 8001

# 启动命令
CMD ["/app/leptos-ani"]