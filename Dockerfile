# syntax=docker/dockerfile:1
# vfeeg-postfix mailgateway EEG Faktura
# Copyright (C) 2023  VFEEG
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

FROM ghcr.io/vfeeg-development/vfeeg-postfix
LABEL org.vfeeg.vendor="Verein zur Förderung von Erneuerbaren Energiegemeinschaften"
LABEL org.vfeeg.image.authors="eegfaktura@vfeeg.org"
LABEL org.opencontainers.image.vendor="Verein zur Förderung von Erneuerbaren Energiegemeinschaften"
LABEL org.opencontainers.image.authors="eegfaktura@vfeeg.org"
LABEL org.opencontainers.image.title="eegfaktura-postfix"
LABEL org.opencontainers.image.version="0.1.0"
LABEL org.opencontainers.image.description="EEG Faktura mailgateway"
LABEL org.opencontainers.image.licenses=AGPL-3.0
LABEL org.opencontainers.image.source=https://github.com/eegfaktura/eegfaktura-postfix
LABEL org.opencontainers.image.base.name=ghcr.io/vfeeg-development/vfeeg-postfix
LABEL description="EEG Faktura mailgateway "
LABEL version="0.1.0"

ENV POSTFIX_RELAY_HOST=""
ENV POSTFIX_RELAY_PORT=""
ENV POSTFIX_RELAY_TLS=""
ENV POSTFIX_RELAY_USER=""
ENV POSTFIX_RELAY_PASSWORD=""
ENV POSTFIX_RELAY_PASSWORD_FILE=""
ENV POSTFIX_RELAY_EMAIL=""
ENV POSTFIX_HOSTNAME=""
ENV POSTFIX_MYDOMAIN=""
ENV POSTFIX_MYNETWORK=""
ENV POSTFIX_DNS_1="9.9.9.9"
ENV POSTFIX_DNS_2=""

FROM debian:bookworm
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y postfix bsd-mailx

COPY entrypoint.sh /

EXPOSE 25
CMD ["/entrypoint.sh"]