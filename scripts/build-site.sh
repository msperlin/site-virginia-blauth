#!/usr/bin/env bash
# Monta a pasta _site/ com apenas os arquivos públicos do site.
# Usado pelo `firebase deploy` (hook predeploy) e pelo GitHub Pages.
set -euo pipefail

cd "$(dirname "$0")/.."

rm -rf _site
mkdir -p _site
cp index.html 404.html favicon.ico icon-192.png icon-512.png apple-touch-icon.png \
  site.webmanifest robots.txt sitemap.xml _site/
cp -r assets _site/assets

# Mantém o <lastmod> do sitemap coerente com a data do deploy.
sed -i "s|<lastmod>[^<]*</lastmod>|<lastmod>$(date -u +%F)</lastmod>|" _site/sitemap.xml
