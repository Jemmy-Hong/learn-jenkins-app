FROM mcr.microsoft.com/playwright:v1.39.0-jammy
RUN npm config set registry https://registry.npmmirror.com && npm install -g netlify-cli@17.36.1 serve wait-on
RUN apt update && apt install jq -y
