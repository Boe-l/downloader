#include <common/common_header.frag>

uniform sampler2D iChannel0; // áudio
uniform float RADIUS;
uniform float BRIGHTNESS;
uniform float SPEED;

#define ITER 64
#define PI 3.141592

#define THRESHOLD 0.1
#define MIN_NEEDLE_SIZE 0.10

float getAudio() {
    float raw = texture(iChannel0, vec2(0.001,0.25)).x;
    return max(raw - THRESHOLD, 0.0);
}

float hash21(vec2 x){return fract(sin(dot(x,vec2(12.4,14.1)))*1245.4);}
vec2 moda(vec2 p,float per){float a=atan(p.y,p.x);float l=length(p);a=mod(a-per/2.,per)-per/2.;return vec2(cos(a),sin(a))*l;}
mat2 rot(float a){return mat2(cos(a),sin(a),-sin(a),cos(a));}
float smin(float a,float b,float k){return -log(exp(-k*a)+exp(-k*b))/k;}
float sphe(vec3 p,float r){return length(p)-r;}
float cyl(vec2 p,float r){return length(p)-r;}

float needles(vec3 p,float audio){
    vec3 pp = p;
    float l_needle = MIN_NEEDLE_SIZE + (1.0 - audio) * 0.8; 

    float rndX = hash21(p.xz*10.0)*0.2 + 0.9;
    float rndY = hash21(p.yz*10.0)*0.2 + 0.9;
    float rndZ = hash21(p.xy*10.0)*0.2 + 0.9;

    p.xz = moda(p.xz,2.*PI/7.);
    float n1 = cyl(p.yz, (0.1-p.x*l_needle) * rndX );

    p = pp;
    p.y = abs(p.y)-0.1;
    p.xz = moda(p.xz,2.*PI/7.);
    p.xy *= rot(PI/4.5);
    float n2 = cyl(p.yz, (0.1-p.x*l_needle) * rndY );

    p = pp;
    float n3 = cyl(p.xz, (0.1-abs(p.y)*l_needle) * rndZ );

    return min(n3,min(n2,n1));
}

float spikyball(vec3 p,float audio){
    p.y -= iTime;
    p.xz *= rot(iTime);
    p.yz *= rot(iTime*0.5);
    float s = sphe(p,0.9);
    return smin(s, needles(p,audio),5.0);
}

float room(vec3 p){
    p += sin(p.yzx - cos(p.zxy));
    p += sin(p.yzx/1.5 + cos(p.zxy)/2.0)*0.5;
    return -length(p.xz)+5.0;
}

float SDF(vec3 p,float audio){
    return min(spikyball(p,audio),room(p));
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
    vec2 uv = (2.0*fragCoord - iResolution.xy) / iResolution.y;
    float dither = hash21(uv);
    float audio = getAudio();
    vec3 ro = vec3(0.001,0.001+iTime,-3.0);
    vec3 p = ro;
    vec3 dir = normalize(vec3(uv,1.0));

    float shad = 0.0;
    float minD = 1000.0;
    bool hit = false;

    for(int i=0;i<ITER;i++){
        float d = SDF(p,audio);
        if(d < minD) minD = d;
        if(d < 0.001){
            shad = float(i)/float(ITER);
            hit = true;
            break;
        }
        d *= 0.9 + dither*0.1;
        p += d*dir;
    }

    vec3 col = vec3(0.0); // fundo preto

    if(hit){
        // cor da bola e espinhos
        vec3 spikes = vec3(shad) * BRIGHTNESS * (2.0 + audio);

        // aura branca baseada na distância mínima do hit
        float aura = exp(-minD*60.0) * (0.1 + audio*0.1);

        col = spikes + vec3(aura);
    }

    // inverter as cores
    col = 1.0 - col;

    fragColor = vec4(pow(col, vec3(1.5)), 1.0);
}

#include <common/main_shadertoy.frag>
