/**
 * PostHog web loader for PowerCoach Studio.
 *
 * No API keys live here. Dart calls window.__powercoachPostHog.init(apiKey, host)
 * after loadAppEnv() when POSTHOG_API_KEY is set AND the user has granted consent.
 *
 * Stub matches the official posthog-js snippet so capture/identify queue until array.js loads.
 *
 * Session replay: enabled after consent, with strong text/input masking.
 * Residual: Flutter CanvasKit paints UI to <canvas>; replay/heatmaps may not
 * reconstruct widget-level DOM the way a typical HTML app does. Prefer product
 * events + pageviews for reliable funnels; treat canvas replay as best-effort.
 */
(function () {
  'use strict';

  if (window.__powercoachPostHog) {
    return;
  }

  // Official PostHog stub (init deferred until Dart provides the project key).
  !(function (t, e) {
    var o, n, p, r;
    e.__SV ||
      ((window.posthog = e),
      (e._i = []),
      (e.init = function (i, s, a) {
        function g(t, e) {
          var o = e.split('.');
          2 == o.length && ((t = t[o[0]]), (e = o[1])),
            (t[e] = function () {
              t.push([e].concat(Array.prototype.slice.call(arguments, 0)));
            });
        }
        ((p = t.createElement('script')).type = 'text/javascript'),
          (p.crossOrigin = 'anonymous'),
          (p.async = !0),
          (p.src =
            s.api_host.replace('.i.posthog.com', '-assets.i.posthog.com') +
            '/static/array.js'),
          (r = t.getElementsByTagName('script')[0]).parentNode.insertBefore(p, r);
        var u = e;
        for (
          void 0 !== a ? (u = e[a] = []) : (a = 'posthog'),
            u.people = u.people || [],
            Object.defineProperty(u, 'toString', {
              configurable: !0,
              enumerable: !0,
              writable: !0,
              value: function (t) {
                var e = 'posthog';
                return (
                  'posthog' !== a && (e += '.' + a), t || (e += ' (stub)'), e
                );
              },
            }),
            Object.defineProperty(u.people, 'toString', {
              configurable: !0,
              enumerable: !0,
              writable: !0,
              value: function () {
                return u.toString(1) + '.people (stub)';
              },
            }),
            (o =
              'init capture register register_once register_for_session unregister unregister_for_session getFeatureFlag getFeatureFlagResult isFeatureEnabled reloadFeatureFlags updateEarlyAccessFeatureEnrollment getEarlyAccessFeatures on onFeatureFlags onSessionId getSurveys getActiveMatchingSurveys renderSurvey canRenderSurvey getNextSurveyStep identify setPersonProperties group resetGroups setPersonPropertiesForFlags resetPersonPropertiesForFlags setGroupPropertiesForFlags resetGroupPropertiesForFlags reset get_distinct_id getGroups get_session_id get_session_replay_url alias set_config startSessionRecording stopSessionRecording sessionRecordingStarted captureException loadToolbar get_property getSessionProperty createPersonProfile opt_in_capturing opt_out_capturing has_opted_in_capturing has_opted_out_capturing clear_opt_in_out_capturing debug'.split(
                ' ',
              )),
            (n = 0);
          n < o.length;
          n++
        )
          g(u, o[n]);
        e._i.push([i, s, a]);
      }),
      (e.__SV = 1));
  })(document, window.posthog || []);

  var DEFAULT_HOST = 'https://eu.i.posthog.com';

  function parseProps(properties) {
    if (properties == null) {
      return {};
    }
    if (typeof properties === 'string') {
      try {
        var parsed = JSON.parse(properties);
        return parsed && typeof parsed === 'object' ? parsed : {};
      } catch (e) {
        return {};
      }
    }
    if (typeof properties === 'object') {
      return properties;
    }
    return {};
  }

  window.__powercoachPostHog = {
    initialized: false,
    init: function (apiKey, host) {
      if (!apiKey || typeof apiKey !== 'string') {
        return false;
      }
      if (this.initialized) {
        return true;
      }
      var apiHost =
        host && typeof host === 'string' && host.trim()
          ? host.trim()
          : DEFAULT_HOST;
      // api_host: absolute EU ingest OR relative first-party proxy (e.g. '/pcs-ph').
      // ui_host: always the PostHog EU app — never the proxy path (toolbar / recordings).
      window.posthog.init(apiKey, {
        api_host: apiHost,
        ui_host: 'https://eu.posthog.com',
        person_profiles: 'identified_only',
        // Manual $pageview from go_router (Flutter SPA).
        capture_pageview: false,
        capture_pageleave: true,
        // Session replay on after consent-gated Dart init (EU cookie banner).
        disable_session_recording: false,
        // Strong masking: text + inputs + attributes.
        mask_all_text: true,
        mask_all_element_attributes: true,
        session_recording: {
          maskAllInputs: true,
          maskTextSelector: '*',
        },
      });
      this.initialized = true;
      return true;
    },
    capture: function (eventName, properties) {
      if (!this.initialized || !window.posthog || !eventName) {
        return;
      }
      window.posthog.capture(String(eventName), parseProps(properties));
    },
    capturePageview: function (path) {
      if (!this.initialized || !window.posthog) {
        return;
      }
      var safePath =
        typeof path === 'string' && path.length > 0 ? path : window.location.pathname;
      // Never attach location.search — query strings may contain email / names.
      var href = window.location.origin + safePath;
      window.posthog.capture('$pageview', {
        $current_url: href,
        path: safePath,
      });
    },
    identify: function (distinctId) {
      if (!this.initialized || !window.posthog || !distinctId) {
        return;
      }
      window.posthog.identify(String(distinctId));
    },
    reset: function () {
      if (!this.initialized || !window.posthog) {
        return;
      }
      window.posthog.reset();
    },
    optInCapturing: function () {
      if (!this.initialized || !window.posthog) {
        return;
      }
      if (typeof window.posthog.opt_in_capturing === 'function') {
        window.posthog.opt_in_capturing();
      }
      if (typeof window.posthog.startSessionRecording === 'function') {
        window.posthog.startSessionRecording();
      }
    },
    optOutCapturing: function () {
      if (!window.posthog) {
        return;
      }
      if (typeof window.posthog.stopSessionRecording === 'function') {
        window.posthog.stopSessionRecording();
      }
      if (typeof window.posthog.opt_out_capturing === 'function') {
        window.posthog.opt_out_capturing();
      }
    },
  };
})();
