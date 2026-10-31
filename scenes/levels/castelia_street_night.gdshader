shader_type sky;

   uniform vec3 zenith_color : source_color = vec3(0.02, 0.03, 0.10);
   uniform vec3 horizon_color : source_color = vec3(0.078, 0.102, 0.20); // matches background_color
   uniform vec3 star_color : source_color = vec3(0.85, 0.90, 1.0);
   uniform float star_density : hint_range(0.0, 1.0) = 0.90;
   uniform float star_brightness : hint_range(0.0, 8.0) = 2.5;

   float hash(vec3 p) {
      p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
      p *= 17.0;
      return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
   }

   void sky() {
      vec3 dir = EYEDIR;
      float h = clamp(dir.y, 0.0, 1.0);

      vec3 col = mix(horizon_color, zenith_color, smoothstep(0.0, 0.5, h));

      vec3 p = dir * 220.0;
      vec3 cell = floor(p);
      vec3 f = fract(p) - 0.5;
      float r = hash(cell);
      if (r > star_density) {
         float size = mix(0.06, 0.18, hash(cell + 7.0));
         float star = 1.0 - smoothstep(size * 0.4, size, length(f));
         float bright = mix(0.4, 1.0, hash(cell + 13.0));
         // stars fade out only very near the horizon, since that band is what the camera sees
         float fade = smoothstep(0.004, 0.06, h);
         col += star_color * star * bright * fade * star_brightness;
      }

      COLOR = col;
   }