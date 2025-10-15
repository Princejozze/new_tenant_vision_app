# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "unstable"; # Using unstable to get a newer Flutter/Dart SDK

  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.flutter
    pkgs.dart
  ];

  # Sets environment variables in the workspace
  env = {};

  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];

    workspace = {
      # To run something each time the workspace is (re)started, use the `onStart` hook
      onStart = {};
    };

    # Enable previews and customize configuration
    previews = {
      enable = true;
      previews = {
        web = {
          command = [ "sh" "-c" "flutter run --machine -d web-server --web-hostname 0.0.0.0 --web-port $PORT" ];
          manager = "flutter";
        };
      };
    };
  };
}
