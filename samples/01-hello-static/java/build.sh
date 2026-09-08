#!/usr/bin/env sh
set -eu

SAMPLE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SDK_DIR="$SAMPLE_DIR/../../../sdk/java/lib"
MAIN_SOURCE_DIR="$SAMPLE_DIR/source/src/main/java"
TEST_SOURCE_DIR="$SAMPLE_DIR/source/src/test/java"
BUILD_DIR="$SAMPLE_DIR/build"
MAIN_CLASSES="$BUILD_DIR/classes"
TEST_CLASSES="$BUILD_DIR/test-classes"
PACKAGE_DIR="$BUILD_DIR/package"
LIBRARY_NAME="hello-static"
OUTPUT_ZIP="$SAMPLE_DIR/hello-static.zip"

rm -rf "$BUILD_DIR"
rm -f "$OUTPUT_ZIP"
mkdir -p "$MAIN_CLASSES" "$TEST_CLASSES" "$PACKAGE_DIR/$LIBRARY_NAME"

find "$MAIN_SOURCE_DIR" -name '*.java' -print > "$BUILD_DIR/main-sources.txt"
javac --release 11 \
  -cp "$SDK_DIR/ZohoFlow-extension-sdk.jar:$SDK_DIR/json.jar" \
  -d "$MAIN_CLASSES" \
  @"$BUILD_DIR/main-sources.txt"

find "$TEST_SOURCE_DIR" -name '*.java' -print > "$BUILD_DIR/test-sources.txt"
javac --release 11 \
  -cp "$MAIN_CLASSES:$SDK_DIR/ZohoFlow-extension-sdk.jar:$SDK_DIR/json.jar" \
  -d "$TEST_CLASSES" \
  @"$BUILD_DIR/test-sources.txt"

java -ea \
  -cp "$TEST_CLASSES:$MAIN_CLASSES:$SDK_DIR/ZohoFlow-extension-sdk.jar:$SDK_DIR/json.jar" \
  com.zoho.flow.samples.hello.HelloConnectorSmokeTest

jar --create \
  --file "$PACKAGE_DIR/$LIBRARY_NAME/$LIBRARY_NAME.jar" \
  --manifest "$SAMPLE_DIR/MANIFEST.MF" \
  -C "$MAIN_CLASSES" .

(cd "$PACKAGE_DIR" && zip -qr "$OUTPUT_ZIP" "$LIBRARY_NAME")

echo "Created $OUTPUT_ZIP"
