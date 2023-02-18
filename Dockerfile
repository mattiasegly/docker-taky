ARG ARCH=
ARG SOURCE_BRANCH=
FROM mattiasegly/base-image:${SOURCE_BRANCH}-${ARCH}

COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN apt-get update && apt-get install -y --no-install-recommends \
	git \
	python3 \
	python3-pip \
	python3-lxml \
	python3-cryptography \
&& rm -rf /var/lib/apt/lists/*
#problem compiling some python packages prom pypi on arm

RUN pip3 install --upgrade pip && \
	groupadd taky && \
	useradd -mg taky taky

USER taky
WORKDIR /home/taky
ENV PATH="$PATH:/home/taky/.local/bin"

RUN mkdir -p uploads/meta clients logs && \
	pip3 install --user git+https://github.com/tkuester/taky@next

VOLUME /home/taky
EXPOSE 8088 8089 8443

ENTRYPOINT ["entrypoint.sh"]
CMD ["echo", "CommandMissing"]
