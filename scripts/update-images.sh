# Updates the container image versions annotated in the Nix modules.
#
# Each image is marked with a comment on the line right before it. The image
# and its current version come from the image reference on that line:
#
#   # update-image: <tag regex>
#   image = "repo/name:1.2.3";
#
# The regex selects which of the image's tags are versions (it must match the
# current one). The highest matching tag with the same major version is
# applied; for 0.x versions, the minor version acts as the major one, as in
# semver. Newer major versions are only reported.
#
# Usage: update-images [repository root]
# Prints a Markdown summary of the changes to stdout.

root=${1:-.}

# Major version of a tag: 1.2.3 -> 1, v2.0.1 -> 2, 0.18.0 -> 0.18
major_of() {
  local version=${1#v} first
  first=${version%%[!0-9]*}
  if [[ $first == 0 ]]; then
    version=${version#0.}
    echo "0.${version%%[!0-9]*}"
  else
    echo "$first"
  fi
}

declare -A tags_cache=()
updated=()
majors=()
errors=()

# Split grep's "file:line:text" by hand: `IFS=: read` would drop the trailing
# colon of an annotation without a regex
while IFS= read -r match; do
  file=${match%%:*}
  match=${match#*:}
  line=${match%%:*}
  read -r regex <<<"${match#*update-image:}" || true
  target=$((line + 1))
  where="${file#"$root"/}:$target"
  version_line=$(sed -n "${target}p" "$file")

  if [[ $version_line =~ image\ =\ \"([^\"]*):([^\":]+)\" ]]; then
    image=${BASH_REMATCH[1]}
    current=${BASH_REMATCH[2]}
    old=":$current\""
  else
    errors+=("$where: the line after the annotation isn't \`image = \"<image>:<tag>\"\`")
    continue
  fi

  if [[ -z $regex ]]; then
    errors+=("\`$image\` ($where): the annotation has no tag regex")
    continue
  fi

  if ! grep -qE "$regex" <<<"$current"; then
    errors+=("\`$image\` ($where): current version \`$current\` doesn't match \`$regex\`")
    continue
  fi

  if [[ -z ${tags_cache[$image]+set} ]]; then
    echo "Listing tags of $image" >&2
    if ! tags=$(crane ls "$image" 2>&1); then
      errors+=("\`$image\` ($where): could not list tags: ${tags##*$'\n'}")
      continue
    fi
    tags_cache[$image]=$tags
  fi

  # Matching tags newer than the current version, in ascending order
  newer_tags=$(
    {
      grep -E "$regex" <<<"${tags_cache[$image]}" || true
      echo "$current"
    } | sort -V -u | awk -v current="$current" 'found { print } $0 == current { found = 1 }'
  )

  current_major=$(major_of "$current")
  best=$current
  latest_major=
  while read -r tag; do
    [[ -z $tag ]] && continue
    if [[ $(major_of "$tag") == "$current_major" ]]; then
      best=$tag
    else
      latest_major=$tag
    fi
  done <<<"$newer_tags"

  if [[ $best != "$current" ]]; then
    new="${old/"$current"/"$best"}"
    NEW_LINE=${version_line/"$old"/"$new"} awk -v n="$target" \
      'NR == n { print ENVIRON["NEW_LINE"]; next } { print }' "$file" >"$file.tmp"
    mv "$file.tmp" "$file"
    updated+=("| \`$image\` | $current | $best | \`$where\` |")
  fi
  if [[ -n $latest_major ]]; then
    majors+=("| \`$image\` | $current | $latest_major | \`$where\` |")
  fi
done < <(grep -rnE --include='*.nix' '^[[:space:]]*# update-image:' "$root/modules" | sort)

echo "## Container images"
echo
if ((${#updated[@]} == 0 && ${#majors[@]} == 0 && ${#errors[@]} == 0)); then
  echo "All container images are up to date."
fi
if ((${#updated[@]} > 0)); then
  echo "Updated within the same major version:"
  echo
  echo "| Image | From | To | Where |"
  echo "|---|---|---|---|"
  printf '%s\n' "${updated[@]}"
  echo
fi
if ((${#majors[@]} > 0)); then
  echo "**New major versions available, not applied.** Update them manually after checking their release notes:"
  echo
  echo "| Image | Current | Latest | Where |"
  echo "|---|---|---|---|"
  printf '%s\n' "${majors[@]}"
  echo
fi
if ((${#errors[@]} > 0)); then
  echo "**Could not check:**"
  echo
  printf -- '- %s\n' "${errors[@]}"
fi
