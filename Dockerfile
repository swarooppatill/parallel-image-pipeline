FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    imagemagick \
    parallel \
    bc \
    procps \
    findutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy files
COPY pipeline.sh /app/pipeline.sh
RUN chmod +x /app/pipeline.sh

ENTRYPOINT ["/app/pipeline.sh"]
CMD ["parallel"]
