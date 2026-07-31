// Executes the REAL sandboxed JS from template.tpl in Node with shimmed GTM
// server APIs, then runs every scenario from the .tpl ___TESTS___ suite plus
// extra edge cases. This is not a mirror of the logic; it extracts and runs
// the exact code that ships, so a green run here means the shipping artifact's
// logic is sound. The GTM editor's own test runner (build gate 2) remains the
// authority on sandbox API semantics.
//
// Run: node test/run-tests.mjs
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const tpl = readFileSync(join(root, "template.tpl"), "utf8");

// ---- extract the real sandboxed code between its sentinel and the next one
const start = tpl.indexOf("___SANDBOXED_JS_FOR_SERVER___");
const end = tpl.indexOf("___SERVER_PERMISSIONS___");
if (start < 0 || end < 0) throw new Error("sentinels not found");
const code = tpl.slice(start + "___SANDBOXED_JS_FOR_SERVER___".length, end);

// ---- sandbox API shims (semantics per developers.google.com server APIs)
function makeShims(ctx) {
  const parseUrl = (u) => {
    try {
      const p = new URL(String(u));
      const sp = {};
      p.searchParams.forEach((v, k) => {
        if (sp[k] === undefined) sp[k] = v;
        else if (Array.isArray(sp[k])) sp[k].push(v);
        else sp[k] = [sp[k], v];
      });
      return { hostname: p.hostname, pathname: p.pathname, searchParams: sp };
    } catch {
      return undefined;
    }
  };
  const apis = {
    getEventData: (k) => ctx.eventData[k],
    getRequestHeader: (n) => ctx.headers[n],
    sendHttpRequest: (url, options) => {
      ctx.sentHttp.push(url);
      const q = url.slice(url.indexOf("?") + 1).split("&");
      const o = {};
      for (const kv of q) {
        const j = kv.indexOf("=");
        o[decodeURIComponent(kv.slice(0, j))] = decodeURIComponent(kv.slice(j + 1));
      }
      ctx.sentGA.push(o); // parsed params, keeps the assert style below
      return { then: (ok, err) => (ctx.httpShouldFail ? err("fail") : ok({ statusCode: ctx.httpStatus ?? 200 })) };
    },
    logToConsole: (...a) => ctx.logs.push(a.join(" ")),
    makeString: (v) => String(v),
    getType: (v) => (Array.isArray(v) ? "array" : v === null ? "null" : typeof v),
    parseUrl,
    computeEffectiveTldPlusOne: ctx.mockTld
      ? ctx.mockTld
      : (u) => {
          const p = parseUrl(u);
          if (!p || !p.hostname) return "";
          const parts = p.hostname.split(".");
          return parts.slice(-2).join(".");
        },
    encodeUriComponent: encodeURIComponent,
  };
  return (name) => {
    if (!(name in apis)) throw new Error("template required un-shimmed API: " + name);
    return apis[name];
  };
}

function runTemplate(data, ctx) {
  let success = 0, failure = 0;
  const fullData = {
    ...data,
    gtmOnSuccess: () => success++,
    gtmOnFailure: () => failure++,
  };
  const fn = new Function("require", "data", code);
  fn(makeShims(ctx), fullData);
  return { success, failure };
}

const baseData = () => ({
  measurementId: "G-TEST12345",
  enableCrawlerDetection: true,
  enableAgentDetection: true,
  enableReferralDetection: true,
  extraBots: [],
  excludeTokens: "",
  pingSecret: "",
  logMode: "no",
});
const baseCtx = () => ({ eventData: {}, headers: {}, sentGA: [], sentHttp: [], logs: [], gaShouldFail: false, httpShouldFail: false });

const GPTBOT_UA = "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko); compatible; GPTBot/1.2; +https://openai.com/gptbot";
const OAI_SEARCHBOT_UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36; compatible; OAI-SearchBot/1.0; +https://openai.com/searchbot";
const CHROME_UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36";

let pass = 0, fail = 0;
const failures = [];
function t(name, fn) {
  try {
    fn();
    pass++;
    console.log("  ok  " + name);
  } catch (e) {
    fail++;
    failures.push(name + ": " + e.message);
    console.log("FAIL  " + name + "  ->  " + e.message);
  }
}
function eq(a, b, what) {
  if (a !== b) throw new Error(`${what ?? "value"}: expected ${JSON.stringify(b)}, got ${JSON.stringify(a)}`);
}

// ---- the .tpl scenario suite, executed against the real code -------------

t("ping classification: full GPTBot mapping", () => {
  const ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "aic.gptbot", bot_ua: GPTBOT_UA, page_location: "https://example.com/pricing" };
  const r = runTemplate(baseData(), ctx);
  eq(r.success, 1, "gtmOnSuccess"); eq(r.failure, 0, "gtmOnFailure");
  eq(ctx.sentGA.length, 1, "sends");
  const e = ctx.sentGA[0];
  eq(e.en, "ai_crawler_visit"); eq(e["ep.ai_type"], "crawler"); eq(e["ep.ai_source"], "GPTBot");
  eq(e["ep.ai_operator"], "OpenAI"); eq(e["ep.ai_category"], "training"); eq(e["ep.detection_method"], "ua_match");
  eq(e.cid, "aic.gptbot"); eq(e.tid, "G-TEST12345");
});

t("late token: OAI-SearchBot past char 100 matches; bot_ua trunc 100", () => {
  if (OAI_SEARCHBOT_UA.toLowerCase().indexOf("oai-searchbot") <= 100) throw new Error("test UA no longer has token past 100");
  const ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: OAI_SEARCHBOT_UA, page_location: "https://example.com/" };
  runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 1, "sends");
  eq(ctx.sentGA[0]["ep.ai_source"], "OAI-SearchBot"); eq(ctx.sentGA[0]["ep.ai_category"], "search");
  eq(ctx.sentGA[0]["ep.bot_ua"].length, 100, "bot_ua length");
});

t("browser-masquerade UA wins over referral (tier precedence)", () => {
  const ctx = baseCtx();
  ctx.eventData = { event_name: "page_view", client_id: "c", user_agent: OAI_SEARCHBOT_UA, page_location: "https://example.com/", page_referrer: "https://chatgpt.com/" };
  runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 1); eq(ctx.sentGA[0]["ep.ai_type"], "crawler"); eq(ctx.sentGA[0]["ep.ai_source"], "OAI-SearchBot");
});

t("Anthropic disambiguation: three tokens, three sources", () => {
  const cases = [
    ["Claude-SearchBot/1.0", "Claude-SearchBot", "search"],
    ["ClaudeBot/1.0", "ClaudeBot", "training"],
    ["Claude-User/1.0", "Claude-User", "user_initiated"],
  ];
  for (const [uaBit, src, cat] of cases) {
    const ctx = baseCtx();
    ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: "Mozilla/5.0; compatible; " + uaBit };
    runTemplate(baseData(), ctx);
    eq(ctx.sentGA.length, 1, uaBit); eq(ctx.sentGA[0]["ep.ai_source"], src, uaBit); eq(ctx.sentGA[0]["ep.ai_category"], cat, uaBit);
  }
});

t("bare partial tokens never match", () => {
  const ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: "my searchbot chatgpt claude adsbot meta cohere tool" };
  const r = runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 0, "sends"); eq(r.success, 1);
});

t("CCBot slash rule", () => {
  let ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: "CCBot/2.0 (https://commoncrawl.org/faq/)" };
  runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 1); eq(ctx.sentGA[0]["ep.ai_source"], "CCBot");
  ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: "the ccbot fan page scraper" };
  runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 0, "no-slash must not match");
});

t("Applebot via event user_agent (default mode)", () => {
  const ctx = baseCtx();
  ctx.eventData = { event_name: "page_view", client_id: "c", user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko; compatible; Applebot/0.1; +http://www.apple.com/go/applebot)", page_location: "https://example.com/" };
  runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 1); eq(ctx.sentGA[0]["ep.ai_source"], "Applebot"); eq(ctx.sentGA[0]["ep.ai_category"], "search");
});

t("Google-Agent -> agent event", () => {
  const ctx = baseCtx();
  ctx.eventData = { event_name: "page_view", client_id: "c", user_agent: "Mozilla/5.0; compatible; Google-Agent/1.0", page_location: "https://example.com/" };
  runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 1); eq(ctx.sentGA[0].en, "ai_agent_visit"); eq(ctx.sentGA[0]["ep.ai_type"], "agent"); eq(ctx.sentGA[0]["ep.ai_category"], "agentic");
});

t("Signature-Agent tier on plain Chrome UA", () => {
  const ctx = baseCtx();
  ctx.eventData = { event_name: "page_view", client_id: "c", user_agent: CHROME_UA, page_location: "https://example.com/" };
  ctx.headers = { "signature-agent": "https://chatgpt.com" };
  runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 1); eq(ctx.sentGA[0]["ep.ai_source"], "chatgpt-agent"); eq(ctx.sentGA[0]["ep.detection_method"], "signature_agent");
});

t("referral via referrer: organic chatgpt", () => {
  const ctx = baseCtx();
  ctx.eventData = { event_name: "page_view", client_id: "c", user_agent: CHROME_UA, page_location: "https://www.example.com/blog", page_referrer: "https://chatgpt.com/" };
  runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 1);
  const e = ctx.sentGA[0];
  eq(e.en, "ai_referral_visit"); eq(e["ep.ai_source"], "chatgpt"); eq(e["ep.ai_medium"], "organic"); eq(e["ep.detection_method"], "referrer");
});

t("referral via UTM with stripped referrer", () => {
  const ctx = baseCtx();
  ctx.eventData = { event_name: "page_view", client_id: "c", user_agent: CHROME_UA, page_location: "https://www.example.com/?utm_source=chatgpt.com" };
  runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 1); eq(ctx.sentGA[0]["ep.ai_source"], "chatgpt"); eq(ctx.sentGA[0]["ep.detection_method"], "utm");
});

t("paid AI click: utm_source=chatgpt + utm_medium=cpc", () => {
  const ctx = baseCtx();
  ctx.eventData = { event_name: "page_view", client_id: "c", user_agent: CHROME_UA, page_location: "https://www.example.com/?utm_source=chatgpt&utm_medium=cpc" };
  runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 1); eq(ctx.sentGA[0]["ep.ai_medium"], "paid");
});

t("same-site referrer discarded (mocked eTLD+1)", () => {
  const ctx = baseCtx();
  ctx.mockTld = () => "example.com";
  ctx.eventData = { event_name: "page_view", client_id: "c", user_agent: CHROME_UA, page_location: "https://www.example.com/a", page_referrer: "https://blog.example.com/b" };
  const r = runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 0); eq(r.success, 1);
});

t("plain human traffic: no-op, no HTTP", () => {
  const ctx = baseCtx();
  ctx.eventData = { event_name: "page_view", client_id: "c", user_agent: CHROME_UA, page_location: "https://www.example.com/" };
  const r = runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 0); eq(ctx.sentHttp.length, 0); eq(r.success, 1);
});

t("referral gated to page_view", () => {
  const ctx = baseCtx();
  ctx.eventData = { event_name: "scroll", client_id: "c", user_agent: CHROME_UA, page_location: "https://www.example.com/", page_referrer: "https://chatgpt.com/" };
  const r = runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 0); eq(r.success, 1);
});

t("loop guard: three output names all no-op", () => {
  for (const name of ["ai_crawler_visit", "ai_agent_visit", "ai_referral_visit"]) {
    const ctx = baseCtx();
    ctx.eventData = { event_name: name, client_id: "c" };
    const r = runTemplate(baseData(), ctx);
    eq(ctx.sentGA.length, 0, name); eq(ctx.sentHttp.length, 0, name); eq(r.success, 1, name);
  }
});

t("pingSecret: missing/wrong dropped, matching processed", () => {
  const data = { ...baseData(), pingSecret: "s3cret" };
  let ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: GPTBOT_UA };
  runTemplate(data, ctx); eq(ctx.sentGA.length, 0, "missing secret");
  ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: GPTBOT_UA, ping_secret: "wrong" };
  runTemplate(data, ctx); eq(ctx.sentGA.length, 0, "wrong secret");
  ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: GPTBOT_UA, ping_secret: "s3cret" };
  runTemplate(data, ctx); eq(ctx.sentGA.length, 1, "matching secret"); eq(ctx.sentGA[0]["ep.ai_source"], "GPTBot");
});

t("extraBots row matches with its own labels", () => {
  const data = { ...baseData(), extraBots: [{ uaSubstring: "novel-bot-9000", displayName: "NovelBot", operator: "NovelCorp", category: "search" }] };
  const ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: "Mozilla/5.0; compatible; Novel-Bot-9000/1.0" };
  runTemplate(data, ctx);
  eq(ctx.sentGA.length, 1); eq(ctx.sentGA[0]["ep.ai_source"], "NovelBot"); eq(ctx.sentGA[0]["ep.ai_operator"], "NovelCorp"); eq(ctx.sentGA[0]["ep.ai_category"], "search");
});

t("excludeTokens disables a built-in", () => {
  const data = { ...baseData(), excludeTokens: "gptbot" };
  const ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: GPTBOT_UA };
  runTemplate(data, ctx);
  eq(ctx.sentGA.length, 0);
});

t("detection toggles isolate their tiers", () => {
  let data = { ...baseData(), enableCrawlerDetection: false };
  let ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: GPTBOT_UA };
  runTemplate(data, ctx); eq(ctx.sentGA.length, 0, "crawler off");
  data = { ...baseData(), enableAgentDetection: false };
  ctx = baseCtx();
  ctx.eventData = { event_name: "page_view", client_id: "c", user_agent: CHROME_UA, page_location: "https://example.com/" };
  ctx.headers = { "signature-agent": "https://chatgpt.com" };
  runTemplate(data, ctx); eq(ctx.sentGA.length, 0, "agent off");
  data = { ...baseData(), enableReferralDetection: false };
  ctx = baseCtx();
  ctx.eventData = { event_name: "page_view", client_id: "c", user_agent: CHROME_UA, page_location: "https://example.com/", page_referrer: "https://chatgpt.com/" };
  runTemplate(data, ctx); eq(ctx.sentGA.length, 0, "referral off");
});

t("truncation: long query trims page_location, path param survives intact", () => {
  let longQuery = "utm_content=abcdefghij";
  for (let i = 0; i < 4; i++) longQuery += "&" + longQuery;
  const ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: GPTBOT_UA, page_location: "https://example.com/pricing/enterprise?" + longQuery };
  runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 1);
  eq(ctx.sentGA[0].dl.length, 100, "page_location");
  eq(ctx.sentGA[0]["ep.page_hostname"], "example.com");
  eq(ctx.sentGA[0]["ep.page_path"], "/pricing/enterprise", "page_path intact");
});

t("pathological path still capped at GA4 param limit", () => {
  let longPath = "/segment";
  for (let i = 0; i < 6; i++) longPath += longPath;
  const ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: GPTBOT_UA, page_location: "https://example.com" + longPath };
  runTemplate(baseData(), ctx);
  eq(ctx.sentGA[0]["ep.page_path"].length, 100, "page_path capped");
});

t("send goes to g/collect with correct wire params", () => {
  const ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "aic.gptbot", bot_ua: GPTBOT_UA, page_location: "https://example.com/" };
  const r = runTemplate(baseData(), ctx);
  eq(r.success, 1); eq(r.failure, 0);
  eq(ctx.sentHttp.length, 1);
  if (!ctx.sentHttp[0].startsWith("https://www.google-analytics.com/g/collect?v=2")) throw new Error("wire URL wrong: " + ctx.sentHttp[0].slice(0, 60));
});

t("rejected send -> gtmOnFailure", () => {
  const ctx = baseCtx();
  ctx.httpShouldFail = true;
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: GPTBOT_UA };
  const r = runTemplate(baseData(), ctx);
  eq(r.failure, 1); eq(r.success, 0);
});

t("non-2xx response -> gtmOnFailure", () => {
  const ctx = baseCtx();
  ctx.httpStatus = 500;
  ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: GPTBOT_UA };
  const r = runTemplate(baseData(), ctx);
  eq(r.failure, 1);
});

t("SPOOF GUARD: bot_ua param on a page_view is ignored", () => {
  const ctx = baseCtx();
  ctx.eventData = { event_name: "page_view", client_id: "c", user_agent: CHROME_UA, bot_ua: GPTBOT_UA, page_location: "https://example.com/" };
  const r = runTemplate(baseData(), ctx);
  eq(ctx.sentGA.length, 0, "spoofed bot_ua must not classify"); eq(r.success, 1);
});

t("every registry row fires on a synthetic UA (21 rows)", () => {
  const m = code.match(/const REGISTRY = \[([\s\S]*?)\];/);
  const rows = [...m[1].matchAll(/\['([^']+)', '([^']+)', '([^']+)', '([^']+)'\]/g)];
  eq(rows.length, 21, "registry size");
  for (const [, token, name] of rows) {
    const ctx = baseCtx();
    ctx.eventData = { event_name: "ai_crawler_ping", client_id: "c", bot_ua: "Prefix/1.0 " + token + " suffix" };
    runTemplate(baseData(), ctx);
    eq(ctx.sentGA.length, 1, token);
    eq(ctx.sentGA[0]["ep.ai_source"], name, token);
  }
});

t("all 13 referral hosts classify with expected slugs", () => {
  const hosts = [
    ["chatgpt.com", "chatgpt"], ["chat.openai.com", "chatgpt"], ["perplexity.ai", "perplexity"],
    ["claude.ai", "claude"], ["gemini.google.com", "gemini"], ["bard.google.com", "gemini"],
    ["copilot.microsoft.com", "copilot"], ["meta.ai", "meta_ai"], ["chat.mistral.ai", "le_chat"],
    ["grok.com", "grok"], ["chat.deepseek.com", "deepseek"],
    ["you.com", "you"], ["poe.com", "poe"],
  ];
  for (const [host, slug] of hosts) {
    const ctx = baseCtx();
    ctx.eventData = { event_name: "page_view", client_id: "c", user_agent: CHROME_UA, page_location: "https://www.example.com/", page_referrer: "https://" + host + "/x" };
    runTemplate(baseData(), ctx);
    eq(ctx.sentGA.length, 1, host);
    eq(ctx.sentGA[0]["ep.ai_source"], slug, host);
  }
});

t("hostile referrer suffixes do not match (notchatgpt.com, chatgpt.com.evil.io)", () => {
  for (const host of ["notchatgpt.com", "chatgpt.com.evil.io", "xchatgpt.com"]) {
    const ctx = baseCtx();
    ctx.eventData = { event_name: "page_view", client_id: "c", user_agent: CHROME_UA, page_location: "https://www.example.com/", page_referrer: "https://" + host + "/" };
    runTemplate(baseData(), ctx);
    eq(ctx.sentGA.length, 0, host);
  }
});

t("missing client_id synthesizes aic.unknown", () => {
  const ctx = baseCtx();
  ctx.eventData = { event_name: "ai_crawler_ping", bot_ua: GPTBOT_UA };
  runTemplate(baseData(), ctx);
  eq(ctx.sentGA[0].cid, "aic.unknown");
});

console.log(`\n${pass} passed, ${fail} failed`);
if (fail) {
  console.log("\nFailures:\n" + failures.map((f) => "  - " + f).join("\n"));
  process.exit(1);
}
