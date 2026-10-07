---
name: generate-german-traffic-safety-images
description: >-
  Generate or edit technically plausible, photorealistic images of German mobile no-stopping zones and road-work traffic safety. Use for requests involving Halteverbotszone, mobiles Halteverbot, Parkverbotszone, Zeichen 283 or 286, Verkehrssicherung, Baustellenabsicherung, Verkehrszeichen, Leitbaken, Absperrschranken, Warnleuchten, traffic-management website imagery, or realistic German street-safety scenes. Apply it to new images, variants, and corrections of existing images. Do not use it to certify or replace an official Verkehrszeichenplan or a traffic authority's order.
---
# Generate German Traffic Safety Images

Create credible German traffic-safety photography by combining correct scene logic with restrained documentary realism. Treat regulatory plausibility, physical construction, and photographic naturalism as separate checks.

## Load the references

- Read `references/domain-guide.md` for every task before choosing signs, barriers, or placement.
- Read `references/prompt-recipes.md` before writing the generation or edit prompt.
- For an actual work-zone arrangement, legal interpretation, or current-rule claim, verify the latest official primary sources. Do not infer an executable setup from an image brief.

## Classify the request

Choose one scene family:

1. **Mobile no-stopping zone**: temporary curb reservation for moving, delivery, lift, container, event, filming, or similar use.
2. **Road-work traffic safety**: lane, sidewalk, shoulder, excavation, short-duration work, or longer-duration work protection.
3. **Traffic-sign documentation**: close or medium photo emphasizing one correctly mounted sign assembly.
4. **Commercial website image**: credible service scene with deliberate space for page copy and no embedded advertising text.
5. **Image correction**: preserve the supplied image and change only implausible signs, equipment, text, geometry, lighting, or artifacts.

## Apply defaults without blocking

When the user gives only a generic request such as `Erstell mir eine Halteverbotszone`, use these defaults:

- Germany, contemporary inner-city residential or mixed-use street.
- Mobile absolute no-stopping zone using Zeichen 283, not Zeichen 286.
- Two boundary sign assemblies on the same relevant curb side, one near and one farther down the reserved stretch.
- Stable black temporary base plates, straight galvanized posts, secure clamps, and white supplementary panels.
- Date and time panels present but not presented as readable hero text unless exact wording was supplied.
- Natural overcast or soft daylight, eye-level documentary commercial photography, moderate depth of field.
- No workers, company branding, cones, barriers, or construction machinery unless implied by the request.

Ask only when a missing fact would materially change the scene family, road geometry, or exact visible text. Otherwise select the conservative default and proceed.

## Build the scene before the camera prompt

Resolve these points in order:

1. **Road geometry**: road type, traffic direction, curb side, sidewalk, parking strip, cycle facility, junctions, and work area.
2. **Control objective**: reserve curb space, prohibit stopping, guide traffic, close an area, protect workers, or document equipment.
3. **Sign logic**: use only signs and directional indicators required by that objective; keep beginning, continuation, and end relationships internally consistent.
4. **Equipment logic**: use plausible German temporary supports, barriers, beacons, delineators, cones, or portable signals only where needed.
5. **Human logic**: keep pedestrian and vehicle paths credible; use appropriate high-visibility workwear when personnel are requested.
6. **Physical logic**: give every object correct scale, support, contact shadow, orientation, reflectivity, and weathering.
7. **Camera logic**: select viewpoint, lens character, depth of field, light, and negative space based on intended use.

Do not let photographic style conceal contradictory traffic-control geometry.

## Write the structured prompt

Use the labeled order from `references/prompt-recipes.md`. Always include:

- intended use and scene family;
- exact German road environment;
- traffic-control purpose and equipment;
- spatial relationship between signs, curb, road, and work area;
- physical materials and imperfections;
- camera, composition, light, and depth of field;
- exact visible wording only when supplied;
- explicit constraints and avoid list.

Prefer positive, concrete descriptions. Use the `Avoid` block to suppress recurring image-model failures, not as a substitute for defining the scene.

## Generate or edit

- Use the built-in image-generation tool for new images and edits.
- For an edit target stored locally, inspect it first so it is available as an image input.
- Label each input as `edit target`, `equipment reference`, `location reference`, or `style reference`.
- Preserve the original composition and untouched objects during corrections.
- For variants, make one meaningful change per generation: viewpoint, weather, road setting, or intended layout.
- Do not invent a logo, company name, license plate, permit number, or readable activation period.

## Inspect the result

Reject or correct the image when any critical check fails:

1. **Sign identity**: Zeichen 283 versus 286 is correct; symbol, border, cross or slash, supplementary panel, and sign face are not malformed.
2. **Zone logic**: relevant signs stand on the same roadside; beginning and end relationships match the curb and traffic context; no contradictory arrows.
3. **Equipment**: posts are straight, supports touch the ground, bases are plausible, barriers and warning lights are not floating or duplicated.
4. **Road use**: German right-hand traffic, curb, parking, cycle and pedestrian space, road markings, and work area do not contradict one another.
5. **Photography**: believable scale, perspective, reflections, shadows, asphalt, metal, plastic, dirt, wear, and atmospheric depth.
6. **Artifact control**: no gibberish hero text, malformed vehicles or people, repeated objects, watermarks, unrelated brands, excessive cinematic grading, or CGI sheen.

Iterate with one targeted correction while repeating all invariants. If a small sign remains unreliable, change framing so the exact face is not the primary focal detail instead of accepting a visibly false sign.

## Preserve the legal boundary

Describe generated outputs as marketing, editorial, or conceptual visuals. An image is not proof of a compliant field setup. For real implementation, state that the competent authority's order, the approved Verkehrszeichenplan where required, the applicable current rules, and the actual location control the arrangement.

## Return the result

Provide the generated image and the final full prompt. Mention any deliberately unreadable sign text or conceptual assumptions that affect factual interpretation. Keep the explanation short unless the user asks for a technical breakdown.
