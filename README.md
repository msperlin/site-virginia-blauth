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
│       ├── og.jpg          # cartão 1200×630 para compartilhamento
│       ├── marca-horizontal.png  # marca (símbolo + nome + Psicóloga)
│       └── marca-simbolo.png     # símbolo isolado, sem texto
├── favicon.ico             # ícone 16/32/48 (fundo creme + símbolo)
├── icon-192.png            # ícone para Android/manifest
├── icon-512.png            # ícone grande (também usado no schema.org)
├── apple-touch-icon.png    # ícone 180×180 para iOS
├── robots.txt
├── sitemap.xml
├── firebase.json           # Firebase Hosting (headers, cache, predeploy)
├── scripts/build-site.sh   # monta _site/ com os arquivos públicos
├── nginx.conf              # headers e cache equivalentes (alternativa em Docker)
├── Dockerfile              # imagem para Cloud Run ou qualquer host Docker
└── .github/workflows/deploy-firebase.yml   # deploy automático na branch main
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

### Firebase Hosting

O site é publicado no Firebase Hosting. O `firebase.json` usa `_site/` como
pasta pública e roda `scripts/build-site.sh` antes de cada deploy, então só os
arquivos do site são enviados (o `Dockerfile`, o `nginx.conf` e o README ficam
de fora).

```bash
npm install -g firebase-tools
firebase login
firebase use --add          # escolhe o projeto Firebase
firebase deploy             # build + envio
```

Para testar localmente com o mesmo comportamento de produção (cache, headers,
compressão):

```bash
firebase emulators:start --only hosting
# http://localhost:5000
```

#### Deploy automático

O workflow `.github/workflows/deploy-firebase.yml` publica no canal `live` a
cada push na branch `main`. Ele usa a service account
`github-deploy@virginia-blauth-site.iam.gserviceaccount.com` (papéis
`firebasehosting.admin` e `serviceusage.serviceUsageConsumer`), cuja chave JSON
fica no secret `FIREBASE_SERVICE_ACCOUNT_VIRGINIA_BLAUTH_SITE`.

Para publicar manualmente sem CI, use `firebase deploy` conforme acima.

#### Desfazer um deploy

```bash
firebase hosting:rollback --project virginia-blauth-site
```

### Alternativa: Google Cloud Run

O `Dockerfile` e o `nginx.conf` continuam no repositório apenas como
alternativa (mesma política de cache e headers). Para usar:

```bash
gcloud run deploy vblast-site \
  --source . \
  --region southamerica-east1 \
  --allow-unauthenticated
```

### Qualquer hospedagem estática

Envie `index.html`, `assets/`, `favicon.ico`, `icon-192.png`, `icon-512.png`,
`apple-touch-icon.png`, `robots.txt` e `sitemap.xml` para a raiz do host.

## Domínio próprio

O `canonical`, as tags Open Graph, o `robots.txt` e o `sitemap.xml` apontam para
**https://virginiabpsicologa.com/**, que é servido pelo Firebase Hosting:

1. No console do Firebase, em **Hosting → Adicionar domínio personalizado**,
   informe `virginiabpsicologa.com`.
2. Crie no provedor de DNS o registro `TXT` de verificação exibido pelo Firebase.
3. Crie os registros `A` com os IPs informados pelo Firebase. Para `www`, use um
   `CNAME` para `virginia-blauth-site.web.app` ou adicione `www` como domínio
   secundário redirecionando para o apex.
4. Se o DNS estiver na Cloudflare, mantenha os registros em **DNS only**
   (nuvem cinza) até o certificado aparecer como **Conectado**.
5. O certificado TLS é emitido automaticamente; a propagação leva de minutos a
   24 horas.

Se o domínio final for outro, substitua as ocorrências de
`https://virginiabpsicologa.com/` em `index.html`, `robots.txt` e
`sitemap.xml`.

## Antes de publicar — conferir

- [ ] WhatsApp: `https://wa.me/5551998555131` e telefone `(51) 99855-5131`.
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
- A seção **Dúvidas frequentes** usa `<details>`/`<summary>` nativos: abre sem
  JavaScript e é navegável por teclado. Ao alterar perguntas ou respostas,
  atualize também o bloco JSON-LD `FAQPage` no `<head>` (usado pelo Google).
- O site não tem formulário nem backend: o contato é por WhatsApp, telefone e
  e-mail.
- Se adicionar analytics, prefira soluções sem cookies (Plausible, Umami ou
  Cloudflare Web Analytics) e atualize o aviso de privacidade (LGPD).

## Licenças

Fontes, fotografia e código estão descritos em [`LICENSES.md`](LICENSES.md).
