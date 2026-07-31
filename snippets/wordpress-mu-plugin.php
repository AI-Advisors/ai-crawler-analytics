<?php
/**
 * Plugin Name: AI Crawler Analytics ping
 * Description: Forwards AI crawler page requests to your server-side GTM container as ai_crawler_ping events. Install as a must-use plugin: copy to wp-content/mu-plugins/.
 */

define('AICA_SGTM_URL', 'https://sgtm.example.com'); // your server GTM container URL
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
        'bot_ua' => $ua,
        'page_location' => set_url_scheme('http://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI']),
    );
    if (AICA_PING_SECRET !== '') $params['ping_secret'] = AICA_PING_SECRET;

    wp_remote_post(AICA_SGTM_URL . '/mp/collect', array(
        'blocking' => false, // fire-and-forget, never delays the crawler
        'timeout'  => 2,
        'headers'  => array('Content-Type' => 'application/json'),
        'body'     => wp_json_encode(array(
            'client_id' => 'aic.' . str_replace('/', '', strtolower($m[1])),
            'events'    => array(array(
                'name'   => 'ai_crawler_ping',
                'params' => $params,
            )),
        )),
    ));
});
