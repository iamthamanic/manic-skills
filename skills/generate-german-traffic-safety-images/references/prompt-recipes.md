# Prompt architecture and recipes

## Contents

- Core architecture
- Generic mobile no-stopping zone
- Website hero variant
- Road-work traffic-safety scene
- Existing-image correction
- Targeted iteration

## Core architecture

Use this order. Remove lines that do not help the specific image.

```text
Use case: photorealistic-natural
Asset type: <website hero / service section / editorial photo / documentation photo / social ad>
Scene family: <mobile no-stopping zone / road-work traffic safety / sign documentation>
Primary request: <one-sentence outcome>

Scene and road geometry: <country, road class, urban/rural setting, traffic direction, curb, sidewalk, parking strip, cycle path, junctions>
Traffic-control purpose: <what the temporary arrangement achieves>
Sign and zone logic: <sign identities, same-side relationship, beginning/end relationship, exact supplementary text if supplied>
Equipment: <supports, posts, barriers, delineators, lamps, cones, signals; only what is justified>
People and activity: <workers, pedestrians, vehicles, actions, PPE; or explicitly none>

Physical realism: <materials, scale, ground contact, contact shadows, reflectivity, wear, dirt, asphalt and curb texture>
Style/medium: photorealistic contemporary documentary commercial photography, not a 3D render
Camera: <lens character, eye level, depth of field, exposure behavior>
Composition/framing: <wide/medium/detail, focal hierarchy, negative space only if needed>
Lighting/weather: <time, sky, light direction and softness, consistent surface condition>
Color response: neutral realistic color, restrained contrast, natural highlight roll-off

Text (verbatim): "<only supplied exact text>"
Constraints: <must-have geometry, identities, invariants, and intended-use constraints>
Avoid: <specific recurring artifacts and unwanted elements>
```

The accuracy comes from three prompt layers:

1. `Sign and zone logic` controls regulatory plausibility.
2. `Physical realism` controls object construction and contact with the real world.
3. `Camera`, `lighting`, and `color response` suppress synthetic CGI aesthetics.

## Generic mobile no-stopping zone

Use this for a request such as `Erstell mir eine Halteverbotszone`.

```text
Use case: photorealistic-natural
Asset type: service website image
Scene family: mobile no-stopping zone
Primary request: a technically plausible temporary no-stopping zone on a contemporary German inner-city residential street

Scene and road geometry: right-hand traffic; quiet two-way urban street; continuous sidewalk and curbside parking strip; ordinary apartment buildings, street trees, and a few naturally parked cars outside the reserved section
Traffic-control purpose: reserve a clearly understandable empty curb section for a temporary service operation
Sign and zone logic: two German mobile Zeichen 283 absolute no-stopping sign assemblies on the same curb side, one prominent in the foreground and the second farther down the curb; beginning and end indicators consistent with the roadway and the sign-face orientation; white supplementary activation panels below the circular signs, present but too small to read
Equipment: straight galvanized temporary posts secured in heavy low black rectangular base plates resting fully on the paving; plausible clamps and spacing; no unrelated traffic-control equipment
People and activity: no workers, no active construction, sparse normal street life only

Physical realism: correct sign proportions; reflective sign film with restrained highlights; fine scratches and edge wear; galvanized-metal grain; scuffed rubber or recycled-plastic bases; realistic curb chips, patched asphalt, dust, leaves, contact shadows, and occlusion
Style/medium: photorealistic contemporary documentary commercial photography, indistinguishable from a real on-location photograph, not a 3D render
Camera: natural 40 mm full-frame lens character at adult eye level; moderate depth of field resembling f/6.3; foreground sign crisp, second sign and curb section still recognizable; realistic perspective and highlight roll-off
Composition/framing: landscape medium-wide view; foreground sign assembly as the primary anchor; empty reserved curb leads into depth toward the second sign; balanced ordinary street context
Lighting/weather: bright overcast daylight with soft directional shadows; dry surfaces; neutral white balance
Color response: restrained contrast and saturation, natural blues and reds, subtle sensor grain, no cinematic color cast

Constraints: use Zeichen 283 with a red cross, not Zeichen 286 with one slash; both boundary signs belong to the same curb section; all posts enter real bases; all bases touch the ground; keep sign geometry, curb, parked cars, and traffic direction internally consistent; no prominent readable sign text
Avoid: malformed or invented road signs; contradictory arrows; signs on opposite road sides; floating bases; bent or forked poles; duplicate signs or cars; gibberish text; company logos; authority seals; license-plate detail; cones; barriers; construction machinery; watermarks; HDR halos; extreme bokeh; fisheye distortion; staged stock-photo smiles; CGI cleanliness
```

## Website hero variant

Start from the generic recipe and change only the composition block:

```text
Asset type: landing-page hero image
Composition/framing: wide 16:9 environmental photograph; no embedded text; keep the sign assembly and reserved curb in the visually active half selected by the page layout; leave calm, low-detail negative space in the copy area; preserve enough street context to explain the service
Constraints: no headline, button, logo, or typography inside the image
```

Do not guess left or right placement when the surrounding page layout is available; inspect the layout first.

## Road-work traffic-safety scene

```text
Use case: photorealistic-natural
Asset type: traffic-safety service section image
Scene family: road-work traffic safety
Primary request: a credible short-duration urban road-maintenance work area in Germany

Scene and road geometry: contemporary inner-city two-lane street with right-hand traffic; localized maintenance area at the curb; unobstructed view for approaching traffic; coherent sidewalk and vehicle path
Traffic-control purpose: warn approaching traffic and guide it safely past a small protected work area
Sign and zone logic: only the temporary German signs justified by the visible road geometry; every face oriented toward the traffic it addresses; no contradictory instructions
Equipment: stable temporary bases; a restrained sequence of red-and-white guidance devices and amber warning lights protecting the work area; cones only for localized short-duration guidance; no portable signal unless opposing traffic must alternate
People and activity: one or two road workers performing a concrete maintenance task inside the protected area, wearing plausible high-visibility clothing with retroreflective strips and task-appropriate PPE; natural posture and tool grip

Physical realism: correct scale and spacing; galvanized metal, reflective sheeting, molded plastic, scuffed bases, dust, asphalt repairs, realistic wheel and foot contact, coherent shadows and occlusion
Style/medium: photorealistic documentary commercial photography, observational rather than staged, not a 3D render
Camera: 35 mm full-frame lens character at eye level; moderate depth of field; safety layout readable from foreground to work area
Composition/framing: landscape medium-wide view with a clear approach path, protected work zone, and ordinary urban context
Lighting/weather: neutral morning daylight, soft shadows, dry pavement, consistent reflections

Constraints: keep workers inside the protected space; use only equipment justified by the task; preserve a credible travel path; make all supports physically stable
Avoid: equipment-catalogue clutter; random signs; contradictory arrows; workers standing unprotected in live traffic; floating lamps or barriers; cloned devices; malformed anatomy; dramatic emergency lighting; logos; gibberish text; watermarks; oversaturated red and orange; CGI sheen
```

## Existing-image correction

```text
Use case: precise-object-edit
Input images: Image 1: edit target; Image 2: equipment reference if supplied
Primary request: correct only the temporary German traffic-control equipment and its physical placement
Change: <exactly list malformed signs, arrows, panels, posts, bases, barriers, lamps, or artifacts>
Invariants: preserve the street, buildings, vehicles, people, camera position, crop, weather, lighting direction, shadows, color response, and all untouched objects
Technical constraints: <correct sign identity and scene relationship>
Avoid: redesigning the scene; moving unrelated objects; adding equipment; changing architecture; changing time of day; introducing text, logos, or watermarks
```

## Targeted iteration

Use one correction at a time and repeat invariants:

```text
Change only <single defect>. Preserve all other signs, supplementary panels, posts, bases, curb geometry, vehicles, architecture, camera position, crop, lighting, weather, and color exactly. The corrected object must match the same perspective, scale, material response, wear, contact shadow, and depth of field. Add nothing else.
```
