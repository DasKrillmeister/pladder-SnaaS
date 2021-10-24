FROM mcr.microsoft.com/powershell

RUN pwsh -c 'Install-Module Pode -force'

EXPOSE 8080
CMD [ "pwsh", "-c", "cd /usr/src/app; ./pladder-snaas.ps1" ]

COPY pladder-snaas.ps1 versio? /usr/src/app/
