#!/bin/bash -eu

# https://qiita.com/youcune/items/fcfb4ad3d7c1edf9dc96
# -euでエラーか未定義変数でストップする

cd "$(cd "$(dirname "$0")"; pwd)/../" # cd to project root

NORMAL=$(tput sgr0)
YELLOW=$(tput setaf 3)
GRAY=$(tput setaf 8)

function message() {
    echo -e "$GRAY$*$NORMAL"
}

function warning() {
    echo -e "$YELLOW$*$NORMAL"
}

# generic

message "##### Run EOF Check"
./cli-scripts/check_endoffile_with_newline.sh

# node packages

message "##### Run ESLint"
yarn run lint:eslint

message "##### Run tsc"
yarn run lint:tsc

message "##### Run Pritter check"
yarn run lint:prettier

message "##### Run markdownlint"
yarn run lint:markdownlint

message "##### Run stylelint"
yarn run lint:stylelint

message "##### Run Markuplint"
yarn run lint:markuplint

# gems

message "##### Run Rubocop"
bundle exec rubocop

message "##### Run Rubocop ERB"
bundle exec rubocop --config .rubocop-erb.yml

message "##### Run ERB Lint"
bundle exec erb_lint --lint-all

message "##### Run Brakeman"
bundle exec brakeman --no-pager --run-all-checks

# docker

message "##### Run Hadolint"
if type hadolint > /dev/null 2>&1; then
    HADOLINT="hadolint"
elif type docker > /dev/null 2>&1; then
    HADOLINT="docker run --rm -i hadolint/hadolint <"
fi

if [ -n "${HADOLINT}" ]; then
    files=$(git ls-files | grep "Dockerfile")
    for file in ${files}; do
        eval "${HADOLINT} ${file}"
    done
else
    warning "[SKIP] Hadolint, hadolint or Docker is required."
fi

message "##### Run Docker Build Checks"
if type docker > /dev/null 2>&1; then
    files=$(git ls-files | grep "Dockerfile")
    for file in ${files}; do
        docker build --build-arg RUBY_VERSION="$(cat .ruby-version)" --check --file "${file}" .
    done
else
    warning "[SKIP] Docker Build Checks, Docker is required."
fi

# GitHub Actions

message "##### Run Actionlint"
if type jactionlint > /dev/null 2>&1; then
    jactionlint
else
    warning "[SKIP] Actionlint, actionlint or Docker is required."
fi

message "##### Run ghalint"
if type ghalint > /dev/null 2>&1; then
    ghalint run
else
    warning "[SKIP] ghalint, ghalint is required."
fi

message "##### Run zizmor"
if type zizmor > /dev/null 2>&1; then
    zizmor --offline --persona auditor --collect default -- .
elif type uvx > /dev/null 2>&1; then
    uvx zizmor --offline --persona auditor --collect default -- .
elif type docker > /dev/null 2>&1; then
    docker run --rm --tty \
           --mount type=bind,src="$(pwd)",dst=/repo,readonly \
           --workdir /repo \
           ghcr.io/woodruffw/zizmor:latest \
           --offline --persona auditor --collect default -- .
else
    warning "[SKIP] zizmor, zizmor or Docker is required."
fi
