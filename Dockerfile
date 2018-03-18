### BUILD ###

FROM ubuntu:16.04 as builder

# Download miner
ADD https://github.com/JayDDee/cpuminer-opt/archive/v3.8.4.tar.gz /src.tar.gz

# Install build components
RUN apt-get update && \
    apt-get install -y build-essential libssl-dev libgmp-dev libcurl4-openssl-dev libjansson-dev automake unzip && \
    rm -rf /var/lib/apt/lists/* && \
# Build cpu miner
  mkdir -p /cpuminer-opt && \
  tar -xzf /src.tar.gz -C /cpuminer-opt --strip-components=1 && \
	rm src.tar.gz && \
	cd /cpuminer-opt && \
	./build.sh


### APP ###

FROM ubuntu:16.04

COPY --from=builder /cpuminer-opt/cpuminer .

COPY configureAndMine.sh .

RUN apt-get update && \
    apt-get install -y libcurl3 libjansson4 python3 python3-numpy && \
	rm -rf /var/lib/apt/lists/* && \
	chmod +x configureAndMine.sh

COPY cpuminer_driver.py .
COPY benchmark.py .
COPY algorithms.txt .

ARG WALLET=368tX1o9zRjtyetvSsXg4fekE86PQjP2QD
ENV WALLET $WALLET

ENTRYPOINT /configureAndMine.sh
