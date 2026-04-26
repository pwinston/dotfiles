#!/usr/bin/env bash
# Orson worktree setup: copy main repo's .env into the new worktree, bumping
# each dev-server port to the next value unused by any sibling worktree.
#
# Called by ~/bin/wt-new as: setup.sh <target> <name> <main-repo>

set -euo pipefail

target="$1"
main_repo="$3"
parent=$(dirname "$main_repo")
repo_name=$(basename "$main_repo")

# Ports we manage. Base values match the main orson checkout's .env.
declare -a keys=(API_PORT WEB_PORT BACKLOT_PORT BACKLOT_API_PORT)
declare -A base=(
  [API_PORT]=8001
  [WEB_PORT]=9001
  [BACKLOT_PORT]=7001
  [BACKLOT_API_PORT]=6001
)

# Collect ports currently in use across the main repo and all sibling worktrees.
declare -A used
shopt -s nullglob
env_files=("$main_repo/.env" "$parent/$repo_name"-*/.env)
shopt -u nullglob
for env_file in "${env_files[@]}"; do
  [ -f "$env_file" ] || continue
  while IFS='=' read -r k v; do
    case "$k" in
      API_PORT|WEB_PORT|BACKLOT_PORT|BACKLOT_API_PORT)
        used["$k:$v"]=1
        ;;
    esac
  done < "$env_file"
done

# Pick the next free port per key, starting from the base.
declare -A chosen
for k in "${keys[@]}"; do
  p=${base[$k]}
  while [ -n "${used[$k:$p]:-}" ]; do
    p=$((p + 1))
  done
  chosen[$k]=$p
  used["$k:$p"]=1
done

# Copy main repo's .env, substituting the four port lines. If no source .env,
# write a minimal stub (user will need to fill in secrets).
if [ -f "$main_repo/.env" ]; then
  sed_args=()
  for k in "${keys[@]}"; do
    sed_args+=(-e "s|^${k}=.*|${k}=${chosen[$k]}|")
  done
  sed "${sed_args[@]}" "$main_repo/.env" > "$target/.env"
else
  {
    for k in "${keys[@]}"; do
      echo "$k=${chosen[$k]}"
    done
  } > "$target/.env"
  echo "orson setup: no $main_repo/.env found; wrote stub with ports only" >&2
fi

echo "orson setup: $target/.env ports -> API=${chosen[API_PORT]} WEB=${chosen[WEB_PORT]} BACKLOT=${chosen[BACKLOT_PORT]} BACKLOT_API=${chosen[BACKLOT_API_PORT]}"

# Create per-worktree Python virtualenv and install the project (editable, with dev extras).
# Uses uv for speed; falls back to python -m venv + pip if uv is missing.
if command -v uv >/dev/null 2>&1; then
  echo "orson setup: creating .venv with uv"
  uv venv "$target/.venv" --python 3.14.1
  uv pip install --python "$target/.venv/bin/python" -e "$target[dev]"
else
  echo "orson setup: creating .venv with python -m venv (uv not found)"
  python3 -m venv "$target/.venv"
  "$target/.venv/bin/pip" install -e "$target[dev]"
fi

# Install npm dependencies in each subproject that has a package.json.
for npm_dir in "$target" "$target/web" "$target/backlot"; do
  if [ -f "$npm_dir/package.json" ]; then
    echo "orson setup: npm install in $npm_dir"
    (cd "$npm_dir" && npm install)
  fi
done
