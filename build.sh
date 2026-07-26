#!/bin/bash
set -e

if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b 3.44.8 --depth 1 $HOME/flutter
fi

export PATH="$PATH:$HOME/flutter/bin"

flutter config --enable-web

flutter pub get

flutter build web