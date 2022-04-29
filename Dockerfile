FROM --platform=linux/arm64/v8 python:3.8-slim-buster AS compile-image

RUN python -m venv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --upgrade pip

WORKDIR /app

# Copy the source code.
COPY squeaknode .

RUN pip install .

FROM --platform=linux/arm64/v8 python:3.8-slim-buster

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
	apt-get install -y \
	iproute2 wget curl tini

RUN wget https://github.com/mikefarah/yq/releases/download/v4.12.2/yq_linux_arm.tar.gz -O - |\
    tar xz && mv yq_linux_arm /usr/bin/yq

COPY --from=compile-image /opt/venv /opt/venv

EXPOSE 8555
EXPOSE 18555
EXPOSE 12994

ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh
ADD assets/utils/health-check.sh /usr/local/bin/health-check.sh
RUN chmod +x /usr/local/bin/health-check.sh

# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
