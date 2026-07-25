#!/bin/bash
set -e

git clone https://github.com/flutter/flutter.git -b 3.44.8 --depth 1 $HOME/flutter

export PATH="$PATH:$HOME/flutter/bin"

flutter config --enable-web

flutter doctor

flutter build web