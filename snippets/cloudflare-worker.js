// AI Crawler Analytics: crawler forward for Cloudflare Workers.
// Forwards AI crawler page requests to your server-side GTM container as
// ai_crawler_ping events. Fire-and-forget: it never delays or alters the
// response served to the crawler.
//
// 1. Set SGTM_URL to your server container URL (no trailing slash).
// 2. If you set a Ping secret on the tag, set PING_SECRET to the same value.
// 3. Deploy as a Worker route covering your site, or merge the waitUntil
//    block into your existing Worker.

const SGTM_URL = "https://sgtm.example.com"; // your server GTM container URL
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
      const params = {
        bot_ua: ua, // full UA, never truncated here
        page_location: request.url,
      };
      if (PING_SECRET) params.ping_secret = PING_SECRET;
      const body = JSON.stringify({
        client_id: "aic." + match[1].toLowerCase().replace("/", ""),
        events: [{ name: "ai_crawler_ping", params: params }],
      });
      ctx.waitUntil(
        fetch(SGTM_URL + "/mp/collect", {
          method: "POST",
          headers: { "content-type": "application/json" },
          body,
        }).catch(() => {})
      );
    }
    return fetch(request);
  },
};
