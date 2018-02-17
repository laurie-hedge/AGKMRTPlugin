uniform sampler2D texture0;
varying mediump vec2 uvVarying;
varying mediump vec4 colorVarying;
 
void main()
{
    gl_FragData[0] = texture2D(texture0, uvVarying) * colorVarying;
    gl_FragData[1] = texture2D(texture0, uvVarying) * colorVarying;
}
