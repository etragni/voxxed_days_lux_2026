FROM golang:1.22-alpine AS build
WORKDIR /app
COPY main.go .
RUN go mod init demo-app && go build -o server .

FROM golang:1.22-alpine
COPY --from=build /app/server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
