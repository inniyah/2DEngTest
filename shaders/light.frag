#version 330 core
//out vec4 FragColor;
  
in vec2 texCoord;
//in vec4 gl_Position;

uniform sampler2D tex0; //color texture
uniform sampler2D tex1; //normal texture
uniform sampler2D tex2; //depth texture
uniform vec3 lightdir;
uniform vec3 lightpos;
uniform vec3 [3] ambient;
uniform vec3 [2] lights;
uniform vec2 screensize;

void main()
{   
    // ambient[0] es la direccion de la luz
    // ambient[1] el color de la luz
    // ambient[2] el color ambiental
    vec3 sunlightdir=normalize(-ambient[0]);
    
    vec3 Normal = normalize(texture(tex1, texCoord).rgb);
    Normal.x = Normal.x - 0.5;
    Normal.y = Normal.y - 0.5;
    Normal.z = Normal.z / 2.0;
    vec3 Color=texture(tex0, texCoord).rgb;
    
    float cosTheta = clamp(dot( Normal,sunlightdir ),0,1);
    vec3 ambientcolor=vec3(ambient[2]+Color*ambient[1]*cosTheta);
    
    // lights[0] posicion de la luz
    // lights[1] color de la luz
    // Calculamos el vector que va desde la superficie hacia la luz
    //vec3 fragpos=vec3(gl_FragCoord.x,screensize.y-gl_FragCoord.y,gl_FragCoord.z);
    vec3 deapth=texture(tex2, texCoord).rgb;
    vec3 fragpos=vec3(gl_FragCoord.x,screensize.y-gl_FragCoord.y,gl_FragCoord.z+deapth.x*64);
    
    vec3 lightdir=lights[0]-fragpos ;
    float distance=length(lightdir);
    lightdir=normalize(lightdir);
    cosTheta = clamp(dot( Normal,lightdir ),0,1);
    vec3 difusecolor= vec3(Color*lights[1] * cosTheta/(distance*distance));
    
    vec3 R=reflect(-lightdir,Normal);
    vec3 eyepos=vec3( screensize/2-fragpos.xy,100);
    vec3 E=normalize(eyepos-fragpos.xyz);
    float cosAlfa=clamp(dot( E,R ),0,1);
    vec3 specularcolor=vec3(Color*lights[1] * pow(cosAlfa, 5.0)/(distance*distance));
    //specularcolor=vec3(0.0,0.0,0.0);
    //difusecolor=vec3(0.0,0.0,0.0);
    
    gl_FragColor = vec4(ambientcolor+difusecolor+specularcolor,1.0);
    
    
    
    
    
    //vec3 lightdir=vec3(-0.5,0.5,0.3);
    //vec3 lightdir=lightpos;
    //vec3 lightdir=normalize(gl_FragCoord.xyz - lightpos);
   
    //para cambiar el depth buffer
    //gl_FragDepth=
    
    
}
