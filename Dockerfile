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
ARG BASE_REPO="arkcase/base"
ARG BASE_TAG="8.7.0"
ARG ARCH="amd64"
ARG OS="linux"
ARG VER="20230602231726.0.0"
ARG MINIO_VER="${VER}"
ARG MC_VER="20230530224138.0.0"
ARG BLD="02"
ARG PKG="minio"
ARG MINIO_SRC="https://dl.min.io/server/minio/release/linux-amd64/minio-${MINIO_VER}.x86_64.rpm"
ARG MC_SRC="https://dl.min.io/client/mc/release/linux-amd64/mcli-${MC_VER}.x86_64.rpm"
ARG APP_USER="minio"
ARG APP_UID="33000"
ARG APP_GROUP="${APP_USER}"
ARG APP_GID="1000"

# Final Image
FROM "${PUBLIC_REGISTRY}/${BASE_REPO}:${BASE_TAG}"

ARG ARCH
ARG OS
ARG VER
ARG PKG
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

RUN yum -y update && \
    yum -y install \
        sudo \
        "${MINIO_SRC}" \
        "${MC_SRC}" \
    && \
    yum -y clean all && \
    groupadd -g "${APP_GID}" "${APP_GROUP}" && \
    useradd -u "${APP_UID}" -g "${APP_GROUP}" "${APP_USER}" && \
    chown -R "${APP_UID}:${APP_GID}" "${HOME}"

COPY --chown=root:root entrypoint /
COPY --chown=root:root update-ssl /
COPY --chown=root:root 00-update-ssl /etc/sudoers.d/

RUN chmod 0755 /entrypoint && \
    chmod 0640 /etc/sudoers.d/00-update-ssl && \
    sed -i -e "s;\${ACM_GROUP};${APP_GROUP};g" /etc/sudoers.d/00-update-ssl

USER "${APP_USER}"

VOLUME [ "/app/data" ]
ENTRYPOINT [ "/entrypoint" ]
