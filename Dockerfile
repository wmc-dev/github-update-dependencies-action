FROM node:lts
COPY update.sh /update.sh
ENTRYPOINT ["/update.sh"]
