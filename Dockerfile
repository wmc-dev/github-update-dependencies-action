FROM node:12
COPY update.sh /update.sh
COPY updateNPMPacakges.sh /updateNPMPacakges.sh
COPY updateSubmodules.sh /updateSubmodules.sh
ENTRYPOINT ["/update.sh"]