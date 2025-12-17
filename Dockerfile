###########################################################################################################
#
# How to build:
#
# docker build -t arkcase/minio:.... .
#
# How to run: (Docker)
# docker compose -f docker-compose.yml up -d
#
#
###########################################################################################################

ARG PUBLIC_REGISTRY="public.ecr.aws"
ARG ARCH="amd64"
ARG OS="linux"
ARG VER="20251015172955.0.0"

ARG MINIO_VER="${VER}"
ARG MC_VER="20250813083541.0.0"

ARG GO="1.24"

ARG MINIO_SRC="https://github.com/minio/minio.git"
ARG MC_SRC="https://github.com/minio/mc.git"

ARG BUILDER_IMAGE="golang"
ARG BUILDER_VER="${GO}-alpine"
ARG BUILDER_IMG="${BUILDER_IMAGE}:${BUILDER_VER}"

ARG APP_USER="minio"
ARG APP_UID="33000"
ARG APP_GROUP="${APP_USER}"
ARG APP_GID="1000"

ARG BASE_REGISTRY="${PUBLIC_REGISTRY}"
ARG BASE_REPO="arkcase/base"
ARG BASE_VER="22.04"
ARG BASE_VER_PFX=""
ARG BASE_IMG="${BASE_REGISTRY}/${BASE_REPO}:${BASE_VER_PFX}${BASE_VER}"

FROM "${BUILDER_IMG}" AS builder

ARG GO
ARG MINIO_VER
ARG MINIO_SRC
ARG MC_VER
ARG MC_SRC

RUN apk --no-cache add git bash

ENV GO111MODULE="on"
ENV CGO_ENABLED="0"
ENV GOOS="linux"
ENV GOARCH="amd64"

ENV CRYPTO_FIX="golang.org/x/crypto@v0.45.0"
ENV MQTT_FIX="github.com/eclipse/paho.mqtt.golang@v1.5.1"

COPY --chmod=0755 version-to-date build /
RUN V="RELEASE.$(/version-to-date "${MINIO_VER}")" && \
    /build "${MINIO_SRC}" "${V}" "${CRYPTO_FIX}" "${MQTT_FIX}"
RUN V="RELEASE.$(/version-to-date "${MC_VER}")" && \
    /build "${MC_SRC}" "${V}" "${CRYPTO_FIX}"

ARG BASE_IMG

# Final Image
FROM "${BASE_IMG}"

ARG ARCH
ARG OS
ARG VER
ARG MINIO_SRC
ARG MC_SRC
ARG APP_USER
ARG APP_UID
ARG APP_GROUP
ARG APP_GID

LABEL ORG="ArkCase LLC" \
      MAINTAINER="Armedia Devops Team <devops@armedia.com>" \
      APP="MinIO Server" \
      VERSION="${VER}"

COPY --chown=root:root --chmod=0755 --from=builder /go/bin/minio /usr/local/bin/minio
COPY --chown=root:root --chmod=0755 --from=builder /go/bin/mc /usr/local/bin/mcli
RUN groupadd -g "${APP_GID}" "${APP_GROUP}" && \
    useradd -u "${APP_UID}" -g "${APP_GROUP}" -G "${ACM_GROUP}" -d "${HOME}" "${APP_USER}" && \
    chown -R "${APP_UID}:${APP_GID}" "${HOME}" && \
    chmod -R g-w,o-rwx "${HOME}"

COPY --chown=root:root --chmod=0755 entrypoint /

USER "${APP_USER}"

VOLUME [ "/app/data" ]
ENTRYPOINT [ "/entrypoint" ]
