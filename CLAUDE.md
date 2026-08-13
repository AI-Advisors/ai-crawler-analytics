# AI Crawler Analytics: a GTM Community Template

## What this is

One Google Tag Manager **server-side** tag template, published free in Google's Community Template Gallery by AI-Advisors. It classifies AI crawler, AI agent, and AI referral activity into three GA4 events.

**Why it exists is not the product.** It is a distribution play. A prior-art scan on 2026-07-30 verified the gap: 0 of 1,629 gallery templates treat AI crawlers as a positive signal rather than noise to exclude.

**The mechanism, stated correctly.** A gallery template does **not** put a backlink on the site that installs it. Verified by reading stape's own gallery template source: every occurrence of "stape" in it is the brand name in the INFO block or an internal event-name mapping. What a gallery template actually earns is measured in our own CI research: for the pixel-install query, the retrieval engines consolidated on stape's template as THE recommended method and cited it on **all 5 retrieval engines**, while our deeper, fresher, better-schema'd blog post was cited on Claude only. The artifact becomes the cited answer. Add gallery visibility and a linkable GitHub repo.

An earlier version of this file attributed stape's 1.4M "Frame" backlinks to template embeds. That was wrong; those are iframe links, most plausibly from stape's hosted sGTM containers, which is their actual business. **Do not project backlink volume from this template. Project citations and installs.**

So: **installs, citations, and credibility are the goal.** A feature that adds an install is worth more than a feature that adds capability. A claim that costs credibility costs more than any feature is worth.

Status: submitted to the gallery 2026-07-30, pending review. Marketing site: `~/Projects/ai-advisors` (separate repo, separate CLAUDE.md).

## The rules that are not negotiable

These came out of a six-verifier adversarial pass that found three blockers hours before submission. They exist because each was violated once.

1. **Never hand-transcribe binary data.** The brand thumbnail shipped as a corrupt PNG because 720 characters of base64 were typed rather than generated. Embed programmatically (`base64 -i icon.png`) and round-trip verify it decodes byte-identical before committing.
2. **Every factual claim needs a source you actually read.** Two README sentences were false at submission time: a sourcing policy contradicted by our own registry, and Cloudflare's allegation about Perplexity attributed to Perplexity's own documentation. Honesty is this template's differentiator, so a false claim here costs more than a missing feature.
3. **Never claim a capability the default install does not deliver.** GPTBot does not execute JavaScript (Vercel measured zero across 500M+ fetches). Without the Step B forward snippet, crawler rows stay near zero. The README says so plainly and must keep saying so.
4. **The word "verified" is reserved.** It does not appear as a data claim anywhere until v2 IP-range verification ships. Counts are self-declared user agents: spoofable up, stealth-crawlable down.
5. **No telemetry, ever.** Data goes only to the user's configured GA4 property. No version pings, no phone-home. This is the clean ToS position and also the reason the privacy section is short. Any telemetry idea is a product decision, not a patch.
6. **No em dashes** in any user-facing copy (house rule, shared with the marketing repo).

## Registry discipline

The 21-token `REGISTRY` array in `template.tpl` is the heart of the thing.

- **Vendor documentation first.** Add a token when the vendor documents it, or when multiple independent registries corroborate a stable token. Registry-only tokens (Bytespider, both Cohere tokens) are labelled as such in the README. Never invent one.
- **Never match bare fragments**: `searchbot`, `chatgpt`, `claude`, `adsbot`, `meta`, `cohere`. They false-positive on unrelated strings. `ccbot/` keeps its slash for the same reason.
- **Longest token first**, first match wins. `claude-searchbot` must be tested before `claudebot`.
- **Match against the full UA, truncate only on output.** OAI-SearchBot's token sits past character 100 of its real UA. Truncating first silently undercounts the exact bots this is named after.
- **Deliberate exclusions, documented in the README:** `Google-Extended` and `Applebot-Extended` are robots.txt-only tokens that never appear in a User-Agent header, so a matcher is dead code. Grok and DeepSeek have no vendor-documented UA. Microsoft Copilot rides Bingbot.
- **Cadence:** quarterly review, shipped as a `metadata.yaml` sha bump. The registry decays fast (OpenAI has bumped versions twice; Meta went from 1 crawler to 5 in a year).

**Cross-repo hazard.** The marketing site has its own crawler taxonomy at `app/api/tools/ai-bot-checker/robots.js` (25 tokens, powering `/tools/ai-bot-checker`). The two lists **legitimately differ**: this one matches User-Agent headers, that one parses robots.txt tokens. `Google-Extended` belongs there and not here. When a vendor ships a new crawler, both need updating, and they already drifted once within hours of the split. The planned fix is a shared public `ai-engines.json` in this repo that both consume.

## Testing

Two suites, and both must pass.

- `node test/run-tests.mjs` extracts the **real sandboxed code** from `template.tpl` and executes it in Node against shimmed GTM APIs. It is not a mirror of the logic, so green here means the shipping artifact is sound. 30 checks.
- The **`___TESTS___` section in the .tpl** runs in Google's own template editor. That editor is the authority on sandbox semantics and catches things Node cannot: two scenarios once passed locally and failed in the editor because `callLater` defers assertions to a later tick. Never interleave `runCode()` with a deferred `isEmpty` assertion; split into one scenario per case.

Both suites must be updated together. The Node harness asserts against parsed `g/collect` query params, so a change to the wire format breaks it loudly, which is intended.

## Architecture, and why

- **One server TAG template.** Client templates cannot be distributed through the gallery. There is no variable in v1.
- **Three tiers, strict precedence:** crawler UA registry, then the `Signature-Agent` header, then AI referral (UTM first because it survives referrer stripping, then referrer hostname). Referral is gated to `page_view` only.
- **Fixed event names** (`ai_crawler_visit`, `ai_agent_visit`, `ai_referral_visit`) with no user override. One schema across every install is what makes cross-install benchmarking possible later, and it is deliberately not configurable.
- **Sends via GA4 `g/collect`**, the same request every GA4 web client makes. An earlier draft used an undocumented `x-ga-measurement_id` routing key; it was removed because it was a guess. No `api_secret` is ever collected.
- **`bot_ua` is honored only on `ai_crawler_ping` events.** Otherwise the ping secret guards a door while a window stands open: anyone could forge a classification by putting `bot_ua` on any event.
- **Permissions are minimal and must stay so.** `read_event_data` (any), `read_request` (only the `user-agent` and `signature-agent` headers), `send_http` (only google-analytics.com), `logging` (debug). A reviewer reads this list; every addition is a question to answer.

## Release process

0. Know which half you are shipping. **The gallery serves only `template.tpl`, pinned by the `metadata.yaml` sha; snippets and README are consumed from GitHub directly.** So snippet/README/CLAUDE.md changes ship on push alone with NO metadata entry, and a `template.tpl` change is invisible to installers until its sha lands in `metadata.yaml`. (Learned 2026-08-12 when the Step B fix turned out to need no sha bump at all.)
1. Edit `template.tpl`, update **both** test suites, run `node test/run-tests.mjs`.
2. Import into a GTM **server** container and run the in-editor tests. A throwaway container works: decline the tagging-server provisioning prompt, it costs nothing and the test runner does not need one.
3. Commit. Then prepend a new entry to `metadata.yaml` `versions:` with the **new** template.tpl commit sha, newest first. The sha must point at the commit containing the template, not the metadata commit.
4. Push to `main`. Gallery propagation takes 2 to 3 days.

Commits author as `kevin@ai-advisors.ai`. The org handle is permanently exposed by the gallery URL, so nothing publishes from a personal account.

## Open items

- **RESOLVED 2026-08-12, and the failure was real: a default server container does NOT claim a JSON POST to `/mp/collect`.** Tested on a live tagging server (Google's `gtm-cloud-image:stable` on Cloud Run, this container's config): the original snippets' ping returned 400, byte-identical in behaviour to a nonsense path, with or without `measurement_id`/`api_secret`; the GA4 wire shape at `/g/collect` returned 200, claimed by the pre-installed GA4 client. Root cause: the sGTM Measurement Protocol client is a separate, NOT-pre-installed client with a user-chosen activation path; only the GA client ships by default. Fix shipped in the snippets + README (v=2 `g/collect` wire format, new `GA4_MEASUREMENT_ID` config line; the tag needed ZERO changes because the GA4 client parses `en`/`ep.*`/`dl`/`cid` into exactly the event-data keys the tag already reads). Full matrix and method: `docs/sgtm-mp-collect-verification-2026-08-12.md` in the marketing repo. **Still owed before the word "verified" appears anywhere near Step B:** a Preview-mode observation that the GA4 client parses `ep.bot_ua` with full fidelity and the tag fires with `ep.ai_source=GPTBot` outbound (blocked on 2026-08-12 by the GCP org policy that keeps Cloud Run non-public; use Stape's free tier or a container whose URL is publicly reachable). The second original question (does GA4 retain events whose params carry bot UA strings) also remains open and needs a real GA4 property.
- **v1.1 SHIPPED 2026-08-12: `oppref` is a Tier 3 referral signal.** Precedence UTM > oppref >
  referrer, with the reasoning in the code comment: an explicit advertiser tag stays
  authoritative, and a chatgpt.com referrer alone cannot separate paid from organic while
  oppref can (OpenAI appends it only to eligible ad clicks). Classifies as `ai_source=chatgpt`
  / OpenAI / `ai_medium=paid` / `detection_method=oppref`; the paid/organic distinction stays
  in `ai_medium` (the schema's existing axis), NOT in `ai_source` - the "distinguish in
  ai_source" idea from the queued note was rejected to keep one source slug per assistant.
  Read off `page_location` which Tier 3 already parses: no new permissions, no registry entry.
  Both suites updated together (3 new scenarios each; Node harness 33/33 on the real extracted
  code). Ships as a `metadata.yaml` sha bump pointing at the template commit. The web app and
  the template now agree about what a paid ChatGPT click is.
- **v2, priority order:** IP-range verification against vendor JSON (this is when "verified" enters the vocabulary), a WordPress plugin that emits the ping natively, a web-container companion honestly scoped to referrals only, and `ai-engines.json` as the shared public registry.
- Support arrives through GitHub Issues. The gallery ToS obligates continued support.
