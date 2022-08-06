FROM debian:stretch-slim AS builder

ARG fr24_url=https://repo-feed.flightradar24.com/rpi_binaries/fr24feed_1.0.29-10_armhf.tgz

# Build dump1090, get some necessary packages and download fr24feed
RUN apt-get update \
    && apt-get install -y --no-install-recommends pkg-config dnsutils curl ca-certificates rtl-sdr git make gcc libc6-dev librtlsdr-dev \
    && cd /tmp \
    && git clone https://github.com/MalcolmRobb/dump1090.git \
    && cd dump1090 \
    && make \
    && mkdir /tmp/fr24 \
    && curl "${fr24_url}" -o /tmp/fr24feed.tgz \
    && tar xzf /tmp/fr24feed.tgz --strip 1 -C /tmp/fr24

# Todo: will Alpine work? It didn't on my first try but it may just be missing packages
FROM debian:stretch-slim AS runner

RUN apt-get update \
    && apt-get install -y --no-install-recommends rtl-sdr \
    && apt-get clean

# Copy the necessary files to the final container
COPY fr24feed.ini /etc/
COPY --from=builder /tmp/dump1090/dump1090 /usr/lib/fr24/
COPY --from=builder /tmp/fr24 /fr24

ENV FR24_KEY ''

ENTRYPOINT ["/fr24/fr24feed"]