{ inputs, lib, pkgs, config, ... }:

{

  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      search = {
        force = true;
        default = "google";
        privateDefault = "google";
        order = ["google"];
      };
      bookmarks = {};
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin
        bitwarden
      ];
      settings = {
        /*** [SECTION 0100]: STARTUP ***/
        /* 0102: set startup page [SETUP-CHROME]
        * 0=blank, 1=home, 2=last visited page, 3=resume previous session
        * [NOTE] Session Restore is cleared with history (2811), and not used in Private Browsing mode
        * [SETTING] General>Startup>Restore previous session ***/
        "browser.startup.page" = 1;
        /* 0103: set HOME+NEWWINDOW page
        * about:home=Firefox Home (default, see 0105), custom URL, about:blank
        * [SETTING] Home>New Windows and Tabs>Homepage and new windows ***/
        "browser.startup.homepage" = "about:home";
        /* 0104: set NEWTAB page
        * true=Firefox Home (default, see 0105), false=blank page
        * [SETTING] Home>New Windows and Tabs>New tabs ***/
        "browser.newtabpage.enabled" = true;
        /* 0105: disable sponsored content on Firefox Home (Activity Stream)
        * [SETTING] Home>Firefox Home Content ***/
        "browser.newtabpage.activity-stream.showSponsored" = false; # [FF58+]
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false; # [FF83+] Shortcuts>Sponsored shortcuts
        "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
        /* 0106: clear default topsites
        * [NOTE] This does not block you from adding your own ***/
        "browser.newtabpage.activity-stream.default.sites" = "";
        # Remove persistent elements in newtab page
        "browser.newtabpage.blocked" = lib.genAttrs [
          # Youtube
          "26UbzFJ7qT9/4DhodHKA1Q=="
          # Facebook
          "4gPpjkxgZzXPVtuEoAL9Ig=="
          # Wikipedia
          "eV8/WsSLxHadrTL1gAxhug=="
          # Reddit
          "gLv0ja2RYVgxKdp0I5qwvA=="
          # Amazon
          "K00ILysCaEq8+bEqV/3nuw=="
          # Twitter
          "T9nJot5PurhJSy8n038xGA=="
        ] (_: 1);

        /*** [SECTION 0200]: GEOLOCATION ***/
        "_user.js.parrot" = "0200 syntax error: the parrot's definitely deceased!";
        /* 0202: disable using the OS's geolocation service ***/
        "geo.provider.ms-windows-location" = false; # [WINDOWS]
        "geo.provider.use_corelocation" = false; # [MAC]
        "geo.provider.use_geoclue" = false; # [FF102+] [LINUX]

        /*** [SECTION 0300]: QUIETER FOX ***/
        /** RECOMMENDATIONS ***/
        /* 0320: disable recommendation pane in about:addons (uses Google Analytics) ***/
        "extensions.getAddons.showPane" = false; # [HIDDEN PREF]
        /* 0321: disable recommendations in about:addons' Extensions and Themes panes [FF68+] ***/
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        /* 0322: disable personalized Extension Recommendations in about:addons and AMO [FF65+]
        * [NOTE] This pref has no effect when Health Reports (0331) are disabled
        * [SETTING] Privacy & Security>Firefox Data Collection & Use>Allow Firefox to make personalized extension recommendations
        * [1] https://support.mozilla.org/kb/personalized-extension-recommendations ***/
        "browser.discovery.enabled" = false;
        /* 0323: disable shopping experience [FF116+]
        * [1] https://bugzilla.mozilla.org/show_bug.cgi?id=1840156#c0 ***/
        "browser.shopping.experience2023.enabled" = false; # [DEFAULT: false]

        /** TELEMETRY ***/
        /* 0330: disable new data submission [FF41+]
        * If disabled, no policy is shown or upload takes place, ever
        * [1] https://bugzilla.mozilla.org/1195552 ***/
        "datareporting.policy.dataSubmissionEnabled" = false;
        /* 0331: disable Health Reports
        * [SETTING] Privacy & Security>Firefox Data Collection & Use>Allow Firefox to send technical... data ***/
        "datareporting.healthreport.uploadEnabled" = false;
        /* 0332: disable telemetry
        * The "unified" pref affects the behavior of the "enabled" pref
        * - If "unified" is false then "enabled" controls the telemetry module
        * - If "unified" is true then "enabled" only controls whether to record extended data
        * [NOTE] "toolkit.telemetry.enabled" is now LOCKED to reflect prerelease (true) or release builds (false) [2]
        * [1] https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/internals/preferences.html
        * [2] https://medium.com/georg-fritzsche/data-preference-changes-in-firefox-58-2d5df9c428b5 ***/
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false; # see [NOTE]
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false; # [FF55+]
        "toolkit.telemetry.shutdownPingSender.enabled" = false; # [FF55+]
        "toolkit.telemetry.updatePing.enabled" = false; # [FF56+]
        "toolkit.telemetry.bhrPing.enabled" = false; # [FF57+] Background Hang Reporter
        "toolkit.telemetry.firstShutdownPing.enabled" = false; # [FF57+]
        /* 0333: disable Telemetry Coverage
        * [1] https://blog.mozilla.org/data/2018/08/20/effectively-measuring-search-in-firefox/ ***/
        "toolkit.telemetry.coverage.opt-out" = true; # [HIDDEN PREF]
        "toolkit.coverage.opt-out" = true; # [FF64+] [HIDDEN PREF]
        "toolkit.coverage.endpoint.base" = "";
        /* 0335: disable Firefox Home (Activity Stream) telemetry ***/
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;

        /** STUDIES ***/
        /* 0340: disable Studies
        * [SETTING] Privacy & Security>Firefox Data Collection & Use>Allow Firefox to install and run studies ***/
        "app.shield.optoutstudies.enabled" = false;
        /* 0341: disable Normandy/Shield [FF60+]
        * Shield is a telemetry system that can push and test "recipes"
        * [1] https://mozilla.github.io/normandy/ ***/
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";

        /** CRASH REPORTS ***/
        /* 0350: disable Crash Reports ***/
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false; # [FF44+]
        # user_pref("browser.crashReports.unsubmittedCheck.enabled" = false; # [FF51+] [DEFAULT: false]
        /* 0351: enforce no submission of backlogged Crash Reports [FF58+]
        * [SETTING] Privacy & Security>Firefox Data Collection & Use>Allow Firefox to send backlogged crash reports  ***/
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false; # [DEFAULT: false]

        /** OTHER ***/
        /* 0360: disable Captive Portal detection
        * [1] https://www.eff.org/deeplinks/2017/08/how-captive-portals-interfere-wireless-security-and-privacy ***/
        "captivedetect.canonicalURL" = "";
        "network.captive-portal-service.enabled" = false; # [FF52+]
        /* 0361: disable Network Connectivity checks [FF65+]
        * [1] https://bugzilla.mozilla.org/1460537 ***/
        "network.connectivity-service.enabled" = false;

        /*** [SECTION 0800]: LOCATION BAR / SEARCH BAR / SUGGESTIONS / HISTORY / FORMS ***/
        /* 0801: disable location bar making speculative connections [FF56+]
        * [1] https://bugzilla.mozilla.org/1348275 ***/
        "browser.urlbar.speculativeConnect.enabled" = false;
        /* 0802: disable location bar contextual suggestions
        * [NOTE] The UI is controlled by the .enabled pref
        * [SETTING] Search>Address Bar>Suggestions from...
        * [1] https://blog.mozilla.org/data/2021/09/15/data-and-firefox-suggest/ ***/
        "browser.urlbar.quicksuggest.enabled" = false; # [FF92+]
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false; # [FF95+]
        "browser.urlbar.suggest.quicksuggest.sponsored" = false; # [FF92+]
        /* 0803: disable live search suggestions
        * [NOTE] Both must be true for live search to work in the location bar
        * [SETUP-CHROME] Override these if you trust and use a privacy respecting search engine
        * [SETTING] Search>Show search suggestions | Show search suggestions in address bar results ***/
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
        /* 0805: disable urlbar trending search suggestions [FF118+]
        * [SETTING] Search>Search Suggestions>Show trending search suggestions (FF119) ***/
        "browser.urlbar.trending.featureGate" = false;
        /* 0806: disable urlbar suggestions ***/
        "browser.urlbar.addons.featureGate" = false; # [FF115+]
        "browser.urlbar.mdn.featureGate" = false; # [FF117+] [HIDDEN PREF]
        "browser.urlbar.pocket.featureGate" = false; # [FF116+] [DEFAULT: false]
        "browser.urlbar.weather.featureGate" = false; # [FF108+] [DEFAULT: false]
        "browser.urlbar.yelp.featureGate" = false; # [FF124+] [DEFAULT: false]
        /* 0807: disable urlbar clipboard suggestions [FF118+] ***/
        # "browser.urlbar.clipboard.featureGate" = false;
        /* 0808: disable recent searches [FF120+]
        * [NOTE] Recent searches are cleared with history (2811)
        * [1] https://support.mozilla.org/kb/search-suggestions-firefox ***/
        # "browser.urlbar.recentsearches.featureGate" = false;
        /* 0810: disable search and form history
        * [NOTE] We also clear formdata on exit (2811)
        * [SETUP-WEB] Be aware that autocomplete form data can be read by third parties [1][2]
        * [SETTING] Privacy & Security>History>Custom Settings>Remember search and form history
        * [1] https://blog.mindedsecurity.com/2011/10/autocompleteagain.html
        * [2] https://bugzilla.mozilla.org/381681 ***/
        "browser.formfill.enable" = false;
        /* 0815: disable tab-to-search [FF85+]
        * Alternatively, you can exclude on a per-engine basis by unchecking them in Options>Search
        * [SETTING] Search>Address Bar>When using the address bar, suggest>Search engines ***/
        # "browser.urlbar.suggest.engines" = false;
        /* 0820: disable coloring of visited links
        * [SETUP-HARDEN] Bulk rapid history sniffing was mitigated in 2010 [1][2]. Slower and more expensive
        * redraw timing attacks were largely mitigated in FF77+ [3]. Using RFP (4501) further hampers timing
        * attacks. Don't forget clearing history on exit (2811). However, social engineering [2#limits][4][5]
        * and advanced targeted timing attacks could still produce usable results
        * [1] https://developer.mozilla.org/docs/Web/CSS/Privacy_and_the_:visited_selector
        * [2] https://dbaron.org/mozilla/visited-privacy
        * [3] https://bugzilla.mozilla.org/1632765
        * [4] https://earthlng.github.io/testpages/visited_links.html (see github wiki APPENDIX A on how to use)
        * [5] https://lcamtuf.blogspot.com/2016/08/css-mix-blend-mode-is-bad-for-keeping.html ***/
        # "layout.css.visited_links_enabled" = false;
        /* 0830: enable separate default search engine in Private Windows and its UI setting
        * [SETTING] Search>Default Search Engine>Choose a different default search engine for Private Windows only ***/
        "browser.search.separatePrivateDefault" = true; # [FF70+]
        "browser.search.separatePrivateDefault.ui.enabled" = true; # [FF71+]

        /*** [SECTION 0900]: PASSWORDS
         [1] https://support.mozilla.org/kb/use-primary-password-protect-stored-logins-and-pas
        ***/
        /* 0903: disable auto-filling username & password form fields
        * can leak in cross-site forms *and* be spoofed
        * [NOTE] Username & password is still available when you enter the field
        * [SETTING] Privacy & Security>Logins and Passwords>Autofill logins and passwords
        * [1] https://freedom-to-tinker.com/2017/12/27/no-boundaries-for-user-identities-web-trackers-exploit-browser-login-managers/
        * [2] https://homes.esat.kuleuven.be/~asenol/leaky-forms/ ***/
        "signon.autofillForms" = false;
        /* 0904: disable formless login capture for Password Manager [FF51+] ***/
        "signon.formlessCapture.enabled" = false;
        /* 0905: limit (or disable) HTTP authentication credentials dialogs triggered by sub-resources [FF41+]
        * hardens against potential credentials phishing
        * 0 = don't allow sub-resources to open HTTP authentication credentials dialogs
        * 1 = don't allow cross-origin sub-resources to open HTTP authentication credentials dialogs
        * 2 = allow sub-resources to open HTTP authentication credentials dialogs (default) ***/
        "network.auth.subresource-http-auth-allow" = 1;
        /* 0906: enforce no automatic authentication on Microsoft sites [FF91+] [WINDOWS 10+]
        * [SETTING] Privacy & Security>Logins and Passwords>Allow Windows single sign-on for...
        * [1] https://support.mozilla.org/kb/windows-sso ***/
        # "network.http.windows-sso.enabled" = false; # [DEFAULT: false]

        /** DOWNLOADS ***/
        /* 2651: enable user interaction for security by always asking where to download
        * [SETUP-CHROME] On Android this blocks longtapping and saving images
        * [SETTING] General>Downloads>Always ask you where to save files ***/
        "browser.download.useDownloadDir" = false;
        /* 2652: disable downloads panel opening on every download [FF96+] ***/
        "browser.download.alwaysOpenPanel" = false;
        /* 2653: disable adding downloads to the system's "recent documents" list ***/
        "browser.download.manager.addToRecentDocs" = false;
        /* 2654: enable user interaction for security by always asking how to handle new mimetypes [FF101+]
        * [SETTING] General>Files and Applications>What should Firefox do with other files ***/
        "browser.download.always_ask_before_handling_new_types" = true;


        # Disable irritating first-run stuff
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.feeds.showFirstRunUI" = false;
        "browser.messaging-system.whatsNewPanel.enabled" = false;
        "browser.rights.3.shown" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.startup.homepage_override.mstone" = "ignore";
        "browser.uitour.enabled" = false;
        "startup.homepage_override_url" = "";
        "trailhead.firstrun.didSeeAboutWelcome" = true;
        "browser.bookmarks.restore_default_bookmarks" = false;
        "browser.bookmarks.addedImportButton" = true;

        # Other
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "browser.translations.automaticallyPopup" = false;

        # Disable "save password" prompt
        "signon.rememberSignons" = false;
        
        # Layout
        "browser.uiCustomization.state" = builtins.toJSON {
          currentVersion = 20;
          newElementCount = 5;
          dirtyAreaCache = ["nav-bar" "PersonalToolbar" "toolbar-menubar" "TabsToolbar" "widget-overflow-fixed-list"];
          placements = {
            PersonalToolbar = ["personal-bookmarks"];
            TabsToolbar = ["tabbrowser-tabs" "new-tab-button" "alltabs-button"];
            nav-bar = ["back-button" "forward-button" "urlbar-container" "downloads-button" "jid0-adyhmvsp91nuo8prv0mn2vkeb84_jetpack-browser-action" "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action" "ublock0_raymondhill_net-browser-action" "_testpilot-containers-browser-action" "reset-pbm-toolbar-button" "unified-extensions-button"];
            toolbar-menubar = ["menubar-items"];
            unified-extensions-area = [];
            widget-overflow-fixed-list = [];
          };
          seen = ["save-to-pocket-button" "developer-button" "ublock0_raymondhill_net-browser-action" "_testpilot-containers-browser-action"];
        };
      };
    };
  };

}