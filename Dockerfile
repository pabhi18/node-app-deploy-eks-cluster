From node:18 AS builder

WORKDIR /build

COPY package.*json .

RUN npm install

COPY . .

RUN npm run 

FROM node:18-alpine AS runner

WORKDIR /app

COPY --from=builder /build/package*.json ./
COPY --from=builder /build /app

RUN npm install --only=prod

EXPOSE 3000

CMD ["npm", "start"]