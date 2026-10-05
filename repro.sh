#!/usr/bin/env bash
# Usage: ./repro.sh [turbo version], default canary.
set -euo pipefail

version="${1:-canary}"
original="$(cat turbo.json)"
trap 'printf "%s\n" "$original" > turbo.json' EXIT

for flag in false true; do
  for dependsOn in '[]' '["^build"]' '["^lint"]'; do
    cat > turbo.json <<JSON
{
  "futureFlags": { "filterUsingTasks": $flag },
  "tasks": { "build": {}, "lint": { "dependsOn": $dependsOn } }
}
JSON
    printf 'filterUsingTasks=%-5s lint.dependsOn=%-11s ' "$flag" "$dependsOn"
    npx --yes "turbo@$version" run lint --filter='app...' --dry=json 2>/dev/null \
      | sed -n '/^{/,$p' \
      | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>console.log(JSON.parse(s).tasks.filter(t=>t.command!=="<NONEXISTENT>").map(t=>t.taskId).join(" ")))'
  done
done
