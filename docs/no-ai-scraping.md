# No-AI scraping policy

unstructured.fyi lets traditional search engines index it and asks AI
systems not to use it. That covers model training, AI answers (retrieval and
grounding), and AI agents fetching pages for a user.

No single standard covers all of this yet. So the site sends the same
preference through four layers. Each layer is read by a different set of
crawlers.

| Layer | File | Read by | Status |
| --- | --- | --- | --- |
| Named-crawler blocks | `public/robots.txt` | All major AI vendors' crawlers | RFC 9309 (standard) |
| `Content-Usage` (robots.txt + HTTP header) | `public/robots.txt`, `infra/cdn/main.tf` | Crawlers adopting IETF AI Preferences | IETF Internet-Draft |
| `Content-Signal` | `public/robots.txt` | Crawlers honouring Cloudflare's Content Signals Policy | Industry convention |
| TDMRep | `public/.well-known/tdmrep.json`, `<meta name="tdm-reservation">` | EU text-and-data-mining tooling | W3C Community Group spec |

## 1. Blocking named crawlers (`robots.txt`)

This is the layer that actually stops crawling. Every major AI vendor has
committed to honouring `robots.txt` for its own user-agent tokens.

```
User-agent: GPTBot
User-agent: ClaudeBot
User-agent: Google-Extended
...
Disallow: /
```

- Under RFC 9309, several `User-agent` lines followed by rules form one
  group. The `Disallow: /` applies to every agent named above it.
- A crawler obeys only the most specific group that matches its token. So a
  crawler named here ignores the permissive `User-agent: *` group further
  down.
- Some tokens are **control tokens** rather than crawlers.
  `Google-Extended`, `Applebot-Extended` and `Webzio-Extended` don't fetch
  anything. Instead, Google, Apple and Webz.io check them to decide whether
  pages their *search* crawlers fetched may also be used for AI. Blocking
  them keeps the site in Google Search and Siri/Spotlight while opting out
  of Gemini/Vertex and Apple Intelligence training.
- The list covers three kinds of agent: training crawlers (GPTBot,
  ClaudeBot, CCBot, Meta-ExternalAgent, …), AI search/answer indexers
  (OAI-SearchBot, Claude-SearchBot, PerplexityBot, …), and user-triggered
  agents (ChatGPT-User, Claude-User, Perplexity-User, …).

The list is a snapshot of the community-maintained
[ai.robots.txt](https://github.com/ai-robots-txt/ai.robots.txt) project. Two
entries were removed because they aren't AI-only:

- `Applebot`: powers Siri and Spotlight search. Apple's AI training opt-out
  is `Applebot-Extended`, which stays blocked.
- `facebookexternalhit`: builds link previews when a post is shared on
  Facebook, Messenger or WhatsApp.

### Refreshing the list

New AI crawlers appear regularly, so refresh the list every few months:

```bash
curl -sL https://raw.githubusercontent.com/ai-robots-txt/ai.robots.txt/main/robots.txt \
  | grep -v -x -e 'User-agent: Applebot' -e 'User-agent: facebookexternalhit'
```

Paste the output over section 1 of `public/robots.txt` and update the
snapshot date in the comment.

## 2. `Content-Usage`: IETF AI Preferences

The IETF [AI Preferences (aipref)](https://datatracker.ietf.org/wg/aipref/about/)
working group is standardising a vocabulary for how crawled content may be
*used*. Two drafts define it:
[vocab](https://datatracker.ietf.org/doc/draft-ietf-aipref-vocab/) (-08) and
[attach](https://datatracker.ietf.org/doc/draft-ietf-aipref-attach/) (-05).

```
Content-Usage: train-ai=n, ai-use=n, search=y
```

| Category | Meaning | Value here |
| --- | --- | --- |
| `train-ai` | Changing the learned parameters of a generative AI model | `n` |
| `ai-use` | Feeding the content to a generative model as input the user didn't supply themselves (RAG, grounding, AI answers) | `n` |
| `search` | Use in an application that points users to where the content lives | `y` |

- Only bare `y` and `n` are valid. Values like `no` or `"n"` are read as
  "unknown", not as a refusal.
- Robots.txt controls two separate things. `Allow`/`Disallow` decides what
  may be **fetched**, and `Content-Usage` states how fetched content may be
  **used**. That's why the line sits in the `User-agent: *` group: it covers
  crawlers that are allowed in, such as search engines.
- The same preference is sent as an HTTP response header on every request.
  A Bunny.net edge rule (`bunnynet_pullzone_edgerule.ai_usage_header` in
  `infra/cdn/main.tf`) adds it. The header goes with the content itself, so
  the preference still applies to copies obtained some other way, such as a
  cache, an archive or a dataset. Apply it with `terraform apply` in
  `infra/cdn`.

## 3. `Content-Signal`: Cloudflare Content Signals Policy

```
Content-Signal: search=yes, ai-input=no, ai-train=no
```

This is Cloudflare's [Content Signals Policy](https://contentsignals.org/).
It covers the same ground as `Content-Usage` with different token names
(`ai-input` corresponds to `ai-use`). Millions of sites behind Cloudflare
publish it by default, which makes it a widely recognised convention. We use
Bunny.net, not Cloudflare, but any crawler that parses robots.txt can read
the line. It's included alongside `Content-Usage` until the IETF draft
becomes final.

Under RFC 9309 §2.2.4, crawlers must ignore rule lines they don't
recognise. Neither line in sections 2 or 3 can change how a search engine
crawls the site.

## 4. TDMRep: EU text-and-data-mining reservation

EU copyright law (DSM Directive 2019/790, Art. 4) permits text and data
mining unless the rights holder reserves those rights "in an appropriate
manner, such as machine-readable means". The EU AI Act requires providers of
general-purpose AI models to respect that reservation.
[TDMRep](https://www.w3.org/community/reports/tdmrep/CG-FINAL-tdmrep-20240510/)
is the W3C Community Group protocol for making the reservation:

- `public/.well-known/tdmrep.json`: `"tdm-reservation": 1` for `location: "/"`
  reserves TDM rights for the whole site.
- `<meta name="tdm-reservation" content="1">` in `BaseLayout.astro` puts the
  same reservation on every HTML page.

A `tdm-policy` URL can be added later if the site ever offers licensing
terms.

## What this does not do

- **It doesn't enforce anything.** Each layer is a request. Crawlers that
  ignore robots.txt or fake their user agent get through anyway. Actual
  blocking needs server-side enforcement, such as Bunny Shield bot rules or
  an edge rule with `BlockRequest` matched on `User-Agent`. That approach
  has its own maintenance and false-positive costs.
- **It doesn't opt out of Google AI Overviews / AI Mode.** Those features
  run on Googlebot, the same crawler as Search, and Google provides no
  separate robots token for them. `Google-Extended` only covers
  Gemini/Vertex training and grounding. The `ai-use=n` / `ai-input=no`
  signals state the preference, but Google doesn't currently honour them
  for Search features. The only stronger option is `nosnippet`, which also
  removes search snippets.
- **It doesn't affect content already collected** before these files were
  published.
- **No `noai` / `noimageai` meta tags.** These were popularised by DeviantArt,
  were never standardised, and major AI vendors don't recognise them.
  `Content-Usage` and TDMRep replace them.

## Verifying

After `yarn build`, all files are in `dist/`:

```bash
cat dist/robots.txt
cat dist/.well-known/tdmrep.json
grep -o '<meta name="tdm-reservation"[^>]*>' dist/index.html
```

In production, after deploying and running `terraform apply`:

```bash
curl -sI https://unstructured.fyi/ | grep -i content-usage
curl -s https://unstructured.fyi/robots.txt | head
```
