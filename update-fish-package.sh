#!/usr/bin/env bash

set -ex

FISH_PACKAGE=$1

if [ -z ${FISH_PACKAGE} ]; then
    echo "Please specify fish package name"
    exit 1
fi

FISH_PACKAGE_FILE_PATH=Food/${FISH_PACKAGE}.lua
FISH_FOOD_LOCAL_GIT_REPO=~/oss/github.com/fishworks/fish-food
DEFAULT_BRANCH=main
SOURCE_REMOTE_REF=source
FORK_REMOTE_REF=origin
PR_BRANCH=update-${FISH_PACKAGE}
GITHUB_USERNAME=karuppiah7890

declare FISH_PACKAGE_GITHUB_REPO_URLS

FISH_PACKAGE_GITHUB_REPO_URLS["hugo"]="https://github.com/gohugoio/hugo"

FISH_PACKAGE_GITHUB_REPO_URL=${FISH_PACKAGE_GITHUB_REPO_URLS[FISH_PACKAGE]}

cd ${FISH_FOOD_LOCAL_GIT_REPO}

git checkout ${DEFAULT_BRANCH}

git remote | grep ${SOURCE_REMOTE_REF}
git remote | grep ${FORK_REMOTE_REF}

git pull --rebase ${SOURCE_REMOTE_REF} ${DEFAULT_BRANCH}

git branch -D ${PR_BRANCH} || true

git checkout -b ${PR_BRANCH}

GITHUB_JSON_RESPONSE=$(curl -L -H "Accept: application/json" ${FISH_PACKAGE_GITHUB_REPO_URL}/releases/latest)

LATEST_VERSION=$(echo "${GITHUB_JSON_RESPONSE}" | tr -s '\n' ' ' | sed 's/.*"tag_name":"//' | sed 's/".*//')

LATEST_VERSION_NUMBER=$(echo $LATEST_VERSION | sed 's/v//')

uff ${FISH_PACKAGE_FILE_PATH} $LATEST_VERSION_NUMBER

git add ${FISH_PACKAGE_FILE_PATH}

git commit -m "${FISH_PACKAGE} ${LATEST_VERSION}"

git push ${FORK_REMOTE_REF} ${PR_BRANCH}

open "https://github.com/fishworks/fish-food/compare/main...${GITHUB_USERNAME}:${PR_BRANCH}"
