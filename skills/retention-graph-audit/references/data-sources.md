# Getting retention curves into a product

For Business Ultra / dashboards that want to run `@retention-graph-audit` automatically.

## Preferred ingest shapes

```json
{
  "platform": "youtube",
  "videoId": "…",
  "durationSec": 45,
  "retentionCurve": [
    { "tSec": 0, "retentionPct": 100 },
    { "tSec": 1, "retentionPct": 86 }
  ],
  "source": "youtube_analytics_api"
}
```

YouTube often returns ratios instead of seconds:

- `elapsedVideoTimeRatio` ∈ (0, 1]
- `audienceWatchRatio` (can be >1 on Shorts due to rewatches)

Map `tSec = ratio * durationSec`. Cap display retention at 100% for pattern labels if desired, but keep raw ratio for analysis.

## Platform paths

### YouTube — real curve (API)

- YouTube Analytics `reports.query`
- `dimensions=elapsedVideoTimeRatio`
- `metrics=audienceWatchRatio,relativeRetentionPerformance`
- `filters=video==VIDEO_ID` (one video per request)

Open-source reference: `davisj95/YTAnalytics` (`video_audience_retention`). Managed wrappers (e.g. Zernio) expose `retentionCurve[]`.

### TikTok — real curve (Business Organic Insights)

- Requires TikTok **Business** account + Video Insights scopes
- Connector fields seen in the wild: `video_view_retention_second` + `video_view_retention_percentage` (or packed `video_view_retention`)
- Public TikTok Open API / Metricool post lists: **not** a curve source

Verify live with one owned video before building BU around it.

### Instagram — no official curve API

Graph API media insights: `ig_reels_avg_watch_time`, `ig_reels_video_view_total_time`, `reels_skip_rate` — **no** per-second series.

Practical options:

1. User uploads Insights screenshot → digitize curve (chart digitizer / vision JSON)
2. Browser automation of own Insights (fragile, ToS risk) — last resort
3. Coarse audit only (skip rate + avg watch / duration) with `confidence: low`

### Aggregators (Metricool, etc.)

Typically expose avg watch / retention **%** scalars. Use for KPIs, not cliff timestamps.

## Screenshot import checklist

- Capture the graph **with x-axis time labels**
- Refuse imports that do not match the video duration
- Store digitized points; discard the image if privacy policy requires
- Mark `source: screenshot_digitized` and never mix into model training without consent
