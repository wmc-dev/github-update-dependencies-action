FROM node:12
COPY update.sh /update.sh
ENTRYPOINT ["#!/bin/bash/update.sh"]