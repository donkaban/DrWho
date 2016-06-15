Shader "drwho/universe" {
Properties 
	{
		_Color("Color", Color) = (1,1,1,1)
	}

	SubShader {
	Pass 
	{
		GLSLPROGRAM

		uniform vec4  _Color;
		uniform vec4  _Time;  
    #ifdef VERTEX 

   		varying vec2 uv; 
        void main() 
        {
        	uv = gl_MultiTexCoord0.xy;
         	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
       	}

    #endif
	#ifdef FRAGMENT

		varying vec2 uv; 
	  	float random (vec2 st) { return fract(sin(dot(st.xy,vec2(12.9898,78.233))) * 43758.5453123);}
		float noise (vec2 st) 
		{
    		vec2 i = floor(st);
    		vec2 f = fract(st);

		    float a = random(i);
		    float b = random(i + vec2(1.0, 0.0));
		    float c = random(i + vec2(0.0, 1.0));
		    float d = random(i + vec2(1.0, 1.0));

    		vec2 u = f*f*(3.0-2.0*f);
   			 return mix(a, b, u.x) + 
            	(c - a)* u.y * (1.0 - u.x) + 
            	(d - b) * u.x * u.y;
		}

		#define FROM 3.0
		#define TO   6.0

		void main() 
		{
		    vec2 pos = vec2(uv * FROM + sin(_Time.x) * TO); 
			gl_FragColor = _Color * noise(pos);
		}

	#endif 
	ENDGLSL 
	}}}