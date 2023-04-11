ARG ARCH=
ARG SOURCE_BRANCH=
FROM mattiasegly/base-image:${SOURCE_BRANCH}-${ARCH} AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	python3-dev \
	libxml2-dev \
	libxslt1-dev \
	libffi-dev \
	libssl-dev \
	cargo \
	git \
	pipx \
	pkg-config \
&& rm -rf /var/lib/apt/lists/*
#packages needed to build on arm

RUN groupadd taky && \
	useradd -mg taky taky

USER taky
WORKDIR /home/taky
ENV PATH="$PATH:/home/taky/.local/bin"

RUN pipx install git+https://github.com/tkuester/taky@next --system-site-packages --verbose
#access needed to find build requirements

FROM mattiasegly/base-image:${SOURCE_BRANCH}-${ARCH}

RUN apt-get update && apt-get install -y --no-install-recommends \
	libxml2 \
	libxslt1.1 \
	libffi8 \
	libssl3 \
	pipx \
&& rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin
COPY start.sh /usr/local/bin

RUN chmod +x /usr/local/bin/entrypoint.sh && \
	chmod +x /usr/local/bin/start.sh && \
	groupadd taky && \
	useradd -mg taky taky && \
	mkdir /taky && \
	chown taky:taky /taky

USER taky
WORKDIR /taky
ENV PATH="$PATH:/home/taky/.local/bin"

COPY --from=builder /home/taky /home/taky

VOLUME /taky
EXPOSE 8088 8089 8443
#monport, sslport, dpsport

ENTRYPOINT ["entrypoint.sh"]
CMD ["start.sh"]
