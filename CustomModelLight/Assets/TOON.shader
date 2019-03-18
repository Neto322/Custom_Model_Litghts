Shader "Custom/TOON"
{
	Properties
	{
		_MainTex("Main Textures", 2D) = "white" {}
		_Albedo("Albedo", Color) = (1, 1, 1, 1)
	
		_BumpMap("Bumpmap", 2D) = "bump" {}
		_NormalStrenght("Normal Strenght", Range(-3, 3)) = 1
		_RimColor("Rim Color", Color) = (0.26, 0.19, 0.16, 0.0)
		_RimPower("Rim Power", Range(0.5,8.0)) = 3.0
		_RampTex("Ramp Texture", 2D) = "white" {}
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_OutlineSize("Outline Size", Range(0.001, 1)) = 1
	}
		SubShader
		{
		   CGPROGRAM
		   #pragma surface surf ToonRamp

		   float4 _Albedo;
		   sampler2D _MainTex;
		   sampler2D _RampTex;
		   sampler2D _BumpMap;
		   float _NormalStrenght;
		   float4 _RimColor;
		   float _RimPower;

		   float4 LightingToonRamp(SurfaceOutput s, fixed2 lightDir, fixed atten)
		   {
			   half diff = dot(s.Normal, lightDir);
			   float uv = (diff * 0.5) + 0.5;
			   float3 ramp = tex2D(_RampTex, uv).rgb;
			   float4 c;
			   c.rgb = s.Albedo * _LightColor0.rgb * ramp;
			   c.a = s.Alpha;
			   return c;
		   }
		   struct Input
		   {
			   float2 uv_MainTex;
			   float2 uv_BumpMap;
			   float3 viewDir;
		   };

		   void surf(Input IN, inout SurfaceOutput o)
		   {
			   o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Albedo.rgb;

			   float3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			   normal.z = normal.z / _NormalStrenght;
			   o.Normal = normal;

			   half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
			   o.Emission = _RimColor.rgb * pow(rim, _RimPower);

		   }
		   ENDCG

		   Pass
		   {
			   Cull Front
			   CGPROGRAM

			   #pragma vertex vert
			   #pragma fragment frag

			   #include "UnityCG.cginc"

			   struct appdata
			   {
				   float4 vertex: POSITION;
				   float3 normal: NORMAL;
			   };
			   struct v2f
			   {
				   float4 pos : SV_POSITION;
				   float4 color : COLOR;
			   };

			   float4 _OutlineColor;
			   float _OutlineSize;

			   v2f vert(appdata v)
			   {
				   v2f o;
				   o.pos = UnityObjectToClipPos(v.vertex);

				   float3 norm = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
				   float2 offset = TransformViewToProjection(norm.xy);

				   o.pos.xy += offset * o.pos.z * _OutlineSize;
				   o.color = _OutlineColor;
				   return o;
			   }
			   fixed4 frag(v2f i) : SV_Target
				{
					return i.color;
				}

			   ENDCG
		   }
		}
}
