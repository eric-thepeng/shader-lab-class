Shader "examples/week 1/masks"
{
    Properties
    {
        [NoScaleOffset] _tex1 ("texture one", 2D) = "white" {}
        [NoScaleOffset] _tex2 ("texture two", 2D) = "white" {}
        [NoScaleOffset] _tex3 ("texture three", 2D) = "white" {}
        
        //sky base color
        //sun color
        //sea base color
        //sun burn color
        
        _cSkyBase ("sky base", Color) = (0.7, 0.2, 0.9, 1)
        _cSunBase ("sun base", Color) = (0, 0.85, 0 , 1)
        _cSeaBase ("sea base", Color) = (0.9, 0.1, 0.4, 1)
        _cSunBurn ("sun burn", Color) = (0, 0.85, 0 , 1)
        _cSkyGlow ("sky glow", Color) = (0, 0.85, 0 , 1)

        //_color5 ("color five", Color) = (0.9, 0.1, 0.4, 1)
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            uniform sampler2D _tex1;
            uniform sampler2D _tex2;
            uniform sampler2D _tex3;

            uniform float3 _cSkyBase;
            uniform float3 _cSunBase;
            uniform float3 _cSeaBase;
            uniform float3 _cSunBurn;
            uniform float3 _cSkyGlow;
            
            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {

                float2 uv = i.uv;
                float2 sunPos = float2(0.25,0.35);
                float radius = 0.06f;
                float seaLevel = 0.2f;

                //SUN
                if(pow(uv.x - sunPos.x,2) + pow(uv.y - sunPos.y,2) < pow(radius,2)) 
                {
                    float weight = 1 - ((pow(uv.x - sunPos.x,2) + pow(uv.y - sunPos.y,2)) / pow(radius,2)) * 0.9;
                    return float4( _cSunBase,1) *weight + float4( _cSunBurn,1) *(1-weight) ;
                }

                //SKY
                else if(uv.y >= (0.015 * sin(50 * uv.x) + seaLevel))
                {
                    float3 color = (0
                        + _cSkyBase * 0.4
                        //+ _cSunBurn * lerp(0, 1, (uv.y-seaLevel)/(1-uv.y)) * 0.2
                        
                        //Sun burn around the sun
                        + _cSunBurn * lerp(0, 1, 1 - clamp( sqrt(pow(uv.x - sunPos.x,2) + pow(uv.y - sunPos.y,2)) / (radius * 7) - 0.5 , 0, 1  ))
                        );

                    //A sky glow stripe
                    color += _cSkyGlow *  (1 - clamp(abs(uv.y - (0.1 * sin(5 * uv.x) + 0.7)),0.1,0.3)/0.3) * 0.2;

                    return float4(color,1);
                }else

                //SEA
                {
                    float3 color =
                        // sea base color gradient to height
                        _cSeaBase * lerp(0.3, 1, 1-uv.y/seaLevel) * 0.5

                        // sun's base color to horizon
                        + _cSunBase * lerp(0.3 ,1 ,uv.y/seaLevel) * 0.2

                        // sun's casting to sea according to distance
                        + _cSunBurn * lerp(0, 1, 1 - sqrt(pow(uv.x - sunPos.x,2) + pow(uv.y - sunPos.y,2)));
                    ;

                    // a strong sunburn on sea
                    color = lerp(_cSunBase,color, clamp(sqrt(pow(uv.x - sunPos.x,2) + pow(uv.y - sunPos.y,2)) /0.25, 0 , 1 ) );
                    
                    return float4(color,1);
                }
                
            }

            float distance()
            {
                return 1;
            }
            
            ENDCG
        }
    }
}
