# Use the official Vault image from the Docker Hub
# Use the official Alpine base image
FROM alpine:latest

# Set environment variables
ENV VAULT_VERSION=1.14.10
ENV VAULT_ADDR=http://127.0.0.1:8200

# Install necessary packages
RUN apk add --no-cache \
    ca-certificates \
    wget \
    unzip \
    bash \
    jq \
    curl \
    openssl

# Download and install Vault
RUN wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
    && unzip vault_${VAULT_VERSION}_linux_amd64.zip \
    && mv vault /usr/local/bin/ \
    && rm vault_${VAULT_VERSION}_linux_amd64.zip
#FROM hashicorp/vault:1.14.10
#
# The Vault data directory will be mapped to this location.
#VOLUME /vault/data
##
### The Vault config directory will be mapped to this location.
###VOLUME /vault/config
##
## The Vault log directory will be mapped to this location.
#VOLUME /vault/logs
#
## The Vault init directory will be mapped to this location
#VOLUME /vault/init


# Create directories for configuration and initialization scripts
RUN mkdir -p /vault/init /vault/config /vault/data /vault/logs

# Copy configuration files into the container
COPY config /vault/config
#COPY init /vault/init


# Copy entrypoint script into the container
#COPY entrypoint.sh /vault/init/entrypoint.sh
#RUN chmod +x /vault/init/entrypoint.sh

# Set environment variables
ENV VAULT_ADDR=http://127.0.0.1:8200

# Expose the Vault port
EXPOSE 8200 8201

# Run entrypoint script
ENTRYPOINT ["/vault/init/entrypoint.sh"]

## Entry point to run Vault server
#ENTRYPOINT ["vault"]
#
## Command to run Vault server in development mode (change accordingly for production)
#CMD ["server", "-config=/vault/config/vault.hcl"]