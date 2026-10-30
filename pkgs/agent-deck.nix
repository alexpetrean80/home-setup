{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go,
}:
buildGoModule (finalAttrs: {
  pname = "agent-deck";
  version = "1.16.34";

  src = fetchFromGitHub {
    owner = "asheshgoplani";
    repo = "agent-deck";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fehA9JNE/viQ4hAZ0djyignluQWRoYunKnQOWRLv+YA=";
  };

  vendorHash = "sha256-MPtWVgxZ6JKrLOtujlueHAisyRXf7w6lBW+CPRLg3kE=";

  # Upstream pins the go directive to the newest patch release, which nixpkgs
  # tends to trail; GOTOOLCHAIN=local then refuses to build. Patch releases
  # carry no language changes, so build with whatever 1.26 nixpkgs has.
  postPatch = ''
    sed -i 's/^go .*/go ${go.version}/' go.mod
  '';

  subPackages = ["cmd/agent-deck"];

  env.CGO_ENABLED = 0;

  # No -X telemetry.defaultPostHogKey: without the release key the binary
  # never uploads, consent or not (TELEMETRY.md).
  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  # The suite drives real tmux servers and agent CLIs; not runnable in the sandbox.
  doCheck = false;

  meta = {
    description = "Terminal session manager for AI coding agents";
    homepage = "https://github.com/asheshgoplani/agent-deck";
    license = lib.licenses.mit;
    mainProgram = "agent-deck";
    platforms = lib.platforms.unix;
  };
})
