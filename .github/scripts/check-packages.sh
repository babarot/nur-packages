#!/usr/bin/env bash
# Build every package for this system and run it with --version, so that a
# release that publishes a broken package is caught here rather than by
# whoever installs it next.
set -euo pipefail

system=$(nix eval --impure --raw --expr builtins.currentSystem)
failed=()

for dir in pkgs/*/; do
  name=$(basename "$dir")
  if [[ $(nix eval --json ".#$name.meta.platforms" | jq --arg s "$system" 'index($s) == null') == true ]]; then
    echo "$name: not built for $system, skipped"
    continue
  fi

  echo "::group::$name"
  if ! out=$(nix build --no-link --print-out-paths ".#$name"); then
    failed+=("$name: nix build failed")
    echo "::endgroup::"
    continue
  fi
  prog=$(nix eval --raw ".#$name.meta.mainProgram")
  version=$(nix eval --raw ".#$name.version")

  if ! output=$("$out/bin/$prog" --version 2>&1 </dev/null); then
    echo "$output"
    failed+=("$name: $prog --version exited with an error")
    echo "::endgroup::"
    continue
  fi
  echo "$output"
  # Only a warning: some tools print a version without the one released
  if [[ $output != *"$version"* ]]; then
    echo "::warning title=$name::$prog --version does not mention $version"
  fi
  echo "::endgroup::"
done

if ((${#failed[@]})); then
  printf '::error::%s\n' "${failed[@]}"
  exit 1
fi
