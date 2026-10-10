# Source Fidelity, Privacy, and Platform Reality

## Provenance

- Source inspiration: Instagram Reel https://www.instagram.com/reel/DeUlQTQxv5O/ (52-second observational walkthrough captured 2026-10-11).
- The narrator asserts they reverse-engineered Duolingo and describes an alleged `churn/` folder, `latest_tomorrow_prob`, app-open sources, session/error counters, Wi-Fi network fingerprinting, ringer state, and message categories related to streaks, friends and leaderboards.
- These are **claims made by the narrator and on-screen fragments**, not authenticated current Duolingo source code or independently verified implementation details. Do not present package names, fields, algorithms, or specific monitoring behavior as established facts.

## Independently published evidence

Duolingo publicly describes using personalized language-learning reminder templates, streak and language features, experiments, and a bandit algorithm to choose notifications based on lesson-completion outcomes. It also explicitly accounts for recency/novelty of repeated messages:

- Duolingo Engineering/Research, "How the Duolingo Owl Decides What Notification To Send": https://blog.duolingo.com/hi-its-duo-the-ai-behind-the-meme/

This supports the **general pattern** of personalized, experimentally evaluated reminders. It does **not** validate every reverse-engineering allegation in the reel, and it is not a description of Duolingo's entire current production stack.

## Device and platform constraints

- Android notification permission, Wi-Fi permissions, available identifiers, and background execution vary by OS version. Do not assume an app can read ringer state, scan connected networks, or freely send push.
- Google Android documentation: https://developer.android.com/develop/connectivity/wifi/wifi-permissions
- Android 13+ has `NEARBY_WIFI_DEVICES` for some Wi-Fi operations, but certain APIs still require location permissions; deriving physical location changes the permission and privacy analysis. Hashing Wi-Fi identifiers is not anonymization by itself when the value still permits linking observations.
- Do not use Wi-Fi network identifiers, inferred home location, silent/ringer state, geofences, or hidden device fingerprinting as default retention features. Use user-selected quiet hours, preferred reminders and first-party activity instead.

## EU/Germany privacy gate

Profile-building from app usage and targeting of reminders can involve personal data processing. Document data purpose, legal basis, transparency, retention, profiling risks, recipients, data-subject rights, and deletion. Assess ePrivacy rules and direct-marketing requirements separately from the OS notification permission. Avoid asserting blanket consent requirements or exemptions without contextual legal review.

- European Data Protection Board topic overview on profiling and tracking: https://www.edpb.europa.eu/topics/ai-and-technology/automated-decision-making-profiling-and-online-tracking_en

Before a targeted messaging implementation, check:

1. Purpose limitation and necessity for every field, including crash/error data.
2. Actual lawful basis, notification category, opt-in/opt-out semantics, and proof of notice.
3. Strict separation of security/operational logs, analytics, and marketing use.
4. Data minimization, bounded retention, deletion, user preferences, and access controls.
5. No sensitive-category inference, undisclosed location or Wi-Fi fingerprinting, or manipulative targeting.
6. Independent technical check of the OS, SDK, and provider capabilities before writing code.

If uncertain, describe the missing approval/evidence and propose a non-invasive implementation path; do not implement speculative invasive tracking.
