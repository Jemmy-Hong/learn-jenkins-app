# noble = ubuntu24.04，自带 Node 20，满足 netlify‑cli 要求 >=20
FROM mcr.microsoft.com/playwright:v1.39.0-noble

# 这里保留你必须要的全局安装，不再报错 with 语法
RUN npm install -g netlify-cli node-jq
