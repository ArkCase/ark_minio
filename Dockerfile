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
ARG VER="20250907161309.0.0"
ARG MINIO_VER="${VER}"
ARG MINIO_RPM_VER="${MINIO_VER}-1"
ARG MC_VER="20250813083541.0.0"
ARG MC_RPM_VER="${MC_VER}-1"
ARG MINIO_SRC="https://dl.min.io/server/minio/release/linux-amd64/archive/minio-${MINIO_RPM_VER}.x86_64.rpm"
ARG MC_SRC="https://dl.min.io/client/mc/release/linux-amd64/archive/mcli-${MC_RPM_VER}.x86_64.rpm"
ARG APP_USER="minio"
ARG APP_UID="33000"
ARG APP_GROUP="${APP_USER}"
ARG APP_GID="1000"

ARG BASE_REGISTRY="${PUBLIC_REGISTRY}"
ARG BASE_REPO="arkcase/base"
ARG BASE_VER="8"
ARG BASE_VER_PFX=""
ARG BASE_IMG="${BASE_REGISTRY}/${BASE_REPO}:${BASE_VER_PFX}${BASE_VER}"

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

ENV PATH="/usr/local/bin:${PATH}"

RUN yum -y install \
        sudo \
        "${MINIO_SRC}" \
        "${MC_SRC}" \
    && \
    yum -y clean all && \
    groupadd -g "${APP_GID}" "${APP_GROUP}" && \
    useradd -u "${APP_UID}" -g "${APP_GROUP}" -G "${ACM_GROUP}" "${APP_USER}" && \
    chown -R "${APP_UID}:${APP_GID}" "${HOME}"

COPY --chown=root:root entrypoint /

USER "${APP_USER}"

VOLUME [ "/app/data" ]
ENTRYPOINT [ "/entrypoint" ]
