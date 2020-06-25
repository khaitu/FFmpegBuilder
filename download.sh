#! /usr/bin/env bash
#
# Copyright (C) 2013-2015 Bilibili
# Copyright (C) 2013-2015 Zhang Rui <bbcallen@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FFMPEG_UPSTREAM=https://git.ffmpeg.org/ffmpeg.git
FFMPEG_COMMIT=n4.3
FFMPEG_LOCAL=ffmpeg

GAS_UPSTREAM=https://github.com/libav/gas-preprocessor
GAS_LOCAL=gas-preprocessor

set -e
TOOLS=tools

FF_ALL_ARCHS="arm64 x86_64"
FF_TARGET=$1

function echo_ffmpeg_version() {
    echo $FFMPEG_COMMIT
}

function clone_repo() {
  if [ ! -d $2 ]; then
    git clone $1 $2
  else
    cd $2
    git fetch --all --tags
    cd -
  fi
}

function ref_repo() {
  if [ ! -d $2 ]; then
    git clone --reference $3 $1 $2
    cd $2
    git repack -a
    cd -
  else
    cd $2
    git fetch --all --tags
    cd -
  fi
}


function pull_common() {
    git --version

    clone_repo $GAS_UPSTREAM $GAS_LOCAL
    clone_repo $FFMPEG_UPSTREAM $FFMPEG_LOCAL
}

function pull_fork() {
    ref_repo $FFMPEG_UPSTREAM arch/ffmpeg-$1 ${FFMPEG_LOCAL}

    cd arch/ffmpeg-$1

    git checkout ${FFMPEG_COMMIT} -B build

    cd -
}

function pull_fork_all() {
    for ARCH in $FF_ALL_ARCHS
    do
        pull_fork $ARCH
    done
}

case "$FF_TARGET" in
    ffmpeg-version)
        echo_ffmpeg_version
    ;;
    arm64|i386|x86_64)
        pull_common
        pull_fork $FF_TARGET
    ;;
    all|*)
        pull_common
        pull_fork_all
    ;;
esac
