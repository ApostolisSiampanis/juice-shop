# Minimal Debian with Nmap installed
FROM debian:bookworm-slim

# Install nmap and CA roots (use --no-install-recommends to keep image small)
RUN apt-get update \
 && apt-get install -y --no-install-recommends nmap ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Create an unprivileged user; -sT (TCP connect) scans do not need raw-socket caps
RUN useradd -m -u 10001 nmapper
USER nmapper

# Working directory inside the container (not strictly required)
WORKDIR /scan

# Make the container behave like "nmap" by default
ENTRYPOINT ["nmap"]
# Show help by default if no args provided
CMD ["-h"]