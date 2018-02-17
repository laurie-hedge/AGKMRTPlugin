uniform sampler2D texture0;
 
varying highp vec3 posVarying;
varying mediump vec3 normalVarying;
varying mediump vec2 uvVarying;
varying mediump vec3 lightVarying;
 
mediump vec3 GetPSLighting( mediump vec3 normal, highp vec3 pos );
mediump vec3 ApplyFog( mediump vec3 color, highp vec3 pointPos );
 
void main()
{ 
    mediump vec3 norm = normalize(normalVarying);
    mediump vec3 light = lightVarying + GetPSLighting(norm, posVarying); 
    
    mediump vec3 color = texture2D(texture0, uvVarying).rgb * light;
    color = ApplyFog(color, posVarying);
    
    gl_FragData[0] = vec4(color, 1.0);
    gl_FragData[1] = vec4(color, 1.0);
}
