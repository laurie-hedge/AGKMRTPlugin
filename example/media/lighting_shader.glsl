uniform sampler2D texture0;
uniform sampler2D texture1;
varying mediump vec2 uvVarying;
 
void main()
{
    vec4 colour = texture2D(texture0, uvVarying);
    vec4 greyscale = vec4(vec3((colour.r + colour.g + colour.b) / 3.0), 1.0) * 0.5;
    vec4 light = texture2D(texture1, uvVarying);

    gl_FragColor = mix(greyscale, colour, light.r);
}
