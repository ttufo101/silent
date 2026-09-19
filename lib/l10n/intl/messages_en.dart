// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(email) => "A verification code was sent to ${email}";

  static String m1(seconds) => "Resend in ${seconds}s";

  static String m2(count) =>
      "${Intl.plural(count, one: '1 day ago', other: '${count} days ago')}";

  static String m3(completed, total) => "Testing latency ${completed}/${total}";

  static String m4(label) =>
      "Are you sure you want to delete the selected ${label}?";

  static String m5(label) =>
      "Are you sure you want to delete the current ${label}?";

  static String m6(label) => "${label} details";

  static String m7(count) => "Showing ${count} connections";

  static String m8(label) => "${label} cannot be empty";

  static String m9(count) => "${count} entries";

  static String m10(label) => "Current ${label} already exists";

  static String m11(name) => "${name} is already up to date";

  static String m12(name) => "${name} updated";

  static String m13(name) => "Updating ${name}...";

  static String m14(count) =>
      "${Intl.plural(count, one: '1 hour ago', other: '${count} hours ago')}";

  static String m15(count) => "${count} hours";

  static String m16(target) => "${target} is an invalid policy";

  static String m17(proxyName) => "${proxyName} is an invalid proxy";

  static String m18(providerName) =>
      "${providerName} is an invalid proxy provider";

  static String m19(subRule) => "${subRule} is an invalid SUB_RULE";

  static String m20(appName) =>
      "1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check ${appName} in the right list\n\nAfter completing the setup, return to the app and use it normally. Thank you for your cooperation.";

  static String m21(count) =>
      "${Intl.plural(count, one: '1 minute ago', other: '${count} minutes ago')}";

  static String m22(count) =>
      "${Intl.plural(count, one: '1 month ago', other: '${count} months ago')}";

  static String m23(count) => "Node configuration updated with ${count} nodes";

  static String m24(label) => "No ${label} yet";

  static String m25(label) => "${label} must be a number";

  static String m26(label) => "${label} must be between 1024 and 49151";

  static String m27(count) => "${count} seconds";

  static String m28(count) => "${count} items have been selected";

  static String m29(value) => "${value}mbits/s";

  static String m30(value) => "${value}M";

  static String m31(count) => "${count} days";

  static String m32(count) => "${count}";

  static String m33(value) => "${value}G";

  static String m34(version) => "Version ${version}";

  static String m35(label) => "${label} must be a url";

  static String m36(count) =>
      "${Intl.plural(count, one: '1 year ago', other: '${count} years ago')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "accessControl": MessageLookupByLibrary.simpleMessage("AccessControl"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Only allow selected app to enter VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Configure application access proxy",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "The selected application will be excluded from VPN",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Access Control Settings",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "action": MessageLookupByLibrary.simpleMessage("Action"),
    "action_mode": MessageLookupByLibrary.simpleMessage("Switch mode"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "action_start": MessageLookupByLibrary.simpleMessage("Start/Stop"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("Show/Hide"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addDomain": MessageLookupByLibrary.simpleMessage("Add"),
    "addProxies": MessageLookupByLibrary.simpleMessage("Add proxies"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("Add proxy group"),
    "addProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Add proxy providers",
    ),
    "addRule": MessageLookupByLibrary.simpleMessage("Add rule"),
    "addSsid": MessageLookupByLibrary.simpleMessage("Add SSID"),
    "addedRules": MessageLookupByLibrary.simpleMessage("Added rules"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Additional parameters",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV server address",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid WebDAV address",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Advanced configuration",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Provide diverse configuration options",
    ),
    "advancedFeatures": MessageLookupByLibrary.simpleMessage(
      "Advanced features",
    ),
    "advancedSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "System behavior, core configuration, and diagnostics",
    ),
    "allNodes": MessageLookupByLibrary.simpleMessage("All nodes"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Allow applications to bypass VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "Some apps can bypass VPN when turned on",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("AllowLan"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "Allow access proxy through the LAN",
    ),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "App access control",
    ),
    "appearanceSettings": MessageLookupByLibrary.simpleMessage("Appearance"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Append System DNS",
    ),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "Forcefully append system DNS to the configuration",
    ),
    "application": MessageLookupByLibrary.simpleMessage("Application"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Modify application related settings",
    ),
    "authBackToLogin": MessageLookupByLibrary.simpleMessage("Back to login"),
    "authCodeSent": m0,
    "authConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm password",
    ),
    "authEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "authEnterCodeTitle": MessageLookupByLibrary.simpleMessage(
      "Enter the verification code",
    ),
    "authEnterEmailDescription": MessageLookupByLibrary.simpleMessage(
      "Enter your registered email and we\'ll send you a verification code.",
    ),
    "authEnterEmailTitle": MessageLookupByLibrary.simpleMessage(
      "Enter your email",
    ),
    "authForgotPassword": MessageLookupByLibrary.simpleMessage(
      "Forgot password?",
    ),
    "authInvalidCode": MessageLookupByLibrary.simpleMessage(
      "The verification code is invalid or expired. Please try again.",
    ),
    "authInvalidEmail": MessageLookupByLibrary.simpleMessage(
      "Enter a valid email address",
    ),
    "authLoading": MessageLookupByLibrary.simpleMessage("Please wait"),
    "authLogin": MessageLookupByLibrary.simpleMessage("Login"),
    "authNetworkError": MessageLookupByLibrary.simpleMessage(
      "Unable to connect to the server",
    ),
    "authNewPassword": MessageLookupByLibrary.simpleMessage("New password"),
    "authPassword": MessageLookupByLibrary.simpleMessage("Password"),
    "authPasswordMismatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "authRegister": MessageLookupByLibrary.simpleMessage("Register"),
    "authRemember": MessageLookupByLibrary.simpleMessage("Remember me"),
    "authRequired": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "authResend": MessageLookupByLibrary.simpleMessage("Resend"),
    "authResendIn": m1,
    "authResetPassword": MessageLookupByLibrary.simpleMessage("Reset Password"),
    "authResetSuccess": MessageLookupByLibrary.simpleMessage(
      "Password reset successfully. Please log in.",
    ),
    "authSendCode": MessageLookupByLibrary.simpleMessage(
      "Send verification code",
    ),
    "authServiceUnavailable": MessageLookupByLibrary.simpleMessage(
      "The service is temporarily unavailable. Please try again later.",
    ),
    "authSetPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Set a new password",
    ),
    "authorized": MessageLookupByLibrary.simpleMessage("Authorized"),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Auto check updates",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "Auto check for updates when the app starts",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Auto close connections",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Auto close connections after change node",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Auto launch"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Follow the system self startup",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("AutoRun"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Auto run when the application is opened",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Auto set system DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Auto update"),
    "backup": MessageLookupByLibrary.simpleMessage("Backup"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Backup and Restore",
    ),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Sync data via WebDAV or files",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("Backup success"),
    "basicConfig": MessageLookupByLibrary.simpleMessage("Basic configuration"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Modify the basic configuration globally",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Basic info"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("Basic strategy"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "To ensure background operation, please disable battery optimization for this app. Tap to go to settings.",
    ),
    "batteryOptimizationStatusTip": MessageLookupByLibrary.simpleMessage(
      "Affected by the system, this status may not always be accurate.",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Bind"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Blacklist mode"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Bypass domain"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Only takes effect when the system proxy is enabled",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "The cache is corrupt. Do you want to clear it?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "Cancel select all",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Check for updates"),
    "clearData": MessageLookupByLibrary.simpleMessage("Clear Data"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("Export clipboard"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("Clipboard import"),
    "closeAllConnections": MessageLookupByLibrary.simpleMessage(
      "Close all connections",
    ),
    "closeConnection": MessageLookupByLibrary.simpleMessage("Close connection"),
    "color": MessageLookupByLibrary.simpleMessage("Color"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Color schemes"),
    "columns": MessageLookupByLibrary.simpleMessage("Columns"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
    "compatible": MessageLookupByLibrary.simpleMessage("Compatibility mode"),
    "configDataDetected": MessageLookupByLibrary.simpleMessage(
      "Data detected in configuration",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to clear all data?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete the current proxy group?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to exit the current window?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force crash the core?",
    ),
    "confirmOverwriteTip": MessageLookupByLibrary.simpleMessage(
      "Existing data will be overwritten after confirmation",
    ),
    "connectNow": MessageLookupByLibrary.simpleMessage("Connect now"),
    "connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "connecting": MessageLookupByLibrary.simpleMessage("Connecting..."),
    "connection": MessageLookupByLibrary.simpleMessage("Connection"),
    "connections": MessageLookupByLibrary.simpleMessage("Connections"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "View current connections data",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectivity："),
    "content": MessageLookupByLibrary.simpleMessage("Content"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Content cannot be empty",
    ),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Content"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Control global added rules",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Copying environment variables",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copy link"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Copy success"),
    "core": MessageLookupByLibrary.simpleMessage("Core"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Core status"),
    "country": MessageLookupByLibrary.simpleMessage("Country"),
    "crashTest": MessageLookupByLibrary.simpleMessage("Crash test"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "creationTime": MessageLookupByLibrary.simpleMessage("Creation time"),
    "currentNode": MessageLookupByLibrary.simpleMessage("Current node"),
    "custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "customDirectDomains": MessageLookupByLibrary.simpleMessage(
      "Custom direct domains",
    ),
    "customDirectDomainsDesc": MessageLookupByLibrary.simpleMessage(
      "Always connect to selected domains directly",
    ),
    "customProxyDomains": MessageLookupByLibrary.simpleMessage(
      "Custom proxy domains",
    ),
    "customProxyDomainsDesc": MessageLookupByLibrary.simpleMessage(
      "Always route selected domains through the proxy",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("Cut"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dark mode"),
    "darkModeDesc": MessageLookupByLibrary.simpleMessage("Use dark appearance"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Home"),
    "dataChangedSave": MessageLookupByLibrary.simpleMessage(
      "Data changes detected, do you want to save?",
    ),
    "daysAgo": m2,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "Default nameserver",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "For resolving DNS server",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("Default"),
    "delay": MessageLookupByLibrary.simpleMessage("Delay"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Delay Test"),
    "delayTestCompleted": MessageLookupByLibrary.simpleMessage(
      "Latency test completed",
    ),
    "delayTestFailed": MessageLookupByLibrary.simpleMessage(
      "Unable to test node latency",
    ),
    "delayTestProgress": m3,
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteMultipTip": m4,
    "deleteTip": m5,
    "desc": MessageLookupByLibrary.simpleMessage(
      "A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Destination"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "Destination GeoIP",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "Destination IPASN",
    ),
    "details": m6,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Relying on third-party api is for reference only",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Developer mode"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Developer mode is enabled.",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Direct"),
    "directDomainHelp": MessageLookupByLibrary.simpleMessage(
      "The domain and its subdomains will always connect directly in Rule mode. Reconnect to apply changes.",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("Disable UDP"),
    "disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
    "disconnected": MessageLookupByLibrary.simpleMessage("Disconnected"),
    "disconnecting": MessageLookupByLibrary.simpleMessage("Disconnecting..."),
    "displayedConnections": m7,
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "Update DNS related settings",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS hijacking"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS mode"),
    "dnsProtection": MessageLookupByLibrary.simpleMessage("DNS protection"),
    "dnsProtectionDesc": MessageLookupByLibrary.simpleMessage(
      "Uses app-managed encrypted DNS in TUN mode",
    ),
    "dnsProtectionRequiresTun": MessageLookupByLibrary.simpleMessage(
      "Enable TUN service mode first",
    ),
    "dnsProtectionUpdateFailed": MessageLookupByLibrary.simpleMessage(
      "Could not apply DNS protection. Please try again.",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("Domain"),
    "domainConflict": MessageLookupByLibrary.simpleMessage(
      "This domain already exists in the other rule list",
    ),
    "domainDuplicate": MessageLookupByLibrary.simpleMessage(
      "This domain has already been added",
    ),
    "domainInputHint": MessageLookupByLibrary.simpleMessage(
      "Enter a domain, such as google.com",
    ),
    "domainInvalid": MessageLookupByLibrary.simpleMessage(
      "Enter a valid domain",
    ),
    "domainSavedReconnect": MessageLookupByLibrary.simpleMessage(
      "Saved. Reconnect to apply changes",
    ),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Edit global rules",
    ),
    "editProxy": MessageLookupByLibrary.simpleMessage("Edit proxy"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("Edit proxy group"),
    "editRule": MessageLookupByLibrary.simpleMessage("Edit rule"),
    "editSsid": MessageLookupByLibrary.simpleMessage("Edit SSID"),
    "emptyTip": m8,
    "en": MessageLookupByLibrary.simpleMessage("English"),
    "entries": MessageLookupByLibrary.simpleMessage(" entries"),
    "entriesCount": m9,
    "exclude": MessageLookupByLibrary.simpleMessage("Hidden from recent tasks"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "When the app is in the background, the app is hidden from the recent task",
    ),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage(
      "Exclude proxy filter",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("Exclude SSIDs"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "When connected to an excluded SSID Wi-Fi, the app running state will be automatically switched.",
    ),
    "excludeType": MessageLookupByLibrary.simpleMessage("Exclude type"),
    "existsTip": m10,
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "expand": MessageLookupByLibrary.simpleMessage("Standard"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Expected status"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Export file"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Export logs"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export Success"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Expressive"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "ExternalController",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Once enabled, the Clash kernel can be controlled on port 9090",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("External fetch"),
    "externalLink": MessageLookupByLibrary.simpleMessage("External link"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fakeip filter"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fakeip range"),
    "fallback": MessageLookupByLibrary.simpleMessage("Fallback"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Generally use offshore DNS",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Fallback filter"),
    "featureComingSoon": MessageLookupByLibrary.simpleMessage(
      "This feature will be available in a future version",
    ),
    "feedback": MessageLookupByLibrary.simpleMessage("Feedback"),
    "feedbackDesc": MessageLookupByLibrary.simpleMessage(
      "Send a suggestion or report a problem",
    ),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Fidelity"),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "The file has been modified. Do you want to save the changes?",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Find process"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "There is a certain performance loss after opening",
    ),
    "fontFamily": MessageLookupByLibrary.simpleMessage("FontFamily"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force restart the core?",
    ),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("FruitSalad"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "geoAutoUpdate": MessageLookupByLibrary.simpleMessage("Auto Update"),
    "geoAutoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto Update Interval",
    ),
    "geoAutoUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "Auto update interval must be greater than 0",
    ),
    "geoOptions": MessageLookupByLibrary.simpleMessage("Geo Options"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo Resources"),
    "geoSkipped": m11,
    "geoUpdated": m12,
    "geoUpdating": m13,
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Geo Low Memory Mode",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "Enabling will use the Geo low memory loader",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("Geoip code"),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Go"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Go to configure script",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Do you want to cache the changes?",
    ),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper service unavailable; TUN mode cannot be enabled. Reinstall silent to restore it.",
    ),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Hide from list"),
    "host": MessageLookupByLibrary.simpleMessage("Host"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Add Hosts"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("Hotkey conflict"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Hotkey Management",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Use keyboard to control applications",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("hours"),
    "hoursAgo": m14,
    "hoursCount": m15,
    "icon": MessageLookupByLibrary.simpleMessage("Icon"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("Icon records"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Icon style"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("Icon URL"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Ignore Battery Optimization",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importFile": MessageLookupByLibrary.simpleMessage("Import from file"),
    "importUrl": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "includeAllProxies": MessageLookupByLibrary.simpleMessage(
      "Include all proxies",
    ),
    "includeAllProxiesTip": MessageLookupByLibrary.simpleMessage(
      "Import all proxies not containing proxy groups, additional proxy groups can be added below",
    ),
    "includeAllProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Include all proxy providers",
    ),
    "includeAllProxyProvidersTip": MessageLookupByLibrary.simpleMessage(
      "When enabled, it will override the imported proxy providers",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Long term effective"),
    "init": MessageLookupByLibrary.simpleMessage("Init"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Please enter the correct hotkey",
    ),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "Input proxy group name",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage(
      "Input rule content",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Intelligent selection",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Interval"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Intranet IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Invalid backup file",
    ),
    "invalidPolicy": m16,
    "invalidProxy": m17,
    "invalidProxyProvider": m18,
    "invalidSubRule": m19,
    "ipcidr": MessageLookupByLibrary.simpleMessage("Ipcidr"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "When turned on it will be able to receive IPv6 traffic",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Allow IPv6 inbound",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("Japanese"),
    "justNow": MessageLookupByLibrary.simpleMessage("Just now"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "Tcp keep alive interval",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Key"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "layout": MessageLookupByLibrary.simpleMessage("Layout"),
    "list": MessageLookupByLibrary.simpleMessage("List"),
    "listen": MessageLookupByLibrary.simpleMessage("Listen"),
    "loadTest": MessageLookupByLibrary.simpleMessage("Load test"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Backup local data to local",
    ),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Location Permission",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Location permission was denied, so the current Wi-Fi name cannot be obtained. Please open location permission manually in system settings.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "According to system requirements, obtaining the Wi-Fi name requires you to grant location permission.",
    ),
    "locationPermissionGuide": m20,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Location Permission Required",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Log"),
    "logLevel": MessageLookupByLibrary.simpleMessage("LogLevel"),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Disabling will hide the log entry",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Logs"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("Log capture records"),
    "logsTest": MessageLookupByLibrary.simpleMessage("Logs test"),
    "loopback": MessageLookupByLibrary.simpleMessage("Loopback unlock tool"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "Used for UWP loopback unlocking",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Loose"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("Match source IP"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("Max failed times"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Memory info"),
    "messageTest": MessageLookupByLibrary.simpleMessage("Message test"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "This is a message.",
    ),
    "min": MessageLookupByLibrary.simpleMessage("Min"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("Minimize on exit"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Modify the default system exit event",
    ),
    "minutesAgo": m21,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixed Port"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "monthsAgo": m22,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameserver": MessageLookupByLibrary.simpleMessage("Nameserver"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "For resolving domain",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "Nameserver policy",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Specify the corresponding nameserver policy",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Network"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "Modify network-related settings",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "Network detection",
    ),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "Network exception, please check your connection and try again",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Network speed"),
    "networkType": MessageLookupByLibrary.simpleMessage("Network type"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Neutral"),
    "noCustomDomains": MessageLookupByLibrary.simpleMessage(
      "No custom domains",
    ),
    "noData": MessageLookupByLibrary.simpleMessage("No data"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("No HotKey"),
    "noInfo": MessageLookupByLibrary.simpleMessage("No info"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("No network"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("No network APP"),
    "noRecords": MessageLookupByLibrary.simpleMessage("No records"),
    "noResolve": MessageLookupByLibrary.simpleMessage("No resolve IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "No resolve hostname",
    ),
    "nodeConfigurationUpToDate": MessageLookupByLibrary.simpleMessage(
      "Node configuration is up to date",
    ),
    "nodeConfigurationUpdated": m23,
    "none": MessageLookupByLibrary.simpleMessage("none"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "The current proxy group cannot be selected.",
    ),
    "nullTip": m24,
    "numberTip": m25,
    "onDemand": MessageLookupByLibrary.simpleMessage("On Demand"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "Configure the program running state for specific scenarios",
    ),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Icon"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Only statistics proxy",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "When turned on, only statistics proxy traffic",
    ),
    "optimalPerformance": MessageLookupByLibrary.simpleMessage(
      "Optimal performance",
    ),
    "optional": MessageLookupByLibrary.simpleMessage("Optional"),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Other contributors",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Outbound mode"),
    "override": MessageLookupByLibrary.simpleMessage("Override"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("Override Dns"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Turning it on will override the DNS options in the profile",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage("Override mode"),
    "overrideScript": MessageLookupByLibrary.simpleMessage("Override script"),
    "overwriteTypeCustom": MessageLookupByLibrary.simpleMessage("Custom"),
    "overwriteTypeCustomDesc": MessageLookupByLibrary.simpleMessage(
      "Custom mode, fully customize proxy groups and rules",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("Palette"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "paste": MessageLookupByLibrary.simpleMessage("Paste"),
    "pauseRefresh": MessageLookupByLibrary.simpleMessage("Pause refresh"),
    "personalAppVersion": MessageLookupByLibrary.simpleMessage("App version"),
    "personalCenter": MessageLookupByLibrary.simpleMessage("Profile"),
    "personalChangePassword": MessageLookupByLibrary.simpleMessage(
      "Change password",
    ),
    "personalChangePasswordFailed": MessageLookupByLibrary.simpleMessage(
      "Unable to change password. Check your current password and try again.",
    ),
    "personalChangePasswordSuccess": MessageLookupByLibrary.simpleMessage(
      "Password changed",
    ),
    "personalConfirmChange": MessageLookupByLibrary.simpleMessage(
      "Confirm change",
    ),
    "personalLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Unable to load profile",
    ),
    "personalLogout": MessageLookupByLibrary.simpleMessage("Log out"),
    "personalLogoutDescription": MessageLookupByLibrary.simpleMessage(
      "Logging out will stop the current proxy connection.",
    ),
    "personalNoActivePlan": MessageLookupByLibrary.simpleMessage(
      "No active plan",
    ),
    "personalOldPassword": MessageLookupByLibrary.simpleMessage(
      "Current password",
    ),
    "personalOrders": MessageLookupByLibrary.simpleMessage("Order list"),
    "personalPasswordLength": MessageLookupByLibrary.simpleMessage(
      "Password must be between 8 and 72 bytes",
    ),
    "personalPlan": MessageLookupByLibrary.simpleMessage("My plan"),
    "personalRemainingDays": MessageLookupByLibrary.simpleMessage(
      "Days remaining",
    ),
    "personalRemainingTraffic": MessageLookupByLibrary.simpleMessage(
      "Traffic remaining",
    ),
    "personalUnlimitedDevices": MessageLookupByLibrary.simpleMessage(
      "Unlimited devices",
    ),
    "personalUnlimitedSpeed": MessageLookupByLibrary.simpleMessage(
      "Unlimited speed",
    ),
    "pingEstimate": MessageLookupByLibrary.simpleMessage(
      "Pings are estimated based on your current location.",
    ),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Please bind WebDAV",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Please enter a script name",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "Please enter the admin password",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Please upload a valid QR code",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a different port",
    ),
    "portTip": m26,
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Prioritize the use of DOH\'s http/3",
    ),
    "preparingNodes": MessageLookupByLibrary.simpleMessage(
      "Preparing nodes...",
    ),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Prerequisites"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Please press the keyboard.",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "process": MessageLookupByLibrary.simpleMessage("Process"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "The profile has been modified. Do you want to disable auto update?",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profiles"),
    "project": MessageLookupByLibrary.simpleMessage("Project"),
    "providers": MessageLookupByLibrary.simpleMessage("Providers"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxiesEmpty": MessageLookupByLibrary.simpleMessage("Proxies is empty"),
    "proxyAndNetwork": MessageLookupByLibrary.simpleMessage(
      "Proxy and network",
    ),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Proxy chains"),
    "proxyDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "Detected selected proxies are abnormal",
    ),
    "proxyDomainHelp": MessageLookupByLibrary.simpleMessage(
      "The domain and its subdomains will always use the proxy in Rule mode. Reconnect to apply changes.",
    ),
    "proxyFilter": MessageLookupByLibrary.simpleMessage("Proxy filter"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proxy group"),
    "proxyGroupDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "Detected current proxy group is abnormal",
    ),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy group is empty",
    ),
    "proxyGroupNameDuplicate": MessageLookupByLibrary.simpleMessage(
      "Proxy group name is duplicate",
    ),
    "proxyGroupNameEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy group name cannot be empty",
    ),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("Proxy nameserver"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Domain for resolving proxy nodes",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("ProxyPort"),
    "proxyProviderDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "Detected selected proxy providers are abnormal",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Proxy providers"),
    "proxyProvidersEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy providers is empty",
    ),
    "proxyProvidersNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy providers cannot be empty",
    ),
    "proxyRoute": MessageLookupByLibrary.simpleMessage("Proxy"),
    "proxyRules": MessageLookupByLibrary.simpleMessage("Proxy rules"),
    "proxyType": MessageLookupByLibrary.simpleMessage("Proxy type"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Prune cache"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Pure black mode"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR code"),
    "quickFill": MessageLookupByLibrary.simpleMessage("Quick fill"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Rainbow"),
    "recommendedNode": MessageLookupByLibrary.simpleMessage("Recommended node"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir Port"),
    "redo": MessageLookupByLibrary.simpleMessage("redo"),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "refreshNodeConfiguration": MessageLookupByLibrary.simpleMessage(
      "Refresh node configuration",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("Remote"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Backup local data to WebDAV",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Remote destination",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "rename": MessageLookupByLibrary.simpleMessage("Rename"),
    "request": MessageLookupByLibrary.simpleMessage("Request"),
    "requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "View recently request records",
    ),
    "requiredUpdateTitle": MessageLookupByLibrary.simpleMessage(
      "Update required",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "The current page has changes. Are you sure you want to reset?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("Make sure to reset"),
    "resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "External resource related info",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Respect rules"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS connection following rules, need to configure proxy-server-nameserver",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("Restart"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to restart the core?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restore"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("Restore all data"),
    "restoreException": MessageLookupByLibrary.simpleMessage(
      "Recovery exception",
    ),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data via file",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data via WebDAV",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("Restore strategy"),
    "restoreStrategy_compatible": MessageLookupByLibrary.simpleMessage(
      "Compatible",
    ),
    "restoreStrategy_override": MessageLookupByLibrary.simpleMessage(
      "Override",
    ),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("Restore success"),
    "resumeRefresh": MessageLookupByLibrary.simpleMessage("Resume refresh"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Route address"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "Config listen route address",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("Route mode"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage(
      "Bypass private route address",
    ),
    "routeMode_config": MessageLookupByLibrary.simpleMessage("Use config"),
    "ru": MessageLookupByLibrary.simpleMessage("Russian"),
    "rule": MessageLookupByLibrary.simpleMessage("Rule"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage(
      "Logical rule AND",
    ),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Match full domain",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "Match domain keyword",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Wildcard match, only supports * and ? wildcards",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match domain suffix",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "Match DSCP mark (tproxy udp inbound only)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match request target port range",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Match IP\'s country code",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Match domains within Geosite",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "Match inbound name",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match inbound port",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "Match inbound type",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "Match inbound username, supports multiple usernames separated by /",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Match IP\'s ASN",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "Match IP address range, IP-CIDR6 is just an alias",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Match IP address range",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match IP suffix range",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "Match all requests, no conditions needed",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Match TCP or UDP",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage(
      "Logical rule NOT",
    ),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("Logical rule OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "Match using process name, matches package name on Android",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Match using process name regex, matches package name on Android",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Match using full process path",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Match using process path regex",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Reference rule set, requires rule-providers configuration",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Match source IP\'s country code",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Match source IP\'s ASN",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Match source IP address range",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match source IP suffix range",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match request source port range",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Match to sub-rule, pay attention to the use of parentheses",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Match Linux USER ID",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("Rule is empty"),
    "ruleName": MessageLookupByLibrary.simpleMessage("Rule name"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Rule providers"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Rule set"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Rule target"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "Do you want to save the changes?",
    ),
    "script": MessageLookupByLibrary.simpleMessage("Script"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Script mode, use external extension scripts, provide one-click override configuration capability",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "seconds": MessageLookupByLibrary.simpleMessage("Seconds"),
    "secondsCount": m27,
    "selectAll": MessageLookupByLibrary.simpleMessage("Select all"),
    "selectProxies": MessageLookupByLibrary.simpleMessage("Select proxies"),
    "selectProxy": MessageLookupByLibrary.simpleMessage("Select a proxy"),
    "selectProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Select proxy providers",
    ),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Please select rule set",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Please select split strategy",
    ),
    "selectSubRule": MessageLookupByLibrary.simpleMessage(
      "Please select sub rule",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "selectedCountTitle": m28,
    "serverProfileLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Unable to load proxy configuration",
    ),
    "serverProfileSyncFailed": MessageLookupByLibrary.simpleMessage(
      "Unable to update proxy configuration",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "shop": MessageLookupByLibrary.simpleMessage("Plans"),
    "shopAll": MessageLookupByLibrary.simpleMessage("All"),
    "shopBandwidth": MessageLookupByLibrary.simpleMessage("Bandwidth"),
    "shopBandwidthMbps": m29,
    "shopBandwidthShort": m30,
    "shopBuy": MessageLookupByLibrary.simpleMessage("Buy"),
    "shopDayCount": m31,
    "shopDeviceCount": m32,
    "shopDevices": MessageLookupByLibrary.simpleMessage("Devices"),
    "shopIntroDescription": MessageLookupByLibrary.simpleMessage(
      "Secure, stable access worldwide",
    ),
    "shopIntroTitle": MessageLookupByLibrary.simpleMessage(
      "Choose a plan that fits you",
    ),
    "shopLoadFailed": MessageLookupByLibrary.simpleMessage(
      "Unable to load plans",
    ),
    "shopNoPlans": MessageLookupByLibrary.simpleMessage("No plans available"),
    "shopPlanTitle": MessageLookupByLibrary.simpleMessage("Plans"),
    "shopRecommended": MessageLookupByLibrary.simpleMessage("Recommended"),
    "shopTime": MessageLookupByLibrary.simpleMessage("By time"),
    "shopTraffic": MessageLookupByLibrary.simpleMessage("By traffic"),
    "shopTrafficGigabytes": m33,
    "shopTrafficLabel": MessageLookupByLibrary.simpleMessage("Traffic"),
    "shopUnlimited": MessageLookupByLibrary.simpleMessage("Unlimited"),
    "shopUnlimitedShort": MessageLookupByLibrary.simpleMessage("∞"),
    "shopValidity": MessageLookupByLibrary.simpleMessage("Validity"),
    "show": MessageLookupByLibrary.simpleMessage("Show"),
    "shrink": MessageLookupByLibrary.simpleMessage("Shrink"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("SilentLaunch"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Start in the background",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socks Port"),
    "sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "source": MessageLookupByLibrary.simpleMessage("Source"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Source IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Special proxy"),
    "specialRules": MessageLookupByLibrary.simpleMessage("special rules"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("Speed statistics"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("Split strategy"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Split strategy cannot be empty",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSIDs is empty"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Stack mode"),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Standard mode, override basic configuration, provide simple rule addition capability",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Starting VPN..."),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "System DNS will be used when turned off",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Stopping VPN..."),
    "style": MessageLookupByLibrary.simpleMessage("Style"),
    "subRule": MessageLookupByLibrary.simpleMessage("Sub rule"),
    "subRuleEmpty": MessageLookupByLibrary.simpleMessage("Sub rule is empty"),
    "subRuleNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Sub rule cannot be empty",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "subscriptionPurchasePlan": MessageLookupByLibrary.simpleMessage(
      "Purchase a plan",
    ),
    "subscriptionRefresh": MessageLookupByLibrary.simpleMessage(
      "Already purchased? Tap to refresh",
    ),
    "subscriptionUnavailableDescription": MessageLookupByLibrary.simpleMessage(
      "Purchase a plan to use the acceleration service",
    ),
    "subscriptionUnavailableTitle": MessageLookupByLibrary.simpleMessage(
      "You don\'t have an active subscription plan",
    ),
    "suspended": MessageLookupByLibrary.simpleMessage("Suspended..."),
    "switchToSystemProxyDescription": MessageLookupByLibrary.simpleMessage(
      "TUN is handling system traffic. Turn off TUN and switch to the system proxy?",
    ),
    "sync": MessageLookupByLibrary.simpleMessage("Sync"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "systemApp": MessageLookupByLibrary.simpleMessage("System APP"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Attach HTTP proxy to VpnService",
    ),
    "systemSettings": MessageLookupByLibrary.simpleMessage("System settings"),
    "tab": MessageLookupByLibrary.simpleMessage("Tab"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Tab animation"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Effective only in mobile view",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("Tap to authorize"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP concurrent"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "Enabling it will allow TCP concurrency",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage("Test interval"),
    "testUrl": MessageLookupByLibrary.simpleMessage("Test url"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("Test when used"),
    "textScale": MessageLookupByLibrary.simpleMessage("Text Scaling"),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Theme color"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Set dark mode,adjust the color",
    ),
    "tight": MessageLookupByLibrary.simpleMessage("Tight"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "timeout": MessageLookupByLibrary.simpleMessage("Timeout"),
    "tip": MessageLookupByLibrary.simpleMessage("tip"),
    "toggle": MessageLookupByLibrary.simpleMessage("Toggle"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("TonalSpot"),
    "tools": MessageLookupByLibrary.simpleMessage("Tools"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxy Port"),
    "trafficCapture": MessageLookupByLibrary.simpleMessage("Traffic capture"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Traffic usage"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "only effective in administrator mode",
    ),
    "tunOwnsSystemTraffic": MessageLookupByLibrary.simpleMessage(
      "TUN is handling system traffic",
    ),
    "tunServiceEnableFailed": MessageLookupByLibrary.simpleMessage(
      "Could not apply TUN service mode. Try again and approve administrator access when enabling it for the first time.",
    ),
    "tunServiceMode": MessageLookupByLibrary.simpleMessage(
      "Service mode (TUN)",
    ),
    "tunServiceModeDesc": MessageLookupByLibrary.simpleMessage(
      "Routes system traffic through a virtual network adapter",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Turn Off"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Turn On"),
    "undo": MessageLookupByLibrary.simpleMessage("undo"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Unified delay"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "Remove extra delays such as handshaking",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Unknown network error",
    ),
    "unnamed": MessageLookupByLibrary.simpleMessage("Unnamed"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "updateAvailableTitle": MessageLookupByLibrary.simpleMessage(
      "Update available",
    ),
    "updateCancelDownload": MessageLookupByLibrary.simpleMessage(
      "Cancel download",
    ),
    "updateCheckFailed": MessageLookupByLibrary.simpleMessage(
      "Unable to check for updates. Please check your network.",
    ),
    "updateChecking": MessageLookupByLibrary.simpleMessage(
      "Checking for updates…",
    ),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Unable to prepare the update. Please try again.",
    ),
    "updateDownloading": MessageLookupByLibrary.simpleMessage(
      "Downloading update…",
    ),
    "updateInstallNow": MessageLookupByLibrary.simpleMessage("Install now"),
    "updateInstallPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Allow this app to install updates, then tap Install again.",
    ),
    "updateInstallerOpened": MessageLookupByLibrary.simpleMessage(
      "Installer opened",
    ),
    "updateLater": MessageLookupByLibrary.simpleMessage("Later"),
    "updateNow": MessageLookupByLibrary.simpleMessage("Update now"),
    "updatePackageSize": MessageLookupByLibrary.simpleMessage("Download size"),
    "updateReadyToInstall": MessageLookupByLibrary.simpleMessage(
      "Update ready to install",
    ),
    "updateUpToDate": MessageLookupByLibrary.simpleMessage(
      "You are using the latest version",
    ),
    "updateVerifying": MessageLookupByLibrary.simpleMessage(
      "Verifying update…",
    ),
    "updateVersion": m34,
    "upload": MessageLookupByLibrary.simpleMessage("Upload"),
    "uploadDiagnosticLogs": MessageLookupByLibrary.simpleMessage(
      "Upload diagnostic logs",
    ),
    "uploadDiagnosticLogsDesc": MessageLookupByLibrary.simpleMessage(
      "Send runtime logs to help diagnose a problem",
    ),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlTip": m35,
    "useHosts": MessageLookupByLibrary.simpleMessage("Use hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("Use system hosts"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "value": MessageLookupByLibrary.simpleMessage("Value"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Vibrant"),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN configuration change detected",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Auto routes all system traffic through VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Changes take effect after restarting the VPN",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV configuration",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Whitelist mode"),
    "yearsAgo": m36,
    "zh_CN": MessageLookupByLibrary.simpleMessage("Simplified Chinese"),
  };
}
