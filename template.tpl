___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "AI Crawler Analytics by AI-Advisors",
  "categories": ["ANALYTICS", "UTILITY"],
  "brand": {
    "id": "brand_dummy",
    "displayName": "AI-Advisors",
    "thumbnail": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAADimHc4AAAB4klEQVR42u3dwU3cMRDF4XdFdEANNABSakgZOaQebpSTa2oCLRISinJAoNX42d/haa+r+dlvPP7b49zc3L7QnCIIAABAAABAAABAAADQpPvfvwCY1M+/fwCY0t3jwxuAyy8AQ/ZzAdBuQ7UAfjw/vQG4/AIwZD/varahNNvPu5ptKK2rn38FwNDob58F2WH0N8+C7DD6m2dBdhn9rbMgu4z+1lmQnUZ/4yxIU9X7WTVVx2mrej+rluo4O1lPoxVlJ+tptKK0r3raV0XZyfcb80F2D/7qELKb77flg5wQ/JUh5JTgrwohJwV/RQg5LfirQciJwV8JQqaWmtPB/whhcomaXdb5rXVCGrcXrqWJbYuc4ver5oWcajmrWFKM+tnZkBO9fqXcEIGfBRGBnwWR7yTX0wL/PxDfTdb5StDbk+s1kvVXYYTFzFqUGdAwA+SARXIAi1poFaQOUAmrhO0F2Q21G+p7gC9ivoj5JuxUhFMRzgU5GedknLOhTkc7He1+gBsybsi4I+aWpFuS7gm7Ke+mvF4RuqUAoF+QjlkA6BmnayIA+obqnAuA3tG6pwNwjVng/YDh6tgLGoPVsTdkhm3IK0rDNuQdseHVUPP/rwfgLUkCAAACAAACAAACAAACoE2vRvrpqG2e+AQAAAAASUVORK5CYII="
  },
  "description": "See which AI crawlers and assistants visit your site, inside your own GA4. Classifies OpenAI, Anthropic, Perplexity, Meta, Apple and more into search, user-initiated, ads and training visits, plus AI referral and agent traffic. AI referral and agent traffic works with no code changes; full crawler visibility uses a small server-side forward snippet included in the repo. Your data goes only to your GA4 property.",
  "containerContexts": ["SERVER"]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "measurementId",
    "displayName": "GA4 Measurement ID",
    "simpleValueType": true,
    "valueHint": "G-XXXXXXXXXX",
    "help": "Events are sent only to this property. Use a dedicated property if you want crawler data separated from your main analytics.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "detectionGroup",
    "displayName": "Detection",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "enableCrawlerDetection",
        "checkboxText": "Detect AI crawlers (user agent registry)",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "Matches the user agent of incoming events, including forwarded crawler pings, against a built-in registry of documented AI crawler tokens."
      },
      {
        "type": "CHECKBOX",
        "name": "enableAgentDetection",
        "checkboxText": "Detect AI agents (Signature-Agent header)",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "Detects agentic browsing that identifies itself with a Signature-Agent request header. Safe to leave on: it does nothing when the header is absent."
      },
      {
        "type": "CHECKBOX",
        "name": "enableReferralDetection",
        "checkboxText": "Detect AI referral traffic (UTM and referrer)",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "Classifies human visits that arrive from AI assistants, using utm_source first (it survives referrer stripping), then OpenAI's oppref click identifier (present only on paid ChatGPT Ads clicks), then the referrer hostname. Applies to page_view events only."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "registryGroup",
    "displayName": "Crawler registry",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "extraBots",
        "displayName": "Additional bots",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "UA substring (lowercase)",
            "name": "uaSubstring",
            "isUnique": true,
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "Display name",
            "name": "displayName",
            "isUnique": false,
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "Operator",
            "name": "operator",
            "isUnique": false,
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "Category",
            "name": "category",
            "isUnique": false,
            "type": "TEXT"
          }
        ],
        "help": "Your own additions, matched after the built-in registry. Use a lowercase user agent substring that is specific enough not to match normal browsers."
      },
      {
        "type": "TEXT",
        "name": "excludeTokens",
        "displayName": "Disable built-in tokens",
        "simpleValueType": true,
        "help": "Comma-separated built-in tokens to disable, for example: ccbot/, bytespider"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "advancedGroup",
    "displayName": "Advanced",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "TEXT",
        "name": "pingSecret",
        "displayName": "Ping secret",
        "simpleValueType": true,
        "help": "Optional. When set, incoming ai_crawler_ping events must carry a matching ping_secret parameter or they are silently dropped. Set the same value in your crawler forward snippet."
      },
      {
        "type": "SELECT",
        "name": "logMode",
        "displayName": "Logging",
        "macrosInSelect": false,
        "selectItems": [
          {
            "value": "debug",
            "displayValue": "Classifications only (preview and debug)"
          },
          {
            "value": "always",
            "displayValue": "Verbose (also log skipped events)"
          },
          {
            "value": "no",
            "displayValue": "No logging"
          }
        ],
        "simpleValueType": true,
        "defaultValue": "debug",
        "help": "Logs appear in Tag Manager preview and debug mode only. Verbose additionally logs events that were examined and skipped."
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

// AI Crawler Analytics by AI-Advisors
// Classifies AI crawler, AI agent, and AI referral activity into dedicated
// GA4 events (ai_crawler_visit, ai_agent_visit, ai_referral_visit).
// Data goes only to the GA4 property configured on this tag. Nothing is ever
// sent to AI-Advisors.
const getEventData = require('getEventData');
const getRequestHeader = require('getRequestHeader');
const sendHttpRequest = require('sendHttpRequest');
const logToConsole = require('logToConsole');
const makeString = require('makeString');
const getType = require('getType');
const parseUrl = require('parseUrl');
const computeEffectiveTldPlusOne = require('computeEffectiveTldPlusOne');
const encodeUriComponent = require('encodeUriComponent');

const MID = makeString(data.measurementId || '');
const LOG_MODE = data.logMode || 'debug';

function log(verboseOnly, msg) {
  if (LOG_MODE === 'no') return;
  if (verboseOnly && LOG_MODE !== 'always') return;
  logToConsole('[AI Crawler Analytics] ' + msg);
}

// ---------------------------------------------------------------------------
// Tier 0: guards
// ---------------------------------------------------------------------------
const eventName = makeString(getEventData('event_name') || '');

// Loop guard: never re-process our own output events.
if (eventName === 'ai_crawler_visit' || eventName === 'ai_agent_visit' || eventName === 'ai_referral_visit') {
  log(true, 'Loop guard: skipping own output event ' + eventName);
  data.gtmOnSuccess();
  return;
}

const isPing = eventName === 'ai_crawler_ping';

// Ping spoof mitigation: when a secret is configured, unauthenticated pings
// are silently dropped.
if (isPing && data.pingSecret) {
  const suppliedSecret = makeString(getEventData('ping_secret') || '');
  if (suppliedSecret !== makeString(data.pingSecret)) {
    log(true, 'Dropped ai_crawler_ping: ping_secret missing or mismatched');
    data.gtmOnSuccess();
    return;
  }
}

// ---------------------------------------------------------------------------
// User agent source chain: ping payload, then event data, then request header.
// Matching ALWAYS runs against the full string; truncation happens only on
// output. (OAI-SearchBot's token sits past character 100 of its real UA.)
// ---------------------------------------------------------------------------
// bot_ua is honored ONLY on ai_crawler_ping events, so the ping secret
// actually guards the forged-param path rather than only the event name.
const uaRaw = makeString((isPing ? getEventData('bot_ua') : '') || getEventData('user_agent') || getRequestHeader('user-agent') || '');
const ua = uaRaw.toLowerCase();

// ---------------------------------------------------------------------------
// Built-in registry: 21 matchers, ordered so that longer, more specific
// tokens match before shorter ones. First match wins.
// Format: [uaSubstring, canonicalName, operator, category]
// Never add bare tokens like "searchbot", "chatgpt", "claude", "adsbot",
// "meta", or "cohere": they false-positive on unrelated strings.
// Deliberate exclusions (documented in the README): Google-Extended and
// Applebot-Extended are robots.txt-only tokens that never appear in a
// User-Agent header; Grok/xAI and DeepSeek have no vendor-documented UA;
// Microsoft Copilot rides Bingbot and is not separable.
// ---------------------------------------------------------------------------
const REGISTRY = [
  ['cohere-training-data-crawler', 'Cohere-Training-Data-Crawler', 'Cohere', 'training'],
  ['meta-externalfetcher', 'Meta-ExternalFetcher', 'Meta', 'user_initiated'],
  ['meta-externalagent', 'Meta-ExternalAgent', 'Meta', 'training'],
  ['claude-searchbot', 'Claude-SearchBot', 'Anthropic', 'search'],
  ['meta-webindexer', 'Meta-WebIndexer', 'Meta', 'search'],
  ['oai-searchbot', 'OAI-SearchBot', 'OpenAI', 'search'],
  ['perplexity-user', 'Perplexity-User', 'Perplexity', 'user_initiated'],
  ['duckassistbot', 'DuckAssistBot', 'DuckDuckGo', 'search'],
  ['perplexitybot', 'PerplexityBot', 'Perplexity', 'search'],
  ['mistralai-user', 'MistralAI-User', 'Mistral', 'user_initiated'],
  ['chatgpt-user', 'ChatGPT-User', 'OpenAI', 'user_initiated'],
  ['google-agent', 'Google-Agent', 'Google', 'agentic'],
  ['claude-user', 'Claude-User', 'Anthropic', 'user_initiated'],
  ['oai-adsbot', 'OAI-AdsBot', 'OpenAI', 'ads'],
  ['cohere-ai', 'Cohere-AI', 'Cohere', 'training'],
  ['claudebot', 'ClaudeBot', 'Anthropic', 'training'],
  ['bytespider', 'Bytespider', 'ByteDance', 'training'],
  ['amazonbot', 'Amazonbot', 'Amazon', 'training'],
  ['applebot', 'Applebot', 'Apple', 'search'],
  ['gptbot', 'GPTBot', 'OpenAI', 'training'],
  ['ccbot/', 'CCBot', 'Common Crawl', 'training']
];

const excluded = {};
if (data.excludeTokens) {
  const tokens = makeString(data.excludeTokens).toLowerCase().split(',');
  for (let e = 0; e < tokens.length; e++) {
    const tok = tokens[e].trim();
    if (tok) excluded[tok] = true;
  }
}

function matchRegistry() {
  if (!ua) return null;
  for (let i = 0; i < REGISTRY.length; i++) {
    const token = REGISTRY[i][0];
    if (excluded[token]) continue;
    if (ua.indexOf(token) !== -1) {
      return { token: token, source: REGISTRY[i][1], operator: REGISTRY[i][2], category: REGISTRY[i][3] };
    }
  }
  if (getType(data.extraBots) === 'array') {
    for (let j = 0; j < data.extraBots.length; j++) {
      const row = data.extraBots[j];
      const sub = makeString(row.uaSubstring || '').toLowerCase();
      if (sub && ua.indexOf(sub) !== -1) {
        return {
          token: sub,
          source: makeString(row.displayName || sub),
          operator: makeString(row.operator || 'Custom'),
          category: makeString(row.category || 'custom')
        };
      }
    }
  }
  return null;
}

function firstString(value) {
  if (getType(value) === 'array') return makeString(value[0] || '');
  return makeString(value || '');
}

function endsWith(str, suffix) {
  if (str === suffix) return true;
  const idx = str.indexOf('.' + suffix);
  return idx !== -1 && idx === str.length - suffix.length - 1;
}

// ---------------------------------------------------------------------------
// Classification. Precedence: crawler UA > Signature-Agent header > referral.
// ---------------------------------------------------------------------------
let result = null;

// Tier 1: user agent registry.
if (data.enableCrawlerDetection) {
  const m = matchRegistry();
  if (m) {
    const isAgent = m.token === 'google-agent';
    result = {
      outName: isAgent ? 'ai_agent_visit' : 'ai_crawler_visit',
      aiType: isAgent ? 'agent' : 'crawler',
      aiSource: m.source,
      aiOperator: m.operator,
      aiCategory: m.category,
      aiMedium: '',
      detectionMethod: 'ua_match',
      includeUa: true
    };
  }
}

// Tier 2: Signature-Agent header (agentic browsing that identifies itself).
if (!result && data.enableAgentDetection) {
  const sig = makeString(getRequestHeader('signature-agent') || '').toLowerCase();
  if (sig.indexOf('chatgpt.com') !== -1) {
    result = {
      outName: 'ai_agent_visit',
      aiType: 'agent',
      aiSource: 'chatgpt-agent',
      aiOperator: 'OpenAI',
      aiCategory: 'agentic',
      aiMedium: '',
      detectionMethod: 'signature_agent',
      includeUa: true
    };
  }
}

// Tier 3: AI referral traffic, page_view events only. UTM first because it
// survives referrer stripping; referrer hostname second.
const pageLocation = makeString(getEventData('page_location') || '');

if (!result && data.enableReferralDetection && eventName === 'page_view') {
  const UTM_MAP = {
    'chatgpt.com': ['chatgpt', 'OpenAI'],
    'chatgpt': ['chatgpt', 'OpenAI'],
    'openai': ['chatgpt', 'OpenAI'],
    'perplexity': ['perplexity', 'Perplexity'],
    'copilot': ['copilot', 'Microsoft'],
    'gemini': ['gemini', 'Google'],
    'claude': ['claude', 'Anthropic']
  };
  // Ordered host-suffix map. duckduckgo.com is deliberately excluded:
  // DuckAssist referrals are indistinguishable from ordinary DDG search.
  const REF_MAP = [
    ['chatgpt.com', 'chatgpt', 'OpenAI'],
    ['chat.openai.com', 'chatgpt', 'OpenAI'],
    ['perplexity.ai', 'perplexity', 'Perplexity'],
    ['claude.ai', 'claude', 'Anthropic'],
    ['gemini.google.com', 'gemini', 'Google'],
    ['bard.google.com', 'gemini', 'Google'],
    ['copilot.microsoft.com', 'copilot', 'Microsoft'],
    ['meta.ai', 'meta_ai', 'Meta'],
    ['chat.mistral.ai', 'le_chat', 'Mistral'],
    ['grok.com', 'grok', 'xAI'],
    ['chat.deepseek.com', 'deepseek', 'DeepSeek'],
    ['you.com', 'you', 'You.com'],
    ['poe.com', 'poe', 'Poe']
  ];

  let utmSource = '';
  let utmMedium = '';
  let oppref = '';
  if (pageLocation) {
    const pu = parseUrl(pageLocation);
    if (pu && pu.searchParams) {
      utmSource = firstString(pu.searchParams.utm_source).toLowerCase();
      utmMedium = firstString(pu.searchParams.utm_medium).toLowerCase();
      // oppref is OpenAI's click identifier, appended only to eligible
      // ChatGPT ad clicks. Opaque value; only its presence matters here.
      oppref = firstString(pu.searchParams.oppref);
    }
  }

  if (utmSource && UTM_MAP[utmSource]) {
    const paid = utmMedium === 'cpc' || utmMedium === 'ppc' || utmMedium.indexOf('paid') === 0;
    result = {
      outName: 'ai_referral_visit',
      aiType: 'referral',
      aiSource: UTM_MAP[utmSource][0],
      aiOperator: UTM_MAP[utmSource][1],
      aiCategory: 'referral',
      aiMedium: paid ? 'paid' : 'organic',
      detectionMethod: 'utm',
      includeUa: false
    };
  } else if (oppref) {
    // A paid ChatGPT Ads click that lands with a stripped referrer and no
    // UTMs is otherwise invisible; oppref survives both, and OpenAI appends
    // it only to ad clicks, so it is definitive paid evidence. Checked
    // after UTM (an explicit advertiser tag stays authoritative) and
    // before the referrer (a chatgpt.com referrer alone cannot separate
    // paid from organic; oppref can).
    result = {
      outName: 'ai_referral_visit',
      aiType: 'referral',
      aiSource: 'chatgpt',
      aiOperator: 'OpenAI',
      aiCategory: 'referral',
      aiMedium: 'paid',
      detectionMethod: 'oppref',
      includeUa: false
    };
  } else {
    const referrer = makeString(getEventData('page_referrer') || '');
    if (referrer) {
      let sameSite = false;
      if (pageLocation) {
        const ownTld = computeEffectiveTldPlusOne(pageLocation);
        const refTld = computeEffectiveTldPlusOne(referrer);
        if (ownTld && refTld && ownTld === refTld) sameSite = true;
      }
      if (!sameSite) {
        const ru = parseUrl(referrer);
        const host = ru ? makeString(ru.hostname || '').toLowerCase() : '';
        if (host) {
          for (let r = 0; r < REF_MAP.length; r++) {
            if (endsWith(host, REF_MAP[r][0])) {
              result = {
                outName: 'ai_referral_visit',
                aiType: 'referral',
                aiSource: REF_MAP[r][1],
                aiOperator: REF_MAP[r][2],
                aiCategory: 'referral',
                aiMedium: 'organic',
                detectionMethod: 'referrer',
                includeUa: false
              };
              break;
            }
          }
        }
      }
    }
  }
}

if (!result) {
  log(true, 'No AI activity detected on event ' + eventName);
  data.gtmOnSuccess();
  return;
}

// ---------------------------------------------------------------------------
// Build the output event. Values are truncated to GA4's 100-character param
// limit at OUTPUT time only. page_hostname and page_path are sent separately
// so truncating page_location never loses the path.
// ---------------------------------------------------------------------------
function trunc(value, max) {
  const s = makeString(value);
  return s.length > max ? s.substring(0, max) : s;
}

let pageHostname = '';
let pagePath = '';
if (pageLocation) {
  const lu = parseUrl(pageLocation);
  if (lu) {
    pageHostname = makeString(lu.hostname || '');
    pagePath = makeString(lu.pathname || '');
  }
}

const clientId = makeString(getEventData('client_id') || '') || 'aic.unknown';

// ---------------------------------------------------------------------------
// Send via the GA4 g/collect wire format, the same request every GA4 web
// client makes and the pattern used by gallery-listed server tags. No
// api_secret is ever collected. The outbound request's User-Agent header is
// NEVER set to a bot UA (GA4 known-bot filtering); bot identity travels in
// event params only.
// ---------------------------------------------------------------------------
let url = 'https://www.google-analytics.com/g/collect' +
  '?v=2' +
  '&tid=' + encodeUriComponent(MID) +
  '&cid=' + encodeUriComponent(clientId) +
  '&en=' + encodeUriComponent(result.outName);
if (pageLocation) url += '&dl=' + encodeUriComponent(trunc(pageLocation, 100));
url += '&ep.ai_type=' + encodeUriComponent(result.aiType) +
  '&ep.ai_source=' + encodeUriComponent(result.aiSource) +
  '&ep.ai_operator=' + encodeUriComponent(result.aiOperator) +
  '&ep.ai_category=' + encodeUriComponent(result.aiCategory) +
  '&ep.detection_method=' + encodeUriComponent(result.detectionMethod);
if (result.aiMedium) url += '&ep.ai_medium=' + encodeUriComponent(result.aiMedium);
if (result.includeUa && uaRaw) url += '&ep.bot_ua=' + encodeUriComponent(trunc(uaRaw, 100));
if (pageHostname) url += '&ep.page_hostname=' + encodeUriComponent(trunc(pageHostname, 100));
if (pagePath) url += '&ep.page_path=' + encodeUriComponent(trunc(pagePath, 100));

sendHttpRequest(url, { method: 'POST', timeout: 2000 }).then(function (response) {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    log(false, 'Sent ' + result.outName + ' (' + result.aiSource + ', ' + result.detectionMethod + ')');
    data.gtmOnSuccess();
  } else {
    log(false, 'Send failed with status ' + response.statusCode);
    data.gtmOnFailure();
  }
}, function () {
  log(false, 'Send failed');
  data.gtmOnFailure();
});


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "headersAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "headerWhitelist",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "user-agent"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "signature-agent"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://www.google-analytics.com/"
              },
              {
                "type": 1,
                "string": "https://region1.google-analytics.com/"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

setup: |-
  const decodeUriComponent = require('decodeUriComponent');
  const mockData = {
    measurementId: 'G-TEST12345',
    enableCrawlerDetection: true,
    enableAgentDetection: true,
    enableReferralDetection: true,
    extraBots: [],
    excludeTokens: '',
    pingSecret: '',
    logMode: 'no'
  };
  let eventData = { event_name: 'page_view', client_id: 'test.cid' };
  let headers = {};
  let sentHttp = [];
  let httpShouldFail = false;
  let httpStatus = 200;
  const GPTBOT_UA = 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko); compatible; GPTBot/1.2; +https://openai.com/gptbot';
  const OAI_SEARCHBOT_UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36; compatible; OAI-SearchBot/1.0; +https://openai.com/searchbot';
  const CHROME_UA = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36';
  const sentParams = (i) => {
    const url = sentHttp[i];
    const q = url.slice(url.indexOf('?') + 1).split('&');
    const o = {};
    for (let k = 0; k < q.length; k++) {
      const j = q[k].indexOf('=');
      o[decodeUriComponent(q[k].slice(0, j))] = decodeUriComponent(q[k].slice(j + 1));
    }
    return o;
  };
  mock('getEventData', (key) => eventData[key]);
  mock('getRequestHeader', (name) => headers[name]);
  mock('sendHttpRequest', (url, options) => {
    sentHttp.push(url);
    return { then: (ok, err) => { if (httpShouldFail) { err('http failed'); } else { ok({ statusCode: httpStatus }); } } };
  });
scenarios:
- name: Ping classification sends ai_crawler_visit with full GPTBot mapping
  code: |-
    eventData = { event_name: 'ai_crawler_ping', client_id: 'aic.gptbot', bot_ua: GPTBOT_UA, page_location: 'https://example.com/pricing' };
    runCode(mockData);
    callLater(() => {
      assertApi('gtmOnSuccess').wasCalled();
      assertApi('gtmOnFailure').wasNotCalled();
      assertThat(sentHttp).hasLength(1);
      const p = sentParams(0);
      assertThat(p.tid).isEqualTo('G-TEST12345');
      assertThat(p.cid).isEqualTo('aic.gptbot');
      assertThat(p.en).isEqualTo('ai_crawler_visit');
      assertThat(p['ep.ai_type']).isEqualTo('crawler');
      assertThat(p['ep.ai_source']).isEqualTo('GPTBot');
      assertThat(p['ep.ai_operator']).isEqualTo('OpenAI');
      assertThat(p['ep.ai_category']).isEqualTo('training');
      assertThat(p['ep.detection_method']).isEqualTo('ua_match');
    });
- name: Late token matching works and bot_ua is truncated to 100 on output
  code: |-
    eventData = { event_name: 'ai_crawler_ping', client_id: 'c', bot_ua: OAI_SEARCHBOT_UA, page_location: 'https://example.com/' };
    runCode(mockData);
    callLater(() => {
      assertThat(OAI_SEARCHBOT_UA.toLowerCase().indexOf('oai-searchbot')).isGreaterThan(100);
      assertThat(sentHttp).hasLength(1);
      const p = sentParams(0);
      assertThat(p['ep.ai_source']).isEqualTo('OAI-SearchBot');
      assertThat(p['ep.ai_category']).isEqualTo('search');
      assertThat(p['ep.bot_ua']).hasLength(100);
    });
- name: Browser masquerade UA classifies as crawler and never as referral
  code: |-
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: OAI_SEARCHBOT_UA, page_location: 'https://example.com/', page_referrer: 'https://chatgpt.com/' };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      const p = sentParams(0);
      assertThat(p['ep.ai_type']).isEqualTo('crawler');
      assertThat(p['ep.ai_source']).isEqualTo('OAI-SearchBot');
    });
- name: Anthropic tokens disambiguate into three distinct sources
  code: |-
    eventData = { event_name: 'ai_crawler_ping', client_id: 'c', bot_ua: 'Mozilla/5.0; compatible; Claude-SearchBot/1.0; +claude.com' };
    runCode(mockData);
    eventData = { event_name: 'ai_crawler_ping', client_id: 'c', bot_ua: 'Mozilla/5.0; compatible; ClaudeBot/1.0; +claude.com' };
    runCode(mockData);
    eventData = { event_name: 'ai_crawler_ping', client_id: 'c', bot_ua: 'Mozilla/5.0; compatible; Claude-User/1.0; +claude.com' };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(3);
      assertThat(sentParams(0)['ep.ai_source']).isEqualTo('Claude-SearchBot');
      assertThat(sentParams(0)['ep.ai_category']).isEqualTo('search');
      assertThat(sentParams(1)['ep.ai_source']).isEqualTo('ClaudeBot');
      assertThat(sentParams(1)['ep.ai_category']).isEqualTo('training');
      assertThat(sentParams(2)['ep.ai_source']).isEqualTo('Claude-User');
      assertThat(sentParams(2)['ep.ai_category']).isEqualTo('user_initiated');
    });
- name: Bare partial tokens never match
  code: |-
    eventData = { event_name: 'ai_crawler_ping', client_id: 'c', bot_ua: 'my searchbot chatgpt claude adsbot meta cohere tool' };
    runCode(mockData);
    callLater(() => {
      assertApi('gtmOnSuccess').wasCalled();
      assertThat(sentHttp).isEmpty();
    });
- name: CCBot requires the slash in the matcher
  code: |-
    eventData = { event_name: 'ai_crawler_ping', client_id: 'c', bot_ua: 'CCBot/2.0 (https://commoncrawl.org/faq/)' };
    runCode(mockData);
    eventData = { event_name: 'ai_crawler_ping', client_id: 'c', bot_ua: 'the ccbot fan page scraper' };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      assertThat(sentParams(0)['ep.ai_source']).isEqualTo('CCBot');
    });
- name: Applebot arriving as event user_agent is detected in default mode
  code: |-
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko; compatible; Applebot/0.1; +http://www.apple.com/go/applebot)', page_location: 'https://example.com/' };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      assertThat(sentParams(0)['ep.ai_source']).isEqualTo('Applebot');
      assertThat(sentParams(0)['ep.ai_category']).isEqualTo('search');
    });
- name: Google-Agent maps to an agent event
  code: |-
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: 'Mozilla/5.0; compatible; Google-Agent/1.0', page_location: 'https://example.com/' };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      const p = sentParams(0);
      assertThat(p.en).isEqualTo('ai_agent_visit');
      assertThat(p['ep.ai_type']).isEqualTo('agent');
      assertThat(p['ep.ai_category']).isEqualTo('agentic');
    });
- name: Signature-Agent header detects ChatGPT agent mode on a plain Chrome UA
  code: |-
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: CHROME_UA, page_location: 'https://example.com/' };
    headers = { 'signature-agent': 'https://chatgpt.com' };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      const p = sentParams(0);
      assertThat(p.en).isEqualTo('ai_agent_visit');
      assertThat(p['ep.ai_source']).isEqualTo('chatgpt-agent');
      assertThat(p['ep.detection_method']).isEqualTo('signature_agent');
    });
- name: A spoofed bot_ua param on a page_view is ignored
  code: |-
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: CHROME_UA, bot_ua: GPTBOT_UA, page_location: 'https://example.com/' };
    runCode(mockData);
    callLater(() => {
      assertApi('gtmOnSuccess').wasCalled();
      assertThat(sentHttp).isEmpty();
    });
- name: Referral via referrer hostname is organic
  code: |-
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: CHROME_UA, page_location: 'https://www.example.com/blog', page_referrer: 'https://chatgpt.com/' };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      const p = sentParams(0);
      assertThat(p.en).isEqualTo('ai_referral_visit');
      assertThat(p['ep.ai_source']).isEqualTo('chatgpt');
      assertThat(p['ep.ai_medium']).isEqualTo('organic');
      assertThat(p['ep.detection_method']).isEqualTo('referrer');
    });
- name: Referral via UTM survives a stripped referrer
  code: |-
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: CHROME_UA, page_location: 'https://www.example.com/?utm_source=chatgpt.com' };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      assertThat(sentParams(0)['ep.ai_source']).isEqualTo('chatgpt');
      assertThat(sentParams(0)['ep.detection_method']).isEqualTo('utm');
    });
- name: Paid AI click is labeled ai_medium paid
  code: |-
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: CHROME_UA, page_location: 'https://www.example.com/?utm_source=chatgpt&utm_medium=cpc' };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      assertThat(sentParams(0)['ep.ai_medium']).isEqualTo('paid');
    });
- name: oppref alone classifies as a paid chatgpt referral
  code: |-
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: CHROME_UA, page_location: 'https://www.example.com/landing?oppref=abc123DEF' };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      assertThat(sentParams(0).en).isEqualTo('ai_referral_visit');
      assertThat(sentParams(0)['ep.ai_source']).isEqualTo('chatgpt');
      assertThat(sentParams(0)['ep.ai_operator']).isEqualTo('OpenAI');
      assertThat(sentParams(0)['ep.ai_medium']).isEqualTo('paid');
      assertThat(sentParams(0)['ep.detection_method']).isEqualTo('oppref');
    });
- name: An explicit UTM outranks oppref
  code: |-
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: CHROME_UA, page_location: 'https://www.example.com/?utm_source=perplexity&oppref=abc123' };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      assertThat(sentParams(0)['ep.ai_source']).isEqualTo('perplexity');
      assertThat(sentParams(0)['ep.detection_method']).isEqualTo('utm');
    });
- name: oppref outranks the referrer hostname
  code: |-
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: CHROME_UA, page_location: 'https://www.example.com/?oppref=abc123', page_referrer: 'https://www.perplexity.ai/search' };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      assertThat(sentParams(0)['ep.ai_source']).isEqualTo('chatgpt');
      assertThat(sentParams(0)['ep.ai_medium']).isEqualTo('paid');
      assertThat(sentParams(0)['ep.detection_method']).isEqualTo('oppref');
    });
- name: Same-site referrer is discarded
  code: |-
    mock('computeEffectiveTldPlusOne', (url) => 'example.com');
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: CHROME_UA, page_location: 'https://www.example.com/a', page_referrer: 'https://blog.example.com/b' };
    runCode(mockData);
    callLater(() => {
      assertApi('gtmOnSuccess').wasCalled();
      assertThat(sentHttp).isEmpty();
    });
- name: Plain human traffic is a no-op with no HTTP calls
  code: |-
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: CHROME_UA, page_location: 'https://www.example.com/' };
    runCode(mockData);
    callLater(() => {
      assertApi('gtmOnSuccess').wasCalled();
      assertApi('sendHttpRequest').wasNotCalled();
    });
- name: Referral tier is gated to page_view events
  code: |-
    eventData = { event_name: 'scroll', client_id: 'c', user_agent: CHROME_UA, page_location: 'https://www.example.com/', page_referrer: 'https://chatgpt.com/' };
    runCode(mockData);
    callLater(() => {
      assertApi('gtmOnSuccess').wasCalled();
      assertThat(sentHttp).isEmpty();
    });
- name: Loop guard ignores all three output event names
  code: |-
    eventData = { event_name: 'ai_crawler_visit', client_id: 'c' };
    runCode(mockData);
    eventData = { event_name: 'ai_agent_visit', client_id: 'c' };
    runCode(mockData);
    eventData = { event_name: 'ai_referral_visit', client_id: 'c' };
    runCode(mockData);
    callLater(() => {
      assertApi('gtmOnSuccess').wasCalled();
      assertThat(sentHttp).isEmpty();
    });
- name: pingSecret drops pings with a missing or wrong secret
  code: |-
    mockData.pingSecret = 's3cret';
    eventData = { event_name: 'ai_crawler_ping', client_id: 'aic.gptbot', bot_ua: GPTBOT_UA };
    runCode(mockData);
    eventData = { event_name: 'ai_crawler_ping', client_id: 'aic.gptbot', bot_ua: GPTBOT_UA, ping_secret: 'wrong' };
    runCode(mockData);
    callLater(() => {
      assertApi('gtmOnSuccess').wasCalled();
      assertThat(sentHttp).isEmpty();
    });
- name: pingSecret accepts a matching secret
  code: |-
    mockData.pingSecret = 's3cret';
    eventData = { event_name: 'ai_crawler_ping', client_id: 'aic.gptbot', bot_ua: GPTBOT_UA, ping_secret: 's3cret' };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      assertThat(sentParams(0)['ep.ai_source']).isEqualTo('GPTBot');
    });
- name: extraBots table rows match with their configured labels
  code: |-
    mockData.extraBots = [{ uaSubstring: 'novel-bot-9000', displayName: 'NovelBot', operator: 'NovelCorp', category: 'search' }];
    eventData = { event_name: 'ai_crawler_ping', client_id: 'c', bot_ua: 'Mozilla/5.0; compatible; Novel-Bot-9000/1.0' };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      const p = sentParams(0);
      assertThat(p['ep.ai_source']).isEqualTo('NovelBot');
      assertThat(p['ep.ai_operator']).isEqualTo('NovelCorp');
      assertThat(p['ep.ai_category']).isEqualTo('search');
    });
- name: excludeTokens disables a built-in matcher
  code: |-
    mockData.excludeTokens = 'gptbot';
    eventData = { event_name: 'ai_crawler_ping', client_id: 'c', bot_ua: GPTBOT_UA };
    runCode(mockData);
    callLater(() => {
      assertApi('gtmOnSuccess').wasCalled();
      assertThat(sentHttp).isEmpty();
    });
- name: Crawler toggle off makes the crawler tier inert
  code: |-
    mockData.enableCrawlerDetection = false;
    eventData = { event_name: 'ai_crawler_ping', client_id: 'c', bot_ua: GPTBOT_UA };
    runCode(mockData);
    callLater(() => {
      assertApi('gtmOnSuccess').wasCalled();
      assertThat(sentHttp).isEmpty();
    });
- name: Agent toggle off makes the Signature-Agent tier inert
  code: |-
    mockData.enableAgentDetection = false;
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: CHROME_UA, page_location: 'https://example.com/' };
    headers = { 'signature-agent': 'https://chatgpt.com' };
    runCode(mockData);
    callLater(() => {
      assertApi('gtmOnSuccess').wasCalled();
      assertThat(sentHttp).isEmpty();
    });
- name: Referral toggle off makes the referral tier inert
  code: |-
    mockData.enableReferralDetection = false;
    eventData = { event_name: 'page_view', client_id: 'c', user_agent: CHROME_UA, page_location: 'https://example.com/', page_referrer: 'https://chatgpt.com/' };
    runCode(mockData);
    callLater(() => {
      assertApi('gtmOnSuccess').wasCalled();
      assertThat(sentHttp).isEmpty();
    });
- name: Long page_location truncates while hostname and path params survive
  code: |-
    let longQuery = 'utm_content=abcdefghij';
    for (let i = 0; i < 4; i++) { longQuery = longQuery + '&' + longQuery; }
    eventData = { event_name: 'ai_crawler_ping', client_id: 'c', bot_ua: GPTBOT_UA, page_location: 'https://example.com/pricing/enterprise?' + longQuery };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      const p = sentParams(0);
      assertThat(p.dl).hasLength(100);
      assertThat(p['ep.page_hostname']).isEqualTo('example.com');
      assertThat(p['ep.page_path']).isEqualTo('/pricing/enterprise');
    });
- name: A pathological path is still capped at the GA4 param limit
  code: |-
    let longPath = '/segment';
    for (let i = 0; i < 6; i++) { longPath = longPath + longPath; }
    eventData = { event_name: 'ai_crawler_ping', client_id: 'c', bot_ua: GPTBOT_UA, page_location: 'https://example.com' + longPath };
    runCode(mockData);
    callLater(() => {
      assertThat(sentHttp).hasLength(1);
      assertThat(sentParams(0)['ep.page_path']).hasLength(100);
    });
- name: A rejected send calls gtmOnFailure
  code: |-
    httpShouldFail = true;
    eventData = { event_name: 'ai_crawler_ping', client_id: 'c', bot_ua: GPTBOT_UA };
    runCode(mockData);
    callLater(() => {
      assertApi('gtmOnFailure').wasCalled();
    });
- name: A non-2xx response calls gtmOnFailure
  code: |-
    httpStatus = 500;
    eventData = { event_name: 'ai_crawler_ping', client_id: 'c', bot_ua: GPTBOT_UA };
    runCode(mockData);
    callLater(() => {
      assertApi('gtmOnFailure').wasCalled();
    });


___NOTES___

AI Crawler Analytics by AI-Advisors
Repository: https://github.com/ai-advisors/ai-crawler-analytics
Documentation: see README.md in the repository.

v1.1.0 (2026-08-12)
- Tier 3 referral detection now recognizes OpenAI's oppref click
  identifier on the landing URL. A paid ChatGPT Ads click that arrives
  with a stripped referrer and no UTM parameters was previously
  invisible; it now classifies as ai_referral_visit with ai_source
  chatgpt, ai_medium paid, detection_method oppref. Precedence: UTM
  first, oppref second, referrer hostname third. No new permissions.

v1.0.0 (2026-07-30)
- Initial release. Three detection tiers: AI crawler user agents (21 built-in
  matchers), Signature-Agent header, and AI referral traffic (UTM + referrer).
- Fixed event schema: ai_crawler_visit, ai_agent_visit, ai_referral_visit.
- Data is sent only to the GA4 property configured on the tag. Nothing is
  ever sent to AI-Advisors.
