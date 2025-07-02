FROM golang:1.24.4-alpine AS builder
WORKDIR /app
COPY . .
RUN go get -u github.com/gin-gonic/gin && go build -o server .

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/server .
EXPOSE 8080
CMD ["./server"]