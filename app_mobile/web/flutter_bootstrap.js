{{flutter_js}}
{{flutter_build_config}}
_flutter.loader.load({
  // No serviceWorkerSettings: this deploy target iterates fast (it's a
  // stopgap testing link, not the shipped product — that's the native
  // Android/iOS app), and a Flutter web service worker aggressively
  // caches the old build, which reliably masks new deploys behind a
  // stale cached version until a hard-refresh. Skipping registration
  // entirely means every load fetches straight from Hosting.
  config: {
    canvasKitBaseUrl: "canvaskit/"
  },
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    var loader = document.getElementById('med100-loading');
    if (loader) loader.remove();
  }
});
