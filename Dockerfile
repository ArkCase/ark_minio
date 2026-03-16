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

ARG FIPS=""
ARG PUBLIC_REGISTRY="public.ecr.aws"
ARG ARCH="amd64"
ARG OS="linux"
ARG VER="20251015.172955"

ARG REG="cgr.dev"
ARG MINIO_REPO="armedia.com/minio-fips"
ARG MINIO_VER="v0.${VER}"
ARG MINIO_IMG="${REG}/${MINIO_REPO}:${MINIO_VER}"

ARG APP_USER="minio"
ARG APP_UID="33000"
ARG APP_GROUP="${APP_USER}"
ARG APP_GID="1000"

ARG BASE_REGISTRY="${PUBLIC_REGISTRY}"
ARG BASE_REPO="arkcase/base"
ARG BASE_VER="24.04"
ARG BASE_VER_PFX=""
ARG BASE_IMG="${BASE_REGISTRY}/${BASE_REPO}${FIPS}:${BASE_VER_PFX}${BASE_VER}"

FROM "${MINIO_IMG}" AS minio-src

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

COPY --chown=root:root --chmod=0755 --from=minio-src /usr/bin/minio /usr/local/bin/
COPY --chown=root:root --chmod=0755 --from=minio-src /usr/bin/mc /usr/local/bin/mcli
RUN groupadd -g "${APP_GID}" "${APP_GROUP}" && \
    useradd -u "${APP_UID}" -g "${APP_GROUP}" -G "${ACM_GROUP}" -d "${HOME}" "${APP_USER}" && \
    chown -R "${APP_UID}:${APP_GID}" "${HOME}" && \
    chmod -R g-w,o-rwx "${HOME}"

COPY --chown=root:root --chmod=0755 entrypoint /

USER "${APP_USER}"

VOLUME [ "/app/data" ]
ENTRYPOINT [ "/entrypoint" ]
