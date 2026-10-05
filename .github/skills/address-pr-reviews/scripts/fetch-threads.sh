#!/usr/bin/env bash
# fetch-threads.sh - Print a PR's unresolved review threads as compact JSON lines.
#
# Usage: fetch-threads.sh [<pr-number-or-url>]   (defaults to the current branch's PR)
#
# Line 1:  {"number","repo","head_branch","head_sha"}
# Line 2+: one unresolved thread per line:
#          {"thread_id","comment_id","path","line","outdated","diff_hunk","comments":[{"author","is_bot","body"}]}
#
# comment_id is the thread's first comment — reply to it so the reply lands in the thread.
# diff_hunk is trimmed to its last 12 lines (the code around the commented line).

set -euo pipefail

read -r number url branch sha < <(
  gh pr view ${1:+"$1"} --json number,url,headRefName,headRefOid \
    --jq '"\(.number) \(.url) \(.headRefName) \(.headRefOid)"'
)
repo=${url#*://*/}
repo=${repo%/pull/*}

printf '{"number":%s,"repo":"%s","head_branch":"%s","head_sha":"%s"}\n' "$number" "$repo" "$branch" "$sha"

gh api graphql --paginate \
  -f owner="${repo%/*}" -f name="${repo#*/}" -F number="$number" \
  -f query='
query($owner: String!, $name: String!, $number: Int!, $endCursor: String) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      reviewThreads(first: 100, after: $endCursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id isResolved isOutdated path line
          comments(first: 50) { nodes { databaseId diffHunk body author { __typename login } } }
        }
      }
    }
  }
}' \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[]
    | select(.isResolved | not)
    | .comments.nodes as $c
    | {
        thread_id: .id,
        comment_id: $c[0].databaseId,
        path,
        line,
        outdated: .isOutdated,
        diff_hunk: ($c[0].diffHunk // "" | split("\n") | .[-12:] | join("\n")),
        comments: [$c[] | {author: (.author.login // "ghost"), is_bot: (.author.__typename == "Bot"), body}]
      }'
