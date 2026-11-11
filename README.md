# Site — Virgínia Blauth · Psicóloga

Site institucional de **Virgínia Blauth, psicóloga (CRP 07/41396)**, com
atendimento presencial em Porto Alegre (bairro Auxiliadora) e online.

O design escolhido foi o **Editorial Calmo** (creme, serifa expressiva, foto em
arco), uma das oito alternativas criadas na etapa de estudo. As demais
alternativas foram retiradas do projeto.

## Estrutura

```
.
├── index.html              # página completa (HTML + CSS + JS inline)
├── assets/
│   ├── fonts/              # Fraunces 400/600/400 itálico e Karla 400/600 (WOFF2)
│   └── img/
│       ├── hero.jpg        # retrato principal
│       ├── consultorio.jpg # foto do consultório
│       └── og.jpg          # cartão 1200×630 para compartilhamento
├── favicon.svg
├── apple-touch-icon.png
├── robots.txt
├── sitemap.xml
├── nginx.conf              # configuração de produção (cache, gzip, headers)
├── Dockerfile              # imagem para Cloud Run ou qualquer host Docker
└── .github/workflows/deploy-pages.yml
```

As fontes e fotos antes estavam embutidas em base64 dentro do HTML. Foram
separadas em arquivos próprios para permitir cache do navegador e reduzir o
peso da página: o `index.html` passou de ~419 KB para ~35 KB.

## Pré-visualizar localmente

Abra o arquivo `index.html` no navegador ou, preferencialmente, sirva a pasta
por HTTP:

```bash
python3 -m http.server 8000
# http://localhost:8000
```

## Publicar

### GitHub Pages (automático)

O workflow `.github/workflows/deploy-pages.yml` publica o site a cada push na
branch `main`. Basta habilitar em **Settings → Pages → Source: GitHub Actions**.
O endereço padrão será `https://USUARIO.github.io/NOME-DO-REPOSITORIO/`.

### Google Cloud Run

```bash
gcloud run deploy vblast-site \
  --source . \
  --region southamerica-east1 \
  --allow-unauthenticated
```

### Qualquer hospedagem estática

Envie `index.html`, `assets/`, `favicon.svg`, `apple-touch-icon.png`,
`robots.txt` e `sitemap.xml` para a raiz do host.

## Domínio próprio

O `canonical`, as tags Open Graph, o `robots.txt` e o `sitemap.xml` apontam para
**https://virginiabpsicologa.com/**. Se o domínio final for outro:

1. Substitua as ocorrências de `https://virginiabpsicologa.com/` em
   `index.html`, `robots.txt` e `sitemap.xml`.
2. No GitHub Pages, adicione o domínio em **Settings → Pages → Custom domain**
   (isso cria o arquivo `CNAME`) e configure o DNS:
   - apex (`@`): registros `A` para `185.199.108.153`, `185.199.109.153`,
     `185.199.110.153` e `185.199.111.153`;
   - `www`: `CNAME` para `USUARIO.github.io`.
3. Ative **Enforce HTTPS**.
4. Migre o domínio com TTL baixo e mantenha o site antigo no ar por alguns dias
   até validar o novo.

## Antes de publicar — conferir

- [ ] WhatsApp: `https://wa.me/5551998555131` (8 ocorrências) e telefone
      `(51) 99855-5131`.
- [ ] E-mail: `virginiab.psicologa@gmail.com`.
- [ ] Endereço: Rua Comendador Rheingantz, 35 — Auxiliadora, Porto Alegre/RS.
- [ ] Instagram: `@virginiab.psicologa`.
- [ ] Link do guia ACALME-SE no Google Drive.
- [ ] Para pré-preencher a mensagem do WhatsApp, use
      `https://wa.me/5551998555131?text=Ol%C3%A1%2C%20Virg%C3%ADnia!%20Gostaria%20de%20agendar%20uma%20consulta.`
- [ ] Aviso de emergência (CVV 188) no rodapé — já incluído.

## Conteúdo e manutenção

- Cores, fontes e espaçamentos estão nas variáveis CSS `:root` no início do
  `index.html` (`--paper`, `--ink`, `--terra`, `--sage`, `--serif`, `--sans`).
- O menu mobile, o scroll suave e as animações de entrada usam JavaScript
  inline; há fallback via `<noscript>`.
- O site não tem formulário nem backend: o contato é por WhatsApp, telefone e
  e-mail.
- Se adicionar analytics, prefira soluções sem cookies (Plausible, Umami ou
  Cloudflare Web Analytics) e atualize o aviso de privacidade (LGPD).

## Licenças

Fontes, fotografia e código estão descritos em [`LICENSES.md`](LICENSES.md).
