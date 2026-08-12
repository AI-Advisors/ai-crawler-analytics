<?php
/**
 * Plugin Name: AI Crawler Analytics ping
 * Description: Forwards AI crawler page requests to your server-side GTM container as ai_crawler_ping events. Install as a must-use plugin: copy to wp-content/mu-plugins/.
 *
 * Set AICA_SGTM_URL, AICA_GA4_MEASUREMENT_ID (same ID as on the tag), and
 * optionally AICA_PING_SECRET (must match the tag's Ping secret).
 *
 * The ping uses the GA4 g/collect wire format because that is what the
 * GA4 client pre-installed in every server container claims. A JSON POST
 * to /mp/collect is NOT claimed by a default container (tested on a live
 * tagging server, 2026-08-12) and would be silently dropped.
 */

define('AICA_SGTM_URL', 'https://sgtm.example.com'); // your server GTM container URL
define('AICA_GA4_MEASUREMENT_ID', 'G-XXXXXXXXXX'); // same ID as on the tag
define('AICA_PING_SECRET', ''); // must match the tag's Ping secret, or leave empty

add_action('template_redirect', function () {
    if (is_admin()) return;
    $ua = isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : '';
    if ($ua === '') return;

    // Fast prefilter only; the tag's registry is authoritative. Send the FULL
    // user agent: some tokens appear after character 100 of the real UA.
    $re = '/(gptbot|oai-searchbot|oai-adsbot|chatgpt-user|claudebot|claude-searchbot|claude-user|perplexitybot|perplexity-user|mistralai-user|duckassistbot|applebot|amazonbot|bytespider|meta-externalagent|meta-externalfetcher|meta-webindexer|ccbot\/|cohere-ai|cohere-training-data-crawler|google-agent)/i';
    if (!preg_match($re, $ua, $m)) return;

    $params = array(
        'v'         => '2',
        'tid'       => AICA_GA4_MEASUREMENT_ID,
        'cid'       => 'aic.' . str_replace('/', '', strtolower($m[1])),
        'en'        => 'ai_crawler_ping',
        'ep.bot_ua' => $ua, // full UA, never truncated here
        'dl'        => set_url_scheme('http://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI']),
    );
    if (AICA_PING_SECRET !== '') $params['ep.ping_secret'] = AICA_PING_SECRET;

    wp_remote_post(AICA_SGTM_URL . '/g/collect?' . http_build_query($params, '', '&', PHP_QUERY_RFC3986), array(
        'blocking' => false, // fire-and-forget, never delays the crawler
        'timeout'  => 2,
    ));
});
