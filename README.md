[![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/ks-iris-lib)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&logo=AdGuard)](LICENSE)

## Description

This repository contains a set of utility classes :

* ks.lib.hl7 : HL7 utility classes
* ks.lib.interop : interoperability utility classes
* ks.lib.json : JSON utility classes
* ks.lib.object : objects utility classes
* ks.lib.record : (yet another?) simple record mapper
* ks.lib.test : unit testing utility classes
* ks.lib.xml : XML utility classes
* ks.lib.purge : interoperability message purge utilities

[![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%3Aks-iris-lib&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%3Aks-iris-lib)


## Usage
Once you clone the new repo to your laptop and open VSCode (with the [InterSystems ObjectScript Extension Pack](https://marketplace.visualstudio.com/items?itemName=intersystems-community.objectscript-pack) installed) you'll be able to start development immediately.

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation
Clone/git pull the repo into any local directory

```
$ git clone https://github.com/theanor/iris-lib.git
```

Open the terminal in this directory and call the command to build and run InterSystems IRIS in container:
*Note: Users running containers on a Linux CLI, should use "docker compose" instead of "docker-compose"*
*See [Install the Compose plugin](https://docs.docker.com/compose/install/linux/)*

```
$ docker-compose up -d
```

To open IRIS Terminal do:

```
$ docker-compose exec iris iris session iris -U IRISAPP
IRISAPP>
```

To exit the terminal, do any of the following:

```
Enter HALT or H (not case-sensitive)
```

## How to start the development

This repository is ready to code in VSCode with the ObjectScript plugin.

Install [VSCode](https://code.visualstudio.com/), [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) and the [InterSystems ObjectScript Extension Pack](https://marketplace.visualstudio.com/items?itemName=intersystems-community.objectscript-pack) plugin and open the folder in VSCode.

Open the `/src/cls/PackageSample/ObjectScript.cls` class and make changes - it will be compiled in the running IRIS docker container.

![docker_compose](https://user-images.githubusercontent.com/2781759/76656929-0f2e5700-6547-11ea-9cc9-486a5641c51d.gif)

Feel free to delete the PackageSample folder and place your ObjectScript classes in the form
`/src/organisation/package/Classname.cls`

[Read more about folder setup for InterSystems ObjectScript](https://community.intersystems.com/post/simplified-objectscript-source-folder-structure-package-manager) and here on the [naming convention](https://community.intersystems.com/post/naming-convention-objectscript-packages-classes-and-package-manager-modules-names)

## Running unit tests

To run test, use VSCode test harness or zpm :

```
USER> zpm "ks-lib test -v"
```

## What else is inside the repository

### .github folder

Contains two GitHub actions workflows:
1. `github-registry.yml`
    Once changes pushed to the repo, the action builds the docker image on Github side and pushes the image to Github registry that can be very convenient to further cloud deployement, e.g. kubernetes.
2. `objectscript-qaulity.yml`
    with every push to master or main branch the workflow launches the repo test on objectscript issues with Objectscript Quality tool, [see the examples](https://community.objectscriptquality.com/projects?sort=-analysis_date). This works if the repo is open-source only.

Both workflows are repo agnostic: so they work with any repository where they exist.

### .vscode folder
Contains two files to setup vscode environment:

#### .vscode/settings.json

Settings file to let you immediately code in VSCode with [VSCode ObjectScript plugin](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript))

#### .vscode/launch.json

Config file if you want to debug with VSCode ObjectScript

### src folder

Contains source files.
src/iris contains InterSystems IRIS Objectscript code

### test folder
Contains unit tests for the ObjectScript classes

### docker-compose.yml

A docker engine helper file to manage images building and rule ports mapping an the host to container folders(volumes) mapping

### Dockerfile

The simplest dockerfile which starts IRIS and imports code from /src folder into it.
Use the related docker-compose.yml to easily setup additional parametes like port number and where you map keys and host folders.


### iris.script

Contains objectscript commands that are feeded to iris during the image building

### module.xml

IPM Module's description of the code in the repository.
It describes what is loaded with the method, how it is being tested and what apps neeed to be created, what files need to be copied.

[Read about all the files in this artilce](https://community.intersystems.com/post/dockerfile-and-friends-or-how-run-and-collaborate-objectscript-projects-intersystems-iris)

## Troubleshooting

If you have issues with docker image building here are some recipes that could help.

1. You are out of free space in docker. You can expand the amount of space or clean up maually via docker desktop. Or you can call the following line to clean up:
```
docker system prune -f
```

2. We use multi-stage image building which in some cases doesn't work. Switch the target to [builder](https://github.com/intersystems-community/intersystems-iris-dev-template/blob/6ab6791983e5783118efce1777a7671046652e4c/docker-compose.yml#L7) from final in the docker compose and try again.

