{ pkgs ? import <nixpkgs> {} }:

let
  android_sdk_pkg = pkgs.androidsdk;
  jdk_pkg = pkgs.openjdk;
in

pkgs.mkShell {
  buildInputs = [
    pkgs.flutter
    pkgs.dart
    jdk_pkg
    android_sdk_pkg
    pkgs.which
    pkgs.chromium
  ];

  shellHook = ''
    # Java setup
    export JAVA_HOME=${jdk_pkg}
    export PATH="${jdk_pkg}/bin"

    # Android SDK setup
    export ANDROID_SDK_ROOT=${android_sdk_pkg}
    export PATH="${android_sdk_pkg}/bin:${android_sdk_pkg}/platform-tools:${PATH}:${jdk_pkg}/bin:${pkgs.flutter}/bin"

    # Chrome setup for Flutter web
    export CHROME_EXECUTABLE=${pkgs.chromium}/bin/chromium

    # Accept Android SDK licenses automatically
    mkdir -p "$HOME/.android"
    touch "$HOME/.android/repositories.cfg"
    yes | ${android_sdk_pkg}/bin/sdkmanager --licenses > /dev/null 2>&1 || true

    echo "Environment ready:"
    echo "  JAVA_HOME=$JAVA_HOME"
    echo "  ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
    echo "  CHROME_EXECUTABLE=$CHROME_EXECUTABLE"
  '';
}
