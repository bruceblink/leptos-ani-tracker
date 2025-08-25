# 阶段1：使用 cargo-chef 缓存依赖
FROM rust:1 AS chef
# 安装 cargo-chef 用于生成和使用依赖缓存方案
RUN cargo install cargo-chef
WORKDIR /app

# 阶段2：生成依赖缓存清单（recipe）
FROM chef AS planner
# 将项目源代码拷贝到构建环境
COPY . ./
# 生成依赖清单 recipe.json，以便后续层能复用依赖缓存
RUN cargo chef prepare --recipe-path recipe.json

# 阶段3：构建 leptos-app、前端静态资源与后端可执行文件
FROM chef AS builder

# 恢复并构建缓存的 Rust 依赖，加速后续构建
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

# 安装 cargo-leptos，避免使用不存在的安装脚本 URL
RUN cargo install cargo-binstall && cargo binstall cargo-leptos -y

# 添加 WASM 编译支持
RUN rustup target add wasm32-unknown-unknown

# 安装依赖工具
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends clang pkg-config libssl-dev

# 拷贝源码
WORKDIR /app
COPY . .

# 构建 release
RUN cargo leptos build --release -vv

# 阶段4：运行应用
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