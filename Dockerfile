FROM node:erbium-alpine as build

RUN npm install -g node-prune
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./
RUN npm install --only-production

# Use everything escept ignored files
COPY . .

# Create build, remove all not needed files and place all required files in build directory
RUN npm run build \
    && npm prune --production \
    && ash /usr/local/bin/node-prune \
    && mkdir build \
    && cp -r node_modules/ dist/ build

FROM node:erbium-alpine

WORKDIR /usr/src/app
COPY --from=build /usr/src/app/build .
USER node
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["node", "dist/main"]