{ pkgs, ... }:

let
  jdk = pkgs.openjdk17;
in
{
  # Use a stable Nix channel.
  channel = "stable-24.05";

  # Install necessary packages for Flutter development.
  packages = [
    pkgs.flutter
    pkgs.dart
    (pkgs.git.override { })
    pkgs.which
    pkgs.openjdk17
    pkgs.chromium
  ];

  # Define environment variables.
  env = {
    JAVA_HOME = "${jdk}";
    CHROME_EXECUTABLE = "${pkgs.chromium}/bin/chromium";
  };

  # Configure the IDE previews.
  idx.previews = {
    enable = true;
    previews = {
      web = {
        command = ["flutter" "run" "-d" "web-server" "--web-hostname" "0.0.0.0" "--web-port" "$PORT"];
        manager = "web";
      };
      android = {
        manager = "flutter";
      };
    };
  };
}
