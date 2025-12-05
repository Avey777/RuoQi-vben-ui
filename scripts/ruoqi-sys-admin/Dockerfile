FROM node:22-slim AS builder

# --max-old-space-size
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV NODE_OPTIONS=--max-old-space-size=8192
ENV TZ=Asia/Shanghai

RUN npm i -g corepack

WORKDIR /app

# copy package.json and pnpm-lock.yaml to workspace
COPY . /app

# 安装依赖
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
# 构建指定的 ruoqi-sys-admin 项目
RUN pnpm run build --filter=./apps/ruoqi-sys-admin

RUN echo "ruoqi-sys-admin 构建成功 🎉"

FROM nginx:stable-alpine AS production

# 配置 nginx
RUN echo "types { application/javascript js mjs; }" > /etc/nginx/conf.d/mjs.conf \
  && rm -rf /etc/nginx/conf.d/default.conf

# 复制 ruoqi-sys-admin 的构建产物
COPY --from=builder /app/apps/ruoqi-sys-admin/dist /usr/share/nginx/html

# 复制 nginx 配置 (从当前目录复制)
COPY scripts/ruoqi-sys-admin/nginx.conf /etc/nginx/nginx.conf

EXPOSE 8081

# 启动 nginx
CMD ["nginx", "-g", "daemon off;"]
