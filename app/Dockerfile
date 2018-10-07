FROM node:8.6

COPY ./core /app

WORKDIR app

RUN npm install --quiet

ENTRYPOINT [ "npm", "start" ]
