Shader "examples/week 3/homework template"
{
    Properties 
    {
        _hour ("hour", float) = 0
        _minute ("minute", float) = 0
        _second ("second", float) = 0
        _circleCor ("circle color", Color) = (1,1,1,1)
        _bgCor1 ("bg color 1", Color) = (1,1,1,1)
        _bgCor2 ("bg color 2", Color) = (1,1,1,1)
        _secondCor ("second cor", Color) = (1,1,1,1)
        _minuteCor ("minute cor", Color) = (1,1,1,1)
        _emptyCor ("empty cor", Color) = (1,1,1,1)
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

            #define TAU 6.28318530718

            float _hour;
            float _minute;
            float _second;
            float3 _circleCor;
            float3 _bgCor1;
            float3 _bgCor2;
            float3 _secondCor;
            float3 _minuteCor;
            float3 _emptyCor;

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

            float Circle(float2 uv, float2 center, float circleRadius)
            {
                float dist = distance(uv, center); // Calculate distance between the pixel and the circle center
                return smoothstep(circleRadius, circleRadius - 0.01, dist); // Soft edge for the circle
            }

            float rectangle (float2 uv, float2 scale) {
                float2 s = scale * 0.5;
                float2 shaper = float2(step(-s.x, uv.x), step(-s.y, uv.y));
                shaper *= float2(1-step(s.x, uv.x), 1-step(s.y, uv.y));
                return shaper.x * shaper.y;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 centerUV = i.uv * 2 - 1;
                float2 uv = i.uv;
                float time = _Time.z;

                // POLAR 
                float polar = (atan2(centerUV.y, centerUV.x) / TAU) + 0.5;

                float3 color = float3(0,0,0);
                
                // radius of 12 circle loop 
                float loopRadius = 0.61;
                float circleRadius = 0.13  + sin(time)/200; // Radius of each individual circle

                // 12 circles one by one
                for (int hour = 0; hour < 12; hour++)
                {
                    // angular position for each hour
                    float angle = (float)-hour / 12.0 * TAU; // Angle in radians for each circle
                    float2 center;
                    if(hour == floor((_hour +9) % 12)) // moving ones
                    {
                        circleRadius = 0.13;
                        center = float2(cos(angle), sin(angle)) * (loopRadius * 0.8 +cos(time)/8); // hour indicatino, Polar to Cartesian for center
                    }else
                    {
                        center = float2(cos(angle), sin(angle)) * (loopRadius); // not moving ones
                    }

                    // Add the circle color contribution
                    color += Circle(centerUV, center, circleRadius) * _circleCor * lerp(0.7,1, distance(centerUV, center)/circleRadius); // White circles
                }

                // assign background
                color += lerp(_bgCor1, _bgCor2, uv.x);

                // warp for the seconds walls
                float warpStength = 0.005;
                float2 warp = 0;
                warp += cos(uv.yx + float2(time, 1.5)) * warpStength;
                warp += sin(uv.yx + float2(0, time * 3)) * warpStength;

                uv += warp;
                
                // GRID
                int gridDimension = 16;
                float2 grid = (frac(uv*gridDimension)-0.5) * 2;
                float2 gridCoord = floor(uv * gridDimension);

                int index = -1;
                if(gridCoord.y == gridDimension - 1) //top side
                {
                    if(gridCoord.x >= gridDimension/2) index = gridCoord.x - gridDimension/2;
                    else index = 52 + gridCoord.x ;
                }
                else if(gridCoord.y == 0) //down side
                {
                    index = 37 - gridCoord.x;
                }
                else if(gridCoord.x == 0) //left side
                {
                    index = 37 + gridCoord.y;
                }else if(gridCoord.x == gridDimension - 1) //right side
                {
                    index = 22-gridCoord.y;
                }
                    
                float squareWidth;
                float3 targetColor = 0;

                if(index == floor(_minute % 60)) //MINUTE
                {
                    squareWidth = 1.5f;
                    targetColor = _minuteCor;
                }
                else if(index == floor(_second % 60)) //SECOND
                {
                    squareWidth = 1.0f;
                    targetColor = _secondCor;
                }else //REGULAR
                {
                    float angle = frac(time * 0.1) * TAU; //* sin(time * 0.2) ;//( 0.5 + (floor(_second) % 2) *  lerp(0,0.5,frac(_second)));
                    float3x3 rotate2D = float3x3(
                        cos(angle),-sin(angle),0,
                        sin(angle),cos(angle),0,
                        0,0,1
                    );
                    

                    grid = mul(rotate2D,float3(grid.xy,1));
                    
                    squareWidth = .7f;
                    targetColor = _emptyCor;
                }
                
                if(gridCoord.x == 0 || gridCoord.x == gridDimension-1 || gridCoord.y == 0 || gridCoord.y == gridDimension -1 )
                {
                    float rec = rectangle(grid,squareWidth);
                    if(rec != 0)
                    {
                        color = rec * targetColor;
                    }
                }

                
                return float4(color,1);

                return float4(_hour/24, _minute/60, _second/60, 1.0);
            }
            ENDCG
        }
    }
}
