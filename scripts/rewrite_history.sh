#!/usr/bin/env bash
set -e

echo "Starting history rewrite: replacing author/committer names/emails containing 'claude' or 'copilot' and stripping Co-authored-by trailers..."

git filter-branch --force --env-filter '
case "$GIT_AUTHOR_NAME" in
  *claude*|*Claude*|*copilot*|*Copilot*)
    export GIT_AUTHOR_NAME="amine_dubs"
    export GIT_AUTHOR_EMAIL="belatrecheamine4@gmail.com"
  ;;
esac
case "$GIT_AUTHOR_EMAIL" in
  *claude*|*Claude*|*copilot*|*Copilot*)
    export GIT_AUTHOR_NAME="amine_dubs"
    export GIT_AUTHOR_EMAIL="belatrecheamine4@gmail.com"
  ;;
esac
case "$GIT_COMMITTER_NAME" in
  *claude*|*Claude*|*copilot*|*Copilot*)
    export GIT_COMMITTER_NAME="amine_dubs"
    export GIT_COMMITTER_EMAIL="belatrecheamine4@gmail.com"
  ;;
esac
case "$GIT_COMMITTER_EMAIL" in
  *claude*|*Claude*|*copilot*|*Copilot*)
    export GIT_COMMITTER_NAME="amine_dubs"
    export GIT_COMMITTER_EMAIL="belatrecheamine4@gmail.com"
  ;;
esac
' --msg-filter 'sed "/Co-authored-by:.*claude/d; /Co-authored-by:.*CLAUDE/d; /Co-authored-by:.*copilot/d; /Co-authored-by:.*Copilot/d"' --tag-name-filter cat -- --all

# Additionally strip any 'tmpclaude' tokens present in commit messages
echo "Stripping 'tmpclaude' tokens from commit messages..."
git filter-branch --force --msg-filter 'sed "s/tmpclaude-[^ ]*//g; s/tmpclaude//g; s/  / /g"' --tag-name-filter cat -- --all

echo "Cleaning up original refs and running garbage collection..."
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo "Force-pushing cleaned history and tags to remote 'ai'..."
git push ai --force --all
git push ai --force --tags

echo "Rewrite and push finished."
