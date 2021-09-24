#!/usr/bin/env bash

inputPatterns=()
defaultPatterns=("bar")
blockedUrlPatterns=("${defaultPatterns[@]}" "${inputPatterns[@]}")

cat <<- EOF > lighthouserc.yml
ci:
  collect:
    url:
      - "$host/$query_string"
      - "$host/products/$product_handle$query_string"
      - "$host/collections/$collection_handle$query_string"
    puppeteerScript: './setPreviewCookies.js'
$(echo "    settings:" && echo "      blockedUrlPatterns:" && for i in "${blockedUrlPatterns[@]}"; do echo "        - \"$i\""; done)
    puppeteerLaunchOptions:
      args:
        - "--no-sandbox"
        - "--disable-setuid-sandbox"
        - "--disable-dev-shm-usage"
        - "--disable-gpu"
  upload:
    target: temporary-public-storage
  assert:
    assertions:
      "categories:performance":
        - error
        - minScore: $min_score_performance
          aggregationMethod: median-run
      "categories:accessibility":
        - error
        - minScore: $min_score_accessibility
          aggregationMethod: median-run
EOF
