# Dockerize

Scaffolding for Dockerized Development Environment

# What is this?

This is a sample repo that uses Docker to automate dev setup and create consistency in deployed environments.

# Developer Getting Started

This application is built using Docker, which creates a Production equivalent environment on your system. It will mount the git repo app directory into the docker container so you can still work on your native OS but run the app in a sandbox.

Download and run the setup:

```sh
git clone INSERT_YOUR_REPO_URL
cd YOUR_REPO
./dev init
# this will make sure docker is installed and then will launch a docker quickstart shell.
# once you see the new shell prompt, run
./dev start
```

When init completes, it will automatically launch a browser pointing to the running app.

### Start and stop the live running app
If for some reason you need to stop/start the app, you can do so like this:

```sh
./dev stop
./dev start
./dev restart
```

### Run Tests

```sh
./dev test;
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
# The Github ORG/User for your project
export APP_ORG="your-github-org"
# The repo name for your github project/repo
export APP_NAME="my-dockerized-app"
# the port to run your app on (change this to something random that won't bump into another app)
export APP_PORT_EXTERNAL=4103
# the port your app listens on within the container (will not conflict with other apps)
export APP_PORT_INTERNAL=3000
```

## Dockerfile
This is the file that defines your actual Application. This is what will build both your local development environment and your production environment--YES, they are the same!

# Technology Stack
* [Docker](https://www.docker.com/):  Application containerization
* _you bring the rest..._


# Directory Structure

```
├── Dockerfile                     - Docker configuration file
├── README.md                      - This file
├── app/                           - The app itself
├── dev                            - Developer toolkit
├── dev.config.sh                  - Configuration for this app
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
