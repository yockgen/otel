FROM golang:1.18.3-alpine as builder
WORKDIR /src
COPY go.mod .
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o ./main .
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /src/main .
EXPOSE 5000
CMD ["./main"]
