# AI Crawler Analytics by AI-Advisors

A Google Tag Manager **server-side** tag that shows AI crawler, AI agent, and AI referral activity inside your own GA4 property.

Every other bot template treats crawlers as noise to filter out. This one treats them as a signal marketers now need: whether GPTBot, ClaudeBot, OAI-SearchBot, and PerplexityBot are reading your site is the earliest measurable indicator of whether AI assistants can cite you at all.

**Your data goes only to the GA4 property you configure. Nothing is ever sent to AI-Advisors.**

Built by [AI-Advisors](https://www.ai-advisors.ai), the AI visibility platform for B2B marketing teams.

---

## Prerequisite, stated first

This template runs in a **GTM server container** (server-side GTM). It cannot run in a normal web container, because the AI crawlers that matter here (GPTBot, ClaudeBot, PerplexityBot, OAI-SearchBot) do not execute JavaScript: no web-container tag will ever see them, and any template that claims otherwise is wrong.

If you do not have a server container yet: [what server-side tagging is](https://developers.google.com/tag-platform/tag-manager/server-side/intro), and hosting options from [Google Cloud](https://developers.google.com/tag-platform/tag-manager/server-side/cloud-run-setup-guide) or [Stape](https://stape.io). If you only run web GTM, this template cannot help you; our [AI referral tracking guide](https://www.ai-advisors.ai/blog/how-to-track-brand-mentions-in-ai-search) covers what is possible client-side.

## What you get

Three fixed GA4 events, one schema across every install:

| Event | Fires for | Detection |
|---|---|---|
| `ai_crawler_visit` | AI crawlers (GPTBot, ClaudeBot, PerplexityBot, OAI-SearchBot, and 16 more) | User agent registry |
| `ai_agent_visit` | Agentic browsing that identifies itself (ChatGPT agent mode via `Signature-Agent`, Google-Agent) | Header or UA |
| `ai_referral_visit` | Humans arriving from AI assistants (ChatGPT, Perplexity, Gemini, Copilot, Claude, and more) | UTM first, referrer second |

Every event carries: `ai_type`, `ai_source`, `ai_operator`, `ai_category` (search / user_initiated / ads / training / agentic / referral), `detection_method`, plus `ai_medium` (organic or paid) on referrals and `bot_ua` on crawler events. Paid AI clicks tagged `utm_source=chatgpt&utm_medium=cpc` surface as `ai_medium=paid` automatically.

## Step A: install the tag (no code, about 5 minutes)

1. In your **server** container: Templates, Search Gallery, add **AI Crawler Analytics by AI-Advisors**. Review the permissions shown (read event data, read the `user-agent` and `signature-agent` request headers, send HTTPS requests to Google Analytics, debug logging).
2. New Tag, choose the template, paste your **GA4 Measurement ID**. Use a dedicated GA4 property if you want crawler data separated from your main analytics.
3. Trigger: one **Custom** trigger, event name matching all events (the tag self-filters and exits quietly on everything human).
4. Publish.

What works on day one with no further setup: AI referral traffic, paid vs organic AI clicks, ChatGPT agent-mode visits where the `Signature-Agent` header is present, and best-effort detection of the few crawlers that execute JavaScript (Applebot, Google-Agent).

## Step B: see the real crawlers (about 15 minutes, the headline)

GPTBot, ClaudeBot, PerplexityBot, and OAI-SearchBot do not run JavaScript. Vercel measured **zero** JavaScript executions across 500M+ GPTBot fetches. That is not a limitation of this template; it is physics of crawlers that never render your pages. The only way any GTM setup can see them is a tiny server-side forward.

Pick your platform in [`snippets/`](snippets/):

- [Cloudflare Worker](snippets/cloudflare-worker.js)
- [Next.js middleware](snippets/nextjs-middleware.ts)
- [Express / Node](snippets/express-middleware.js)
- [WordPress mu-plugin](snippets/wordpress-mu-plugin.php)

Each is under 50 lines, fire-and-forget, and never delays the crawler's response. The Express snippet needs Node 18 or newer (built-in fetch). The Cloudflare and Express snippets skip static-asset requests so all four platforms count page requests the same way. If you add your own rows to the tag's registry, mirror them in the snippet's prefilter regex too, or your additions will only be seen for events the container already receives. Set your server container URL (and the optional Ping secret, mirrored in the tag's Advanced settings, which makes spoofed pings much harder; the tag also ignores the bot_ua parameter on any event that is not an ai_crawler_ping). The snippet sends the **full** user agent to your own container; the tag classifies it and truncates only on output.

If you use another All Events GA4 forwarding tag in the same container, add an exception for event name `ai_crawler_ping` to it, so raw pings are not double-forwarded as unclassified junk.

## Step C: register the dimensions (one time, in GA4)

GA4 Admin, Custom definitions, create **event-scoped** custom dimensions for: `ai_type`, `ai_source`, `ai_operator`, `ai_category`, `detection_method`, and optionally `ai_medium`. Reports populate from that moment onward.

## Verify

1. GTM Preview on the server container; visit any page of your site with `?utm_source=chatgpt&utm_medium=cpc` appended. You should see the tag fire and an `ai_referral_visit` with `ai_medium=paid` in GA4 Realtime.
2. With Step B installed: `curl -A "GPTBot/1.2" https://your-site.com/` and watch `ai_crawler_visit` arrive.

## Reporting guidance

Report crawler activity as **event count by `ai_source`**, never as sessions or users. Crawler events deliberately collapse into a handful of synthetic `aic.*` client IDs so they cannot inflate your user counts. If you want full separation, point the tag at a dedicated GA4 property.

## The registry

21 built-in matchers across OpenAI (GPTBot, OAI-SearchBot, ChatGPT-User, OAI-AdsBot), Anthropic (ClaudeBot, Claude-SearchBot, Claude-User), Perplexity (PerplexityBot, Perplexity-User), Meta (ExternalAgent, ExternalFetcher, WebIndexer), Apple (Applebot), Amazon (Amazonbot), ByteDance (Bytespider), Mistral (MistralAI-User), DuckDuckGo (DuckAssistBot), Common Crawl (CCBot), Cohere, and Google-Agent. Add your own rows or disable built-ins in the tag's Crawler registry settings; no template update needed.

Deliberately excluded, and why:

- **Google-Extended and Applebot-Extended**: robots.txt-only tokens. They never appear in a User-Agent header, so a matcher for them is dead code. Nobody can count them by UA; anyone who claims to is guessing.
- **Grok / xAI and DeepSeek**: no vendor-documented crawler user agent as of July 2026, and no stable token corroborated across independent bot registries either. We add tokens on vendor documentation or solid multi-registry corroboration, whichever comes first; a few shipped rows (Bytespider, the two Cohere tokens) are registry-corroborated rather than vendor-documented, and are labeled from the best available characterization.
- **Microsoft Copilot**: rides Bingbot for crawling and is not separable from ordinary Bing indexing.

## Honest limitations

1. A standard web GTM container cannot see GPTBot, ClaudeBot, or PerplexityBot. Neither can this template without Step B. Anything else you have read is wrong.
2. Counts are based on self-declared user agents. Spoofed UAs can inflate them; Cloudflare has documented Perplexity falling back to undeclared generic browser user agents when its declared bots are blocked (a characterization Perplexity publicly disputes), which would deflate them. Treat the numbers as a strong directional signal, not an audited count. IP-range verification is planned for v2, and the word "verified" does not appear in this template until it ships.
3. Gemini and Google AI Overviews crawl via ordinary Googlebot and are not separable by user agent. This template makes no Gemini crawl claims.
4. Agentic browsers (ChatGPT Atlas, Perplexity Comet, Claude for Chrome) present plain Chrome user agents by design. We label only agent traffic that identifies itself (the `Signature-Agent` header, Google-Agent). Coverage of agent mode depends on the header being present, which we do not overclaim.
5. Detection of JavaScript-executing bots in Step A (Applebot, Google-Agent) is best effort: rendering is reported for these agents, but delivery of the analytics beacon to your server container on any given render is not guaranteed.
6. Data goes only to the GA4 property you configure. Nothing is sent to AI-Advisors, no version checks, no telemetry, nothing.

## Support

Open a [GitHub issue](https://github.com/ai-advisors/ai-crawler-analytics/issues). Registry updates ship quarterly, or sooner when vendors document new crawlers.

## License

Apache 2.0. Copyright 2026 AI-Advisors.
