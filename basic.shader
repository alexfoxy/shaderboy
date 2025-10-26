
// Hard Light per-channel
vec3 hardLight(vec3 base, vec3 blend) {
  // if blend <= 0.5: darken; else: lighten
  vec3 lt = 2.0 * base * blend;
  vec3 gt = 1.0 - 2.0 * (1.0 - base) * (1.0 - blend);
  return mix(lt, gt, step(0.5, blend));
}

void main() {
  vec2 uv = vUV;
  vec2 uvTone = vUV * uCoverUV2.xy + uCoverUV2.zw;
  float gainMapOffset = -0.2;
  float uAmount = 1.0; // 0 = none, 1 = normal, 2 = stronger

  vec4 c = texture(uBase,    uv);
  vec4 w = texture(uToneMap, uvTone)  * (1.0 + gainMapOffset);

  vec3 baseColor = c.rgb;

  // Use luminance of gain map to avoid color shifts
  float g = dot(w.rgb, vec3(0.2126, 0.7152, 0.0722));

  // Push gain away/toward 0.5 by uAmount:
  // amount=0 -> 0.5 (no change), amount=1 -> original g, amount>1 -> more extreme
  float gAdj = clamp(0.5 + (g - 0.5) * uAmount, 0.0, 1.0);
  vec3 blend = vec3(gAdj);

  vec3 hard = hardLight(baseColor, blend);

  // Smoothly blend with original based on amount in [0..1]; for >1 we already
  // “boosted” via gAdj, so just take full hard result here.
  float t = clamp(uAmount, 0.0, 1.0);
  vec3 outColor = mix(baseColor, hard, t);

  finalColor = vec4(outColor, c.a);
}

