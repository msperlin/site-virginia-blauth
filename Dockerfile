# Site estático (Google Cloud Run / qualquer host com Docker).
# Build a partir da raiz do repositório:
#   gcloud run deploy vblast-site --source . --region southamerica-east1 --allow-unauthenticated

FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html favicon.ico icon-192.png icon-512.png apple-touch-icon.png robots.txt sitemap.xml /usr/share/nginx/html/
COPY assets/ /usr/share/nginx/html/assets/

EXPOSE 8080
