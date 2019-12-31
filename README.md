# Dockerize :whale:

Scaffolding for Dockerized Development Environment

# What is this?

This is a sample repo that uses Docker to automate dev setup and create consistency in deployed environments.

# :mag: The Problem

How do I setup a dev environment for Project X?

```
I think John knows... is he still around?

We used to have a shell script

The README is outdated/empty

You need two versions of Java/Ruby/Python

Project A conflicts with Project B

What is Nokogiri and why won't it compile?!
```

# :rocket: The Dream

```sh
git clone YOUR-REPO-HERE
cd YOUR-REPO-HERE

# one line install to "dockerize" this repo
curl -sL https://.../install.sh | bash

# start using your dockerized app
./dev start
```

:boom::ok_hand: Enjoy a cup of coffee!

# :whale: End Result

* Runs in a sandboxed environment (docker)
* I can use my own IDE
* Same versions of software as everyone else
* Same software as production

# Developer Getting Started

This application is built using Docker, which creates a Production equivalent environment on your system. It will mount the git repo app directory into the docker container so you can still work on your native OS but run the app in a sandbox.

### Installation

Simple one-liner shell script that installs the developer toolkit:

```sh
curl -sL https://raw.githubusercontent.com/asanchezr/dockerize/master/install.sh | bash
```

OR, create `install-dev` as an alias!

```bash
alias install-dev="curl -sL https://raw.githubusercontent.com/asanchezr/dockerize/master/install.sh | bash"
```

### Docker-Dev Manages Docker, Not Your App!

* Simple `bash` scripts!
* Idempotent software install
* Your App is configured in a **Dockerfile**
* Port, name, etc, configured in `dev.config`
* Automates solutions

### Simple Commands

```sh
./dev init
./dev restart
./dev shell
./dev start
./dev stop
./dev test
```

### Start and stop the live running app

If for some reason you need to stop/start the app, you can do so like this:

```sh
./dev stop
./dev start
./dev restart
```

### Testing Your Docker Image / App

You can run `dev test` to test either the running instance or to run and test a new instance. Before running `dev test`, you should update `test.sh` (at the bottom) to add a test runner execution command.

```sh
./dev test
```

### Debugging The Environment Internally

```sh
./dev shell
```

# Using This Repo as a Bootstrap

This project is made up of several files, which you can port into your own application to dockerize your developer environment:

## .dockerignore

This file simply tells docker to ignore files and directories in the docker build process.

Chances are, you don't need things like `build_scripts`, `app/test`, `docs`, etc in the docker build.

Adding more to this file will speed up your docker build time since docker has to send all the files in this directory to the docker engine in order to create the machine. It will omit anything specified in `.dockerignore`

## .env

This file is a runtime ENV declaration. Keep in mind that secrets must be set on the actual system ENV, which ops will use to pass into docker. Everything else can go in here. Your app will use these settings on your dev machine.

## dev

The `dev` script is the main developer toolkit script. You can copy this file without modification.

## dev.config

These are the specific configs for your app/environment, which the `dev` script will use to run your app apart from others:

```sh
#!/usr/bin/env bash
# The repo name for your github project/repo
export APP_NAME="my-dockerized-app"
# the port to run your app on (change this to something random that won't bump into another app)
export APP_PORT_EXTERNAL=4103
# the port your app listens on within the container (will not conflict with other apps)
export APP_PORT_INTERNAL=3000
```

## Dockerfile

This is the file that defines your actual Application. This is what will build both your local development environment and your production environment.

We have provided a sample `Dockerfile` for a ficticious JavaScript app.

:bulb: **NOTE:** The `Dockerfile` in this repo is for reference only. The installation script will not download it into your project folder. You are responsible for crafting a proper `Dockerfile` that matches your tech stack and environment.


## Docker-Compose.yml

This file allows you to define multiple services (docker containers) and manage their deployment. For example, your `docker-compose.yml` could describe the following services for a full-stack web application:

* web
* backend
* database

We have provided a sample `docker-compose.yml` for a ficticious JavaScript app.

:bulb: **NOTE:** The `docker-compose.yml` in this repo is for reference only. The installation script will not download it into your project folder. You are responsible for crafting a proper `docker-compose.yml` that matches your tech stack and environment.

# Technology Stack
* [Docker](https://www.docker.com/):  Application containerization
* _you bring the rest..._


# Directory Structure

```
├── Dockerfile                     - Docker configuration file
├── docker-compose.yml             - Docker-Compose configuration file
├── README.md                      - This file
├── app/                           - The app itself
├── dev                            - Developer toolkit
├── dev.config                     - Configuration for this app
├── dev.init.sh                    - Custom dev init script (per project)
├── docs/                          - Documentation (swagger, etc)
└── test.sh                        - Test script to run against docker container
```

# Repo Owner Docs

## Readme Directory Tree

```sh
# brew install tree (if you don't have it)
tree -I 'node_modules|lib'
```
