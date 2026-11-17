#!/usr/bin/env bats
# Static checks for the extension manifest and its command files.

setup() {
  ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  MANIFEST="$ROOT/extension.yml"
}

@test "manifest has a valid id and a semver version" {
  id="$(yq '.extension.id' "$MANIFEST")"
  version="$(yq '.extension.version' "$MANIFEST")"
  [[ "$id" =~ ^[a-z][a-z0-9-]*$ ]]
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "every command is named speckit.<id>.<name> and its file exists" {
  id="$(yq '.extension.id' "$MANIFEST")"
  count=0
  while IFS=$'\t' read -r name file; do
    [[ "$name" =~ ^speckit\.${id}\.[a-z0-9-]+$ ]]
    [ -f "$ROOT/$file" ]
    count=$((count + 1))
  done < <(yq '.provides.commands[] | [.name, .file] | @tsv' "$MANIFEST")
  [ "$count" -ge 1 ]
}

@test "every command file has a description and takes \$ARGUMENTS" {
  while IFS= read -r file; do
    [ "$(sed -n '1p' "$ROOT/$file")" = "---" ]
    run bash -c "sed -n '2,/^---\$/p' '$ROOT/$file' | grep -E '^description: .+'"
    [ "$status" -eq 0 ]
    grep -qF '$ARGUMENTS' "$ROOT/$file"
  done < <(yq '.provides.commands[].file' "$MANIFEST")
}

@test "every hook runs a command this extension provides" {
  provided="$(yq '.provides.commands[].name' "$MANIFEST")"
  hooks="$(yq '.hooks[].command' "$MANIFEST")"
  [ -n "$hooks" ]
  while IFS= read -r command; do
    grep -qxF "$command" <<<"$provided"
  done <<<"$hooks"
}

@test "every hook is optional and has a prompt" {
  [ "$(yq '[.hooks[] | select(.optional != true)] | length' "$MANIFEST")" -eq 0 ]
  [ "$(yq '[.hooks[] | select((.prompt // "") == "")] | length' "$MANIFEST")" -eq 0 ]
}

@test "every hook event is a documented Spec Kit event" {
  while IFS= read -r event; do
    [[ "$event" =~ ^(before|after)_(specify|plan|tasks|implement|analyze|checklist|clarify|constitution|converge)$ ]]
  done < <(yq '.hooks | keys | .[]' "$MANIFEST")
}

@test "the release-please extra-file points at the manifest version" {
  config="$ROOT/.github/config/release-please-config.json"
  [ "$(jq -r '.packages["."]["extra-files"][0].path' "$config")" = "extension.yml" ]
  [ "$(jq -r '.packages["."]["extra-files"][0].jsonpath' "$config")" = '$.extension.version' ]
}

@test "manifest meets the community catalog metadata rules" {
  [ "$(yq '.extension.description | length' "$MANIFEST")" -lt 200 ]
  [ "$(yq '.tags | length' "$MANIFEST")" -ge 2 ]
  [ "$(yq '.tags | length' "$MANIFEST")" -le 5 ]
  [ "$(yq '.extension.repository' "$MANIFEST")" = "$(yq '.extension.homepage' "$MANIFEST")" ]
  [ -f "$ROOT/README.md" ]
  [ -f "$ROOT/LICENSE" ]
}
