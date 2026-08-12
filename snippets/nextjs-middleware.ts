// AI Crawler Analytics: crawler forward for Next.js middleware.
// Add to middleware.ts (or merge into your existing middleware). Forwards AI
// crawler page requests to your server-side GTM container as ai_crawler_ping
// events without delaying the response.
//
// Set SGTM_URL, GA4_MEASUREMENT_ID (same ID as on the tag), and optionally
// PING_SECRET (must match the tag's Ping secret).
//
// The ping uses the GA4 g/collect wire format because that is what the
// GA4 client pre-installed in every server container claims. A JSON POST
// to /mp/collect is NOT claimed by a default container (tested on a live
// tagging server, 2026-08-12) and would be silently dropped.

import { NextResponse } from "next/server";
import type { NextRequest, NextFetchEvent } from "next/server";

const SGTM_URL = "https://sgtm.example.com"; // your server GTM container URL
const GA4_MEASUREMENT_ID = "G-XXXXXXXXXX"; // same ID as on the tag
const PING_SECRET = ""; // must match the tag's Ping secret, or leave empty

// Fast prefilter only; the tag's registry is authoritative. Send the FULL
// user agent: some tokens appear after character 100 of the real UA.
const AI_CRAWLER_RE =
  /(gptbot|oai-searchbot|oai-adsbot|chatgpt-user|claudebot|claude-searchbot|claude-user|perplexitybot|perplexity-user|mistralai-user|duckassistbot|applebot|amazonbot|bytespider|meta-externalagent|meta-externalfetcher|meta-webindexer|ccbot\/|cohere-ai|cohere-training-data-crawler|google-agent)/i;

export function middleware(request: NextRequest, event: NextFetchEvent) {
  const ua = request.headers.get("user-agent") || "";
  const match = ua.match(AI_CRAWLER_RE);
  if (match) {
    const qs = new URLSearchParams({
      v: "2",
      tid: GA4_MEASUREMENT_ID,
      cid: "aic." + match[1].toLowerCase().replace("/", ""),
      en: "ai_crawler_ping",
      "ep.bot_ua": ua, // full UA, never truncated here
      dl: request.nextUrl.href,
    });
    if (PING_SECRET) qs.set("ep.ping_secret", PING_SECRET);
    event.waitUntil(
      fetch(SGTM_URL + "/g/collect?" + qs.toString(), { method: "POST" }).catch(() => {})
    );
  }
  return NextResponse.next();
}

export const config = {
  // Pages only: skip Next internals and static assets.
  matcher: ["/((?!_next/|api/|.*\\.(?:ico|png|jpg|jpeg|gif|svg|css|js|txt|xml|webmanifest)).*)"],
};
