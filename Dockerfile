FROM node:16.18-alpine
RUN apk update \
  && apk add npm
ADD . /h5/
WORKDIR /h5
RUN npm install

CMD node looplisten_zh.js