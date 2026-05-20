#!/bin/bash
set -e

echo "Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1

echo "Adding Flutter to PATH..."
export PATH="$PATH:`pwd`/flutter/bin"

echo "Running flutter doctor..."
flutter doctor -v

echo "Creating .env and env files for Flutter..."
echo "GROK_API_KEY=$GROK_API_KEY" > .env
echo "GROK_API_KEY=$GROK_API_KEY" > env

echo "Building Flutter Web..."
flutter build web --release
