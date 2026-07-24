#!/usr/bin/env bash
# Publish this site to production (S3 + CloudFront) at https://botsquirrel.com
# The GitHub Pages copy stays as the test environment and needs no action —
# it updates on push. Run this only when you want the change live for customers.
set -euo pipefail
BUCKET=botsquirrel-site-640533248752
DIST=EP4TSVD5YUCV7
cd "$(dirname "$0")"

# Assets get a long cache; HTML gets a short one so copy changes appear quickly.
aws s3 sync . "s3://$BUCKET/" --delete \
  --exclude ".git/*" --exclude ".github/*" --exclude ".DS_Store" --exclude "deploy-prod.sh" \
  --exclude "*.html" --cache-control "public,max-age=31536000"
aws s3 sync . "s3://$BUCKET/" \
  --exclude "*" --include "*.html" --exclude ".git/*" \
  --cache-control "public,max-age=300" --content-type "text/html; charset=utf-8"

aws cloudfront create-invalidation --distribution-id "$DIST" --paths "/*" \
  --query 'Invalidation.{Id:Id,Status:Status}' --output table
echo "Live at https://botsquirrel.com (edge refresh takes a minute or two)"
