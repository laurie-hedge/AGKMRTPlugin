uniform sampler2D texture0;

varying mediump vec2 uvVarying;
varying mediump vec4 colorVarying;
 
void main()
{
	gl_FragData[0] = texture2D(texture0, uvVarying);
	gl_FragData[1] = mix(vec4(colorVarying.r), vec4(vec3(0.0), 1.0), length(uvVarying - vec2(0.5, 0.5)) * 2.0f);
}
