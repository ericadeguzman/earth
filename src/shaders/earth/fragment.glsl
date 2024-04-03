uniform sampler2D uDayTexture;
uniform sampler2D uNightTexture;
uniform sampler2D uSpecularCloudsTexture;
uniform vec3 uSunDirection;
uniform vec3 uAtmosphereDayColor;
uniform vec3 uAtmosphereTwilightColor;



varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;

void main()
{
    vec3 viewDirection = normalize(vPosition - cameraPosition);
    vec3 normal = normalize(vNormal);
    vec3 color = vec3( 0.0);

    // Sun orientation
 
    float sunOrientation = dot(uSunDirection, normal);
    // color = vec3(sunOrientation);

//Day / night color
float dayMix = smoothstep(-0.25, 0.5, sunOrientation);
vec3 dayColor = texture(uDayTexture, vUv).rgb;
vec3 nightColor = texture(uNightTexture, vUv).rgb;

// if dayMix is 0 then we get the first value "nightColor" 
// if dayMix is 1 we get the second value "dayColor" 
// if dayMix is 0.5 we get a mix of both
color = mix( nightColor, dayColor, dayMix);

//Specular clouds
vec2 specularCloudsColor = texture(uSpecularCloudsTexture, vUv).rg;
// color = vec3(specularCloudsColor, 0.0);


//Clouds
float cloudsMix = smoothstep(0.5, 1.0, specularCloudsColor.g);
cloudsMix *= dayMix;
color = mix(color, vec3(1.0), cloudsMix);

// Fresnel
float fresnel = dot(viewDirection, normal) + 1.0;
fresnel = pow(fresnel, 2.0);
// color = vec3(fresnel);


//Atmosphere
float atmosphereDayMix = smoothstep(-0.5, 1.0, sunOrientation);
vec3 atmosphereColor = mix(uAtmosphereTwilightColor, uAtmosphereDayColor, atmosphereDayMix);
color = mix(color, atmosphereColor, fresnel * atmosphereDayMix);

//Speculare
vec3 reflection = reflect(- uSunDirection, normal);
float specular = - dot(reflection, viewDirection);
specular = max(specular, 0.0);
specular = pow(specular, 32.0);
specular *= specularCloudsColor.r;

color += vec3(specular);

vec3 specularColor = mix(vec3(1.0), atmosphereColor, fresnel);
color += specular * specularColor;

    // Final color
    gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}