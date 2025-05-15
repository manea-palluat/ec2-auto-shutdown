FROM hashicorp/terraform:latest

RUN apk add --no-cache bash python3 py3-pip dos2unix

WORKDIR /app
COPY . /app

#convert to LF + make executable
#this is needed because the script is created on Windows and copied to Linux
#I had issues with the script not being executable
#and realized that the script was created on Windows
#and the line endings are not compatible (CRLF vs LF)
#dos2unix is used to convert the line endings

RUN dos2unix /app/docker-entrypoint.sh \
 && chmod +x /app/docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]
