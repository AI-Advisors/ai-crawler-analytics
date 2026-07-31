// AI Crawler Analytics: crawler forward for Next.js middleware.
// Add to middleware.ts (or merge into your existing middleware). Forwards AI
// crawler page requests to your server-side GTM container as ai_crawler_ping
// events without delaying the response.

import { NextResponse } from "next/server";
import type { NextRequest, NextFetchEvent } from "next/server";

const SGTM_URL = "https://sgtm.example.com"; // your server GTM container URL
const PING_SECRET = ""; // must match the tag's Ping secret, or leave empty

// Fast prefilter only; the tag's registry is authoritative. Send the FULL
// user agent: some tokens appear after character 100 of the real UA.
const AI_CRAWLER_RE =
  /(gptbot|oai-searchbot|oai-adsbot|chatgpt-user|claudebot|claude-searchbot|claude-user|perplexitybot|perplexity-user|mistralai-user|duckassistbot|applebot|amazonbot|bytespider|meta-externalagent|meta-externalfetcher|meta-webindexer|ccbot\/|cohere-ai|cohere-training-data-crawler|google-agent)/i;

export function middleware(request: NextRequest, event: NextFetchEvent) {
  const ua = request.headers.get("user-agent") || "";
  const match = ua.match(AI_CRAWLER_RE);
  if (match) {
    const params: Record<string, string> = {
      bot_ua: ua,
      page_location: request.nextUrl.href,
    };
    if (PING_SECRET) params.ping_secret = PING_SECRET;
    event.waitUntil(
      fetch(SGTM_URL + "/mp/collect", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          client_id: "aic." + match[1].toLowerCase().replace("/", ""),
          events: [{ name: "ai_crawler_ping", params }],
        }),
      }).catch(() => {})
    );
  }
  return NextResponse.next();
}

export const config = {
  // Pages only: skip Next internals and static assets.
  matcher: ["/((?!_next/|api/|.*\\.(?:ico|png|jpg|jpeg|gif|svg|css|js|txt|xml|webmanifest)).*)"],
};
