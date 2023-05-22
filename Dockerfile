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
ARG VER="RELEASE.2023-05-18T00-05-36Z"
ARG BLD="01"
ARG PKG="minio"
ARG MINIO_SRC=""
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
    && \
    yum -y clean all && \
    groupadd -g "${APP_GID}" "${APP_GROUP}" && \
    useradd -u "${APP_UID}" -g "${APP_GROUP}" "${APP_USER}"

COPY --chown=root:root entrypoint /
COPY --chown=root:root update-ssl /
COPY --chown=root:root 00-update-ssl /etc/sudoers.d/

RUN chmod 0755 /entrypoint && \
    chmod 0640 /etc/sudoers.d/00-update-ssl && \
    sed -i -e "s;\${ACM_GROUP};${APP_GROUP};g" /etc/sudoers.d/00-update-ssl

USER "${APP_USER}"

EXPOSE 9000
VOLUME [ "/app/data" ]
ENTRYPOINT [ "/entrypoint" ]
