#version 330 core
//out vec4 FragColor;
  
in vec2 texCoord;
//in vec4 gl_Position;

// Entradas del shader
uniform sampler2D tex0; //color texture
uniform sampler2D tex1; //normal texture
uniform sampler2D tex2; //depth texture
uniform vec3 lightdir;
uniform vec3 lightpos;
uniform vec3 [3] ambient;
uniform vec3 [20] lights; //para 10 luces
uniform vec2 screensize;

float difuseangle(vec3 Normal,vec3 lightdir)
{
    return clamp(dot( Normal,lightdir ),0,1);
} 

float specularangle(vec3 E,vec3 R)
{
    return pow(clamp(dot( E,R ),0,1), 5.0);
}

vec3 Normal()
{
    vec3 Normal = normalize(texture(tex1, texCoord).rgb);
    Normal.x = Normal.x - 0.5;
    Normal.y = Normal.y - 0.5;
    Normal.z = Normal.z / 2.0;
    return Normal; 
}

void main()
{   
    // ambient[0] es la direccion de la luz
    // ambient[1] el color de la luz
    // ambient[2] el color ambiental
    // CALCULO LA NORMAL, DIRECCION DE LA LUZ DEL SOL Y EL COLOR DE LA TEXTURA
    vec3 sunlightdir=normalize(-ambient[0]);
    vec3 Normal = Normal();
    vec3 Color=texture(tex0, texCoord).rgb;
    vec3 Rsun=reflect(-sunlightdir,Normal);
    vec3 deapth=texture(tex2, texCoord).rgb;
    vec3 fragpos=vec3(gl_FragCoord.x,screensize.y-gl_FragCoord.y,gl_FragCoord.z+deapth.x*64);
    vec3 eyepos=vec3( screensize/2-fragpos.xy,100);
    vec3 E=normalize(eyepos-fragpos.xyz);
    
    //COLOR AMBIENTAL : ambient[2]
    // COLOR DIFUSO:        Color*ambient[1]*difuseangle(Normal,sunlightdir))
    // COLOR ESPECULAR: Color*ambient[1]*specularangle(E,reflect(-sunlightdir,Normal))
    
    // lights[0] posicion de la luz
    // lights[1] color de la luz
    // Calculamos el vector que va desde la superficie hacia la luz
    vec3 lightcolor= vec3(ambient[2]+Color*ambient[1]*difuseangle(Normal,sunlightdir)+Color*ambient[1]*specularangle(E,reflect(-sunlightdir,Normal)));
    for (int i=0;i<=9;i++)
    {
        vec3 lightdir=lights[i*2]-fragpos ;
        float distance=length(lightdir);
        float distance2=distance*distance;
        lightdir=normalize(lightdir);
        vec3 R=reflect(-lightdir,Normal);
        lightcolor= lightcolor + Color*lights[i*2+1] * difuseangle(Normal,lightdir)/(distance2)+Color*lights[i*2+1] * specularangle(E,R)/(distance2);
    }
    //specularcolor=vec3(0.0,0.0,0.0);
    //difusecolor=vec3(0.0,0.0,0.0);
    
    gl_FragColor = vec4(lightcolor,1.0);
    
    //vec3 lightdir=vec3(-0.5,0.5,0.3);
    //vec3 lightdir=lightpos;
    //vec3 lightdir=normalize(gl_FragCoord.xyz - lightpos);
   
    //para cambiar el depth buffer
    //gl_FragDepth=
    
    
}
