#!/usr/bin/env bash
# Publish this site to production (S3 + CloudFront) at https://botsquirrel.com
# The GitHub Pages copy stays as the test environment and needs no action —
# it updates on push. Run this only when you want the change live for customers.
set -euo pipefail
BUCKET=botsquirrel-site-640533248752
DIST=EP4TSVD5YUCV7
cd "$(dirname "$0")"

# WHAT IS EXCLUDED, AND WHY
#
#   Tooling dirs (.git, .github, .gstack, .claude) — never customer content.
#     .claude/ in particular holds stale full-site worktree copies (~137 MB),
#     each with its own index.html and d/. They are gitignored, so GitHub Pages
#     never sees them, but `aws s3 sync` walks dotfiles by default and would
#     publish the lot — including nested copies of the files excluded below.
#
#   Build tooling (deploy-prod.sh, render-demo-video.js, demo-video-source.html)
#     — leaks the bucket name, AWS account id, CloudFront distribution id and
#     local filesystem paths. demo-video-source.html is an offscreen render
#     stage for the demo video, not a page anyone should land on.
#
#   d/ — one-off prospect demo pages plus their third-party screenshots. Those
#     outreach links deliberately point at the GitHub Pages copy (the pages carry
#     noindex and reproduce third-party branding), so they must stay reachable
#     there and must NEVER appear on customer-facing botsquirrel.com.
#
# PATTERN RULE: `aws s3 sync --exclude` matches the WHOLE relative key, and `*`
# crosses `/`. A bare "deploy-prod.sh" therefore matches only the root copy — a
# nested .claude/worktrees/<id>/deploy-prod.sh slips straight through, which is
# how the previously-suppressed files kept getting republished. Every rule below
# is a directory prefix ("d/*") or carries a leading `*` ("*/deploy-prod.sh") so
# nested copies are caught too. Do not "simplify" these back to bare names.

# Assets get a long cache; HTML gets a short one so copy changes appear quickly.
aws s3 sync . "s3://$BUCKET/" --delete \
  --exclude ".git/*" --exclude ".github/*" --exclude ".gstack/*" --exclude ".claude/*" \
  --exclude "d/*" --exclude "docs/*" --exclude "*/docs/*" \
  --exclude ".DS_Store" --exclude "*/.DS_Store" \
  --exclude "deploy-prod.sh" --exclude "*/deploy-prod.sh" \
  --exclude "render-demo-video.js" --exclude "*/render-demo-video.js" \
  --exclude "*.html" --cache-control "public,max-age=31536000"
aws s3 sync . "s3://$BUCKET/" \
  --exclude "*" --include "*.html" \
  --exclude ".git/*" --exclude ".github/*" --exclude ".gstack/*" --exclude ".claude/*" \
  --exclude "d/*" --exclude "docs/*" --exclude "*/docs/*" \
  --exclude "demo-video-source.html" --exclude "*/demo-video-source.html" \
  --cache-control "public,max-age=300" --content-type "text/html; charset=utf-8"

aws cloudfront create-invalidation --distribution-id "$DIST" --paths "/*" \
  --query 'Invalidation.{Id:Id,Status:Status}' --output table
echo "Live at https://botsquirrel.com (edge refresh takes a minute or two)"
