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
├── 404.html                # página de erro (Firebase e nginx a servem automaticamente)
├── site.webmanifest        # nome, cores e ícones para "adicionar à tela inicial"
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

Envie `index.html`, `404.html`, `site.webmanifest`, `assets/`, `favicon.ico`,
`icon-192.png`, `icon-512.png`, `apple-touch-icon.png`, `robots.txt` e
`sitemap.xml` para a raiz do host.

## Ver acessos (Cloud Logging)

O site não tem JavaScript de analytics e nada é gravado no navegador do
visitante. Para ver quem acessa, use os **logs de requisição do próprio Firebase
Hosting**, exportados para o Cloud Logging. Não exige código, nem banner de
cookies, e não muda o peso da página.

### Ligar a exportação (uma vez)

1. Abra <https://console.firebase.google.com/project/virginia-blauth-site/settings/integrations/cloudlogging>.
2. Em **Configurações do projeto → Integrações**, no cartão **Cloud Logging**,
   clique em **Vincular**.
3. Marque **somente** o site `virginia-blauth-site` e conclua.

É preciso uma conta com papel **Owner**, **Editor** ou **Firebase Develop
Admin** no projeto — a service account de deploy
(`github-deploy@virginia-blauth-site.iam.gserviceaccount.com`) não serve.

As requisições **novas** aparecem em até ~30 minutos; não há histórico
retroativo. A retenção padrão é de 30 dias e a franquia gratuita é de 50 GB/mês
— este site usa uma fração mínima disso.

### Consultar

Abra <https://console.cloud.google.com/logs/query?project=virginia-blauth-site>
e use:

```
resource.type="firebase_domain"
logName="projects/virginia-blauth-site/logs/webrequests"
```

Ajustes úteis:

| Pergunta | Como fazer |
|---|---|
| Quais páginas são acessadas | agrupar por `httpRequest.requestUrl` |
| De qual cidade/país vem | agrupar por `jsonPayload.remoteIpCity` e `jsonPayload.remoteIpCountry` |
| Como a pessoa chegou | olhar `httpRequest.referer` (Instagram, Google, WhatsApp, direto) |
| Pessoas x robôs | `httpRequest.userAgent=~"Mozilla"` para manter navegadores; filtrar `Googlebot\|bingbot\|facebookexternalhit` para remover robôs |
| Links quebrados | `httpRequest.status=404` |
| Domínio próprio x `.web.app` | agrupar por `jsonPayload.hostname` |

Campos disponíveis em cada requisição: `remoteIp`, `referer`, `userAgent`,
`requestUrl`, `status`, `latency`, `cacheHit`, `remoteIpCountry` e
`remoteIpCity`.

### Observações

- A aba **Hosting** do console do Firebase mostra armazenamento e transferência,
  não visitantes.
- O painel **Uso** do Cloud Logging (e o `log_bytes` no Logs Explorer) serve para
  acompanhar o volume de dados dos logs.
- `remoteIp` e cidade são dados pessoais pela LGPD: mantenha a retenção padrão de
  30 dias e não compartilhe os logs. Como nada é gravado no dispositivo do
  visitante, não é necessário banner de consentimento.
- Para histórico maior que 30 dias, exporte os logs para o BigQuery (exige
  plano Blaze) ou use uma ferramenta de analytics sem cookies, como Plausible,
  Umami ou Cloudflare Web Analytics.

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

## SEO e presença local

- **Google Business Profile** (perfil da empresa no Google) é o que coloca o
  consultório no mapa para buscas como "psicóloga perto de mim". Use o mesmo
  nome, endereço e telefone do site; o `schema.org` já publica esses dados.
- **Google Search Console**: cadastre `https://virginiabpsicologa.com/` e envie
  `sitemap.xml`. Não usa cookies, então não muda nada no aviso de privacidade.
- **Dados pendentes no schema.org** (`index.html`, bloco `Psychologist`):
  `openingHoursSpecification` e `geo` (latitude/longitude do consultório).
  Sem essas informações o `LocalBusiness` continua válido, apenas menos completo.
- **FAQ no Google**: desde 2023 os resultados enriquecidos de FAQ aparecem
  sobretudo em sites de governo e saúde. O bloco `FAQPage` segue válido e útil
  para outros buscadores, mas não espere ver as perguntas expandidas no SERP.

## Antes de publicar — conferir

- [ ] WhatsApp: `https://wa.me/5551998555131` e telefone `(51) 99855-5131`.
- [ ] E-mail: `virginiab.psicologa@gmail.com`.
- [ ] Endereço: Rua Comendador Rheingantz, 35 — Auxiliadora, Porto Alegre/RS.
- [ ] Instagram: `@virginiab.psicologa`.
- [ ] Link do guia ACALME-SE no Google Drive.
- [ ] Para pré-preencher a mensagem do WhatsApp, use
      `https://wa.me/5551998555131?text=Ol%C3%A1%2C%20Virg%C3%ADnia!%20Gostaria%20de%20agendar%20uma%20consulta.`
- [ ] Aviso de emergência (CVV 188) no rodapé — já incluído.
- [ ] Cloud Logging vinculado ao site `virginia-blauth-site` (ver
      [Ver acessos (Cloud Logging)](#ver-acessos-cloud-logging)).

## Conteúdo e manutenção

- Cores, fontes e espaçamentos estão nas variáveis CSS `:root` no início do
  `index.html` (`--paper`, `--ink`, `--terra`, `--sage`, `--serif`, `--sans`).
- O menu mobile, o scroll suave e as animações de entrada usam JavaScript
  inline; há fallback via `<noscript>`.
- A seção **Dúvidas frequentes** usa `<details>`/`<summary>` nativos: abre sem
  JavaScript e é navegável por teclado. Ao alterar perguntas ou respostas,
  atualize também o bloco JSON-LD `FAQPage` no `<head>` (usado pelo Google).
- O site não tem formulário nem backend: o contato é por WhatsApp, telefone e
  e-mail. O botão principal do topo abre a **conversa inicial gratuita de 20
  minutos**; no celular, uma barra fixa repete essa ação depois que o topo sai
  da tela (`.m-bar`).
- **Links do WhatsApp**: cada seção usa `?text=` com uma mensagem
  pré-preenchida, então a origem do contato já aparece na primeira mensagem. Ao
  criar uma seção nova, siga o mesmo padrão (codifique o texto com
  <https://www.urlencoder.org>).
- **Cache de imagens**: imagens e ícones ficam uma semana em cache porque o nome
  é fixo — ao trocar uma foto, **renomeie o arquivo** (`hero-2.jpg`) para não
  servir a antiga. As fontes são `immutable` por um ano: se mudarem, renomeie
  também.
- **Página 404**: `404.html` usa caminhos absolutos (`/assets/...`) porque o
  Firebase a serve em qualquer profundidade de URL.
- O acompanhamento de acessos é feito pelos logs do Firebase Hosting no Cloud
  Logging (ver [Ver acessos](#ver-acessos-cloud-logging)); não há script de
  analytics na página. Se adicionar um, prefira soluções sem cookies (Plausible,
  Umami ou Cloudflare Web Analytics) e atualize o aviso de privacidade (LGPD).

## Licenças

Fontes, fotografia e código estão descritos em [`LICENSES.md`](LICENSES.md).
