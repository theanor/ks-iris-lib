ARG IMAGE=intersystemsdc/irishealth-community
ARG VERSION=2024.1
ARG VERSION=latest
FROM $IMAGE:$VERSION

USER root

WORKDIR /opt/irisbuild
RUN chown -R ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisbuild

USER ${ISC_PACKAGE_MGRUSER}

COPY src src
COPY module.xml module.xml
COPY iris.script iris.script

RUN <<EOF
iris start IRIS
iris session IRIS < iris.script
iris stop IRIS quietly
EOF
