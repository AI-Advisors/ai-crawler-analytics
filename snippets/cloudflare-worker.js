// AI Crawler Analytics: crawler forward for Cloudflare Workers.
// Forwards AI crawler page requests to your server-side GTM container as
// ai_crawler_ping events. Fire-and-forget: it never delays or alters the
// response served to the crawler.
//
// 1. Set SGTM_URL to your server container URL (no trailing slash).
// 2. Set GA4_MEASUREMENT_ID to the same Measurement ID you configured on
//    the tag. It routes the ping inside your container; the tag decides
//    where data is sent.
// 3. If you set a Ping secret on the tag, set PING_SECRET to the same value.
// 4. Deploy as a Worker route covering your site, or merge the waitUntil
//    block into your existing Worker.
//
// The ping uses the GA4 g/collect wire format because that is what the
// GA4 client pre-installed in every server container claims. A JSON POST
// to /mp/collect is NOT claimed by a default container (tested on a live
// tagging server, 2026-08-12) and would be silently dropped.

const SGTM_URL = "https://sgtm.example.com"; // your server GTM container URL
const GA4_MEASUREMENT_ID = "G-XXXXXXXXXX"; // same ID as on the tag
const PING_SECRET = ""; // must match the tag's Ping secret, or leave empty

// Fast prefilter only. The tag's registry is authoritative; keep this regex
// permissive and let the tag decide. Send the FULL user agent, never sliced:
// some tokens (OAI-SearchBot) appear after character 100 of the real UA.
const AI_CRAWLER_RE = /(gptbot|oai-searchbot|oai-adsbot|chatgpt-user|claudebot|claude-searchbot|claude-user|perplexitybot|perplexity-user|mistralai-user|duckassistbot|applebot|amazonbot|bytespider|meta-externalagent|meta-externalfetcher|meta-webindexer|ccbot\/|cohere-ai|cohere-training-data-crawler|google-agent)/i;

// Skip static assets so page-request counts line up across all snippets.
const ASSET_RE = /\.(ico|png|jpg|jpeg|gif|svg|css|js|txt|xml|webmanifest|woff2?)$/i;

export default {
  async fetch(request, env, ctx) {
    const ua = request.headers.get("user-agent") || "";
    const path = new URL(request.url).pathname;
    const match = !ASSET_RE.test(path) && ua.match(AI_CRAWLER_RE);
    if (match) {
      const qs = new URLSearchParams({
        v: "2",
        tid: GA4_MEASUREMENT_ID,
        cid: "aic." + match[1].toLowerCase().replace("/", ""),
        en: "ai_crawler_ping",
        "ep.bot_ua": ua, // full UA, never truncated here
        dl: request.url,
      });
      if (PING_SECRET) qs.set("ep.ping_secret", PING_SECRET);
      ctx.waitUntil(
        fetch(SGTM_URL + "/g/collect?" + qs.toString(), { method: "POST" }).catch(() => {})
      );
    }
    return fetch(request);
  },
};
