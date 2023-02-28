ARG ARCH=
ARG SOURCE_BRANCH=
FROM mattiasegly/base-image:${SOURCE_BRANCH}-${ARCH} AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	libxml2-dev \
	libxslt1-dev \
	libffi-dev \
	libssl-dev \
	python3-dev \
	cargo \
	git \
	pipx \
&& rm -rf /var/lib/apt/lists/*
#packages needed to compile on arm

RUN groupadd taky && \
	useradd -mg taky taky

USER taky
WORKDIR /home/taky
ENV PATH="$PATH:/home/taky/.local/bin"

RUN mkdir -p uploads/meta clients logs && \
	pipx install git+https://github.com/tkuester/taky@next

FROM mattiasegly/base-image:${SOURCE_BRANCH}-${ARCH}

RUN apt-get update && apt-get install -y --no-install-recommends \
	libxml2 \
	libxslt1.1 \
	libffi8 \
	libssl3 \
	pipx \
&& rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN groupadd taky && \
	useradd -mg taky taky

USER taky
WORKDIR /home/taky
ENV PATH="$PATH:/home/taky/.local/bin"

COPY --from=builder /home/taky /home/taky

VOLUME /home/taky
EXPOSE 8088 8089 8443

ENTRYPOINT ["entrypoint.sh"]
CMD ["echo", "Specify", "Command"]
