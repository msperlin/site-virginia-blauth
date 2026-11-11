#!/usr/bin/env bash
# Monta a pasta _site/ com apenas os arquivos públicos do site.
# Usado pelo `firebase deploy` (hook predeploy) e pelo GitHub Pages.
set -euo pipefail

cd "$(dirname "$0")/.."

rm -rf _site
mkdir -p _site
cp index.html favicon.svg apple-touch-icon.png robots.txt sitemap.xml _site/
cp -r assets _site/assets
