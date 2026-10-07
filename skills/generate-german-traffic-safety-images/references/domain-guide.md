# German traffic-safety domain guide

## Contents

- Regulatory baseline
- Mobile no-stopping zones
- Road-work traffic safety
- Physical and photographic realism
- Failure patterns
- Source links

## Regulatory baseline

Use this guide for visual plausibility, not field planning.

- StVO Anlage 2 defines Zeichen 283 as an absolute no-stopping restriction and Zeichen 286 as a restricted no-stopping restriction.
- The restriction applies on the roadside where the sign stands. Mobile temporary signs can supersede signs that otherwise permit parking.
- The beginning of a restricted stretch may be marked by a horizontal white arrow pointing toward the roadway; the end may be marked by one pointing away. A repeated sign can carry opposing arrowheads. Interpret this relationship from the actual curb side and sign-face orientation; never hard-code `arrow left` or `arrow right` without scene geometry.
- RSA 21 replaced RSA 95 and distinguishes inner-city roads, rural roads, and motorways as well as short- and longer-duration work zones.
- Work affecting road traffic requires an authority-defined arrangement. Under StVO section 45(6), contractors must obtain the relevant order before work begins and construction contractors submit a traffic-sign plan.

Never turn a generic image prompt into measured placement instructions, safety distances, or a field-ready plan. Those depend on the approved arrangement, road class, duration, speed, geometry, local authority, and current rules.

## Mobile no-stopping zones

### Default visual grammar

For the colloquial request `Halteverbotszone`, default to a temporary stretch using Zeichen 283:

- blue circular face;
- red border;
- two red diagonal bars forming a red cross;
- white directional arrow integrated only where needed to denote beginning, continuation, or end;
- white rectangular supplementary panel below the circular sign for the activation period or authorized qualifier;
- galvanized temporary post and secure connection;
- heavy low black temporary base plate resting fully on a stable surface;
- a second boundary assembly visible farther along the same curb where the composition allows it.

Use Zeichen 286 only when the request specifically calls for restricted no-stopping or its loading and short-stay exceptions. Its face uses one red diagonal bar rather than the red cross of Zeichen 283.

### Spatial logic

- Keep both boundary signs on the same side of the road as the reserved curb section.
- Align sign faces for the traffic that must perceive them; do not show random fronts and backs.
- Keep the reserved section visually understandable through curb line, empty parking space, perspective, or the second sign.
- Do not place a sign in the middle of a live lane, floating above a base, fused into a parked car, or clipping through the curb.
- Do not use traffic cones as the primary legal definition of a temporary no-stopping stretch. Add them only when the requested physical operation plausibly needs a work boundary.
- Do not add an excavation, barrier fence, work truck, crane, skip, or worker to a simple curb reservation unless the user requests that activity.

### Supplementary panels and text

- Render exact date, time, reason, or qualifier verbatim only when the user supplies it or requests a deliberate example.
- When no exact text is supplied, keep the panel present but small, angled, partially occluded, or outside the focus plane. Do not invent prominent readable dates or official wording.
- Never add company logos, permit seals, order numbers, phone numbers, QR codes, or decorative slogans unless provided.

## Road-work traffic safety

First choose the road setting and duration. Equipment appropriate for a short urban maintenance operation can be implausible on a motorway or a longer-duration excavation.

Use only elements justified by the scene:

- warning sign for road works when an approaching road user needs it;
- red-and-white delineators or barriers to lead or block movement;
- amber warning lights where active visibility is needed;
- cones for short-duration guidance or localized protection;
- stable temporary bases and posts;
- portable signals only when alternate traffic control is actually implied;
- temporary pedestrian or cycle routing when the original path is affected;
- temporary protective devices when the scene calls for separation rather than simple guidance.

Avoid the `equipment catalogue` error: one scene should not automatically contain a warning triangle, every type of barrier, cones, beacons, temporary signals, a truck, an excavator, and several unrelated signs.

When workers appear:

- use plausible high-visibility workwear with retroreflective strips;
- use safety footwear and task-appropriate head, hand, eye, or hearing protection;
- place workers inside a protected work area, not casually in live traffic;
- maintain natural posture, tool grip, anatomy, and interaction with the task.

## Physical and photographic realism

### Environment

- Use contemporary German road design: right-hand traffic, coherent lane markings, curbs, drainage, sidewalk paving, street furniture, vehicles, and architecture.
- Keep license plates unreadable unless the user requires an exact fictional plate.
- Use imperfect everyday conditions: light dust, small scratches, galvanized-metal texture, rubber or recycled-plastic base texture, worn asphalt, patched pavement, leaves, minor grime, and subtle edge wear.
- Match wetness, sky, reflections, and shadow softness. Do not combine dry dust with mirror-wet asphalt unless the scene explains it.

### Camera

For a general website or editorial image, prefer:

- eye level around a standing adult's viewpoint;
- natural 35–50 mm full-frame lens character;
- moderate depth of field, usually resembling f/5.6–f/8 rather than extreme portrait blur;
- neutral color response and soft daylight;
- realistic highlight roll-off on reflective sign faces;
- enough depth for the curb section and second boundary sign to remain intelligible.

Use 24–35 mm only for a wider environmental hero image. Use 50–85 mm for equipment detail, but avoid making regulatory context unreadable. Avoid fisheye distortion, drone angles, miniature tilt-shift, extreme low angles, aggressive teal-orange grading, HDR halos, sterile 3D-render smoothness, and excessive background bokeh.

### Commercial composition

- Reserve negative space only where website copy will actually sit.
- Do not put generated text inside the photograph for a website hero unless explicitly requested.
- Keep the safety equipment visually important without making the street look staged or deserted beyond plausibility.
- Use one clear focal hierarchy: foreground assembly, reserved or protected stretch, contextual street.

## Failure patterns

Reject these outputs:

- Zeichen 283 drawn with one slash, or Zeichen 286 drawn with a cross;
- red, blue, or white geometry melting into a novel non-German sign;
- beginning and end indicators pointing inconsistently with the roadway;
- two boundary signs on opposite sides of the road for one curb section;
- supplementary panels with large nonsense text;
- poles that bend, fork, disappear, or do not enter a base;
- bases that float, balance on an edge, repeat unnaturally, or fuse into the sidewalk;
- barriers with incoherent stripe directions or lamps detached from the device;
- identical cloned pedestrians, cars, trees, signs, or windows;
- pristine studio equipment pasted into a gritty street;
- visible brand names, watermarks, or invented authority marks;
- dramatic emergency atmosphere when the request is ordinary traffic management.

## Source links

Check these again when the task depends on current law or technical rules:

- StVO Anlage 2, including Zeichen 283 and 286: https://www.gesetze-im-internet.de/stvo_2013/anlage_2.html
- StVO section 45, including authority and contractor obligations: https://www.gesetze-im-internet.de/stvo_2013/__45.html
- Federal introduction of RSA 21, ARS 24/2021: https://www.bmv.de/SharedDocs/DE/Anlage/StB/ars-aktuell/allgemeines-rundschreiben-strassenbau-2021-24.pdf?__blob=publicationFile
- FGSV RSA 21 overview and public rule-plan access: https://www.fgsv-verlag.de/rsa-21
