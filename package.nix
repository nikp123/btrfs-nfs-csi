{
  buildGoModule,
  rev
}: let
  src = ./.;
  version = builtins.readFile "${src}/VERSION";
in buildGoModule {
  pname = "btrfs-nfs-csi";
  inherit version;
  inherit src;

  ldflags = [
    "-X main.version=${version} -X main.commit=${rev}"
  ];

  vendorHash = "sha256-yRCmPMMli/EmnAavGXD/eqtGHs7ZGo9ww06kkP8aR8I=";
}
