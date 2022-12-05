FROM node:14-alpine3.14 as docs

# Install Python
ENV PYTHONUNBUFFERED=1
RUN apk update
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

WORKDIR /usr/src/app
RUN npm init -y && \
    yarn add -D @redocly/openapi-cli ts-node typedoc typedoc-plugin-markdown typescript && \
    pip install mkdocs && \
    pip install mkdocs-render-swagger-plugin && \
    pip install mkdocs-awesome-pages-plugin && \
    pip install mkdocs-monorepo-plugin && \
    pip install mkdocs-macros-plugin && \
    pip install mkdocs-material

COPY docs/ docs/
COPY README.md docs/
COPY .redocly.yaml ./
     
RUN npx openapi bundle --ext json -o ./docs/example-api

COPY mkdocs.yml ./
RUN mkdocs build

# web server 
FROM nginx:alpine as mkdocs
COPY --from=docs /usr/src/app/site/ /usr/share/nginx/html
EXPOSE 80
