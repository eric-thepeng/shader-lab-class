Shader "examples/week 10/hw 10"
{
    Properties
    {
        _MainTex ("render texture", 2D) = "white"{}
        _distortion ("distortion", Range(-1, 1)) = -0.5
        _scale ("scale", Range(0, 3)) = 1
    }

    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            
            float _distortion;
            float _scale;

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

            float3 RGBtoHSV(float3 rgb)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = rgb.g < rgb.b ? float4(rgb.bg, K.wz) : float4(rgb.gb, K.xy);
                float4 q = rgb.r < p.x ? float4(p.xyw, rgb.r) : float4(rgb.r, p.yzx);
                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            float3 HSVtoRGB(float h, float s, float v)
            {
                float3 k = float3(1.0, 2.0/3.0, 1.0/3.0);
                float3 p = abs(frac(h + k) * 6.0 - 3.0);
                return v * lerp(k.xxx, saturate(p - k.xxx), s);
            }

            float interestingCurve(float x)
            {
                // oscillation curve
                return sin(x * 10) * x * x; 
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;// - 0.5;

                // DISTORTION
                float centerX = 0.5 + sin(_Time.y) * 0.3;
                float oscillationSpeed = 10;
                float strength = 15;

                float distance = abs(uv.x - centerX);

                float distortion = interestingCurve(distance) * sin(oscillationSpeed * _Time.y);

                // Only distort near the center line with attenuation by distance
                distortion *= exp(-distance * 20.0); // Sharp falloff from center

                uv += float2(distortion * strength, 0.0);

                // COLOR Shifting for highlight
                
                float3 orgColorRGB = tex2D(_MainTex, uv);
                float3 orgColorHSV = RGBtoHSV(orgColorRGB);
                
                float speed = abs(orgColorHSV.x - 0.5) * 2;
                float time = _Time.y * speed;

                float maxHueDelta = abs(orgColorHSV.x - 0.5); //(orgColorRGB.r + orgColorRGB.g + orgColorRGB.b)/3;

                float hueDelta = maxHueDelta * sin(time);
                
                //float hue = frac(time);
                float3 finalRGB = HSVtoRGB(frac( orgColorHSV.x + hueDelta), orgColorHSV.y, orgColorHSV.z);

                if(orgColorHSV.z < 0.5)
                {
                    return float4(orgColorRGB, 1.0);
                }
                return float4(finalRGB, 1.0);
            }


            
            ENDCG
        }
    }
}
