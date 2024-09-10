Shader "examples/week 1/masks"
{
    Properties
    {
        [NoScaleOffset] _tex1 ("texture one", 2D) = "white" {}
        [NoScaleOffset] _tex2 ("texture two", 2D) = "white" {}
        [NoScaleOffset] _tex3 ("texture three", 2D) = "white" {}
        
        _color1 ("color one", Color) = (0.7, 0.2, 0.9, 1)
        _color2 ("color two", Color) = (0, 0.85, 0 , 1)
        _color3 ("color two", Color) = (0.9, 0.1, 0.4, 1)
        _color4 ("color two", Color) = (0, 0.85, 0 , 1)
        _color5 ("color two", Color) = (0.9, 0.1, 0.4, 1)
        
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

            uniform float3 _color1;
            uniform float3 _color2;
            uniform float3 _color3;
            uniform float3 _color4;
            uniform float3 _color5;
            
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

                /*
                float2 uv = i.uv;

                // sample the color data from each of the three textures and store them in float3 variables
                float3 t1 = tex2D(_tex1, uv).rgb;
                float3 t2 = tex2D(_tex2, uv).rgb;
                float3 mask = tex2D(_tex3, uv).rgb;

                float3 color = 0;

                //color = t2 * (1-mask) + (t1+t2)/2 *mask;
                color = t2 * (1-mask) + t1 *mask;

                //return float4(color * 2, 1.0);*/

                /* Statement:
                 * 
                 */

                float2 uv = i.uv;
                float2 sunPos = float2(0.4,0.3);
                float radius = 0.1f;
                
                if(pow(uv.x - sunPos.x,2) + pow(uv.y - sunPos.y,2) < pow(radius,2)) //sun
                {
                    float weight = 1 - ((pow(uv.x - sunPos.x,2) + pow(uv.y - sunPos.y,2)) / pow(radius,2)) * 0.9;
                    return float4( _color1,1) *weight + float4( _color2,1) *(1-weight) ;
                }
                else //background
                {
                    float3 color = (
                        0.2 * _color1
                        + _color2 * sin(uv.x)/10 * abs(uv.y - sunPos.y) * 2
                        + _color3 * (uv.y)
                        );
                    
                    return float4(color,1);
                }

                //sky stuffs
                
            }
            ENDCG
        }
    }
}
