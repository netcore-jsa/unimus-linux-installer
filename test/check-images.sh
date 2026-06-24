#!/bin/bash

# Validate that every container image referenced by the test menu is pullable
# from its registry. Uses 'docker manifest inspect', which queries the registry
# without downloading layers and works for foreign-architecture images too, so
# this is a fast sanity check (catches images that have been removed/renamed).
#
# This does NOT prove an install succeeds - that is what run-test-container.sh
# is for; it only proves the images still exist and can be pulled.
#
# Requires: docker. Exits non-zero if any image is missing.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
menu="${DIR}/run-test-container.sh";

# the test menu is the single source of truth: every selectable distro is a
# 'docker_run "<image>"' line (skip the '-c' passthrough docker_run "${image}")
mapfile -t images < <(grep -oE 'docker_run "[^"]+"' "${menu}" \
  | sed -E 's/^docker_run "//; s/"$//' \
  | grep -vxF '${image}' \
  | sort -u);

if [[ ${#images[@]} -eq 0 ]]; then
  echo "ERROR: no images found in ${menu}";
  exit 1;
fi;

echo "Checking ${#images[@]} test images are pullable...";
echo;

fail=0;
for img in "${images[@]}"; do
  if docker manifest inspect "${img}" > /dev/null 2>&1; then
    printf '  ok   - %s\n' "${img}";
  else
    printf '  FAIL - %s (not pullable)\n' "${img}";
    fail=$((fail + 1));
  fi;
done;

echo;
if [[ ${fail} -eq 0 ]]; then
  echo "All ${#images[@]} images pullable.";
  exit 0;
fi;

echo "${fail} image(s) not pullable.";
exit 1;
