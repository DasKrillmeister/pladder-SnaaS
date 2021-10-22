# pladder-SnaaS

Your very own proxy service for https://github.com/raek/pladder


# Local development

## Docker

Edit docker-compose.yml to taste (or create a docker-compose.override.yml)

run with:

docker-compose build

docker-compose up

connect to localhost:8080

## Powershell

Use powershell 7 and run Install-Module Pode

Set $env:uri and $env:token and run the script with ./pladder-snaas.ps1

connect to localhost:8080


----------------------------

# Build & Deploy

## Staging

The main branch is automatically built and deployed via Azure Devops to a staging environment.

Status:
[![Build Status](https://dev.azure.com/krillmeister/pladder-SnaaS/_apis/build/status/DasKrillmeister.pladder-SnaaS?branchName=main)](https://dev.azure.com/krillmeister/pladder-SnaaS/_build/latest?definitionId=1&branchName=main)

Staging can be accessed here:
https://snaas-staging.ext.krillmeister.se/


## Prod

Run the github action to deploy to prod
