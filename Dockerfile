FROM node:10-slim as node

WORKDIR /usr/app

# install a specific NPM version
RUN npm install -g npm@6.9.0

COPY package*.json ./

RUN npm ci

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
