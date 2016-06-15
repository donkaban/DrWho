Shader "drwho/universe" {
Properties 
	{
		_Iterations("Star Volume", Range(1,20)) = 4
		_Zoom("Star Zoom", Range(1,10)) = 4
		_Brightness("Star Brightness", Range(0,1.0)) = .2
		_Saturation("Star Saturation", Range(0,1.0)) = .2
		_DistFading("DistFading", Range(0,1.0)) = .4

		_VolSteps("Volumetric Steps", Range(2,20)) = 10
		_VolSize("Volumetic Size", Range(0,1.0)) = .2
		_Cloud("Cloud Volume", Range(0,1.0)) = .2
		_Speed("Speed", Range(0,10)) = 3
	}

	SubShader {
	Pass 
	{
		GLSLPROGRAM

		uniform vec4  _Color;
		uniform vec4  _Time;  

		uniform int   _Iterations;
		uniform int   _VolSteps;
		uniform float _VolSize;
		uniform float _Brightness;
		uniform float _DistFading;
		uniform float _Saturation;
		uniform float _Cloud;
		uniform float _Zoom;
		uniform float _Speed;



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

		#define tile   0.450
		#define transverseSpeed 1.1
		#define cloud 0.1

 		
		float field(in vec3 p) 
		{
			
			float strength = 7. + .03 * log(1.e-6 + fract(sin(_Time.y) * 4373.11));
			float accum = 0.;
			float prev = 0.;
			float tw = 0.;
		
			for (int i = 0; i < 6; ++i) 
			{
				float mag = dot(p, p);
				p = abs(p) / mag + vec3(-.5, -.8 + 0.1*tan(_Time.y*0.2 + 2.0), -1.1+0.3*log(_Time.y*0.15));
				float w = exp(-float(i) / 7.);
				accum += w * exp(-strength * pow(abs(mag - prev), 2.3));
				tw += w;
				prev = mag;
			}
			return max(0., 5. * accum / tw - .7);
		}

		void main()
		{
			           
	        float speed = _Speed;
	    	float formuparam = .89;
				       
			//mouse rotation
			float a_xz = 0.9;
			float a_yz = -.6;
			float a_xy = 0.9 + _Time.y*0.04;
			
			
			mat2 rot_xz = mat2(cos(a_xz),sin(a_xz),-sin(a_xz),cos(a_xz));
			mat2 rot_yz = mat2(cos(a_yz),sin(a_yz),-sin(a_yz),cos(a_yz));
			mat2 rot_xy = mat2(cos(a_xy),sin(a_xy),-sin(a_xy),cos(a_xy));
			

			vec3 dir=vec3(uv *_Zoom, 1.);
		 
			vec3 from=vec3(0.0, 0.0,0.0);
		 
		                               
		        //from.x -= 5.0*(mouse.x-0.5);
		        //from.y -= 5.0*(mouse.y-0.5);
		               
		               
			vec3 forward = vec3(0.,0.,1.);
		               
			
			from.x += transverseSpeed*(1.0)*cos(0.01*_Time.y) + 0.001*_Time.y;
			from.y += transverseSpeed*(1.0)*sin(0.01*_Time.y) +0.001*_Time.y;
			
			from.z += 0.003*_Time.y;
			
			
			dir.xy*=rot_xy;
			forward.xy *= rot_xy;

			dir.xz*=rot_xz;
			forward.xz *= rot_xz;
				
			
			dir.yz*= rot_yz;
			forward.yz *= rot_yz;
			 

			
			from.xy*=-rot_xy;
			from.xz*=rot_xz;
			from.yz*= rot_yz;
			 
			
			float zooom = (_Time.y-3311.)*speed;
			from += forward* zooom;
			float sampleShift = mod( zooom, _VolSize );
			 
			float zoffset = -sampleShift;
			sampleShift /= _VolSize; 


////////////////////////////////			


			float s=0.24;
     		float s3 = s + _VolSize/2.0;
			vec3 v=vec3(0.);
			float t3 = 0.0;

//			
			vec3 backCol2 = vec3(0.);
			for (int r=0; r<_VolSteps; r++) 
			{
				vec3 p2=from+(s+zoffset)*dir;
				vec3 p3=(from+(s3+zoffset)*dir )* (1.9/_Zoom);
				
				p2 = abs(vec3(tile)-mod(p2,vec3(tile*2.))); 
				p3 = abs(vec3(tile)-mod(p3,vec3(tile*2.))); 
				
				t3 = field(p3);

				float pa,a=pa=0.;
				for (int i=0; i<_Iterations; i++) 
				{
					p2=abs(p2)/dot(p2,p2)-formuparam; // the magic formula
					//p=abs(p)/max(dot(p,p),0.005)-formuparam; // another interesting way to reduce noise
					float D = abs(length(p2)-pa); // absolute sum of average change
					
					if (i > 2)
					{
					a += i > 7 ? min( 12., D) : D;
					}
						pa=length(p2);
				}
				
				
				a*=a*a;
				float s1 = s+zoffset;
				float fade = pow(_DistFading,max(0.,float(r)-sampleShift));

				v+=fade;
				if( r == 0 )
					fade *= (1. - (sampleShift));
				// fade in samples as they approach from the distance
				if( r == _VolSteps-1 )
					fade *= sampleShift;
				v+=vec3(s1,s1*s1,s1*s1*s1*s1)*a*_Brightness*fade; // coloring based on distance
				
				backCol2 += mix(.4, 1., 1.0) * vec3(0.20 * t3 * t3 * t3, 0.4 * t3 * t3, t3 * 0.7) * fade;

				
				s+=_VolSize;
				s3 += _VolSize;
				
				
				
				}
				       
			v=mix(vec3(length(v)),v,_Saturation); //color adjust
			

			vec4 forCol2 = vec4(v*.01,1.);
			
				backCol2 *= _Cloud;
			
			gl_FragColor = forCol2 + vec4(backCol2, 1.0);



			
		 
		}




	#endif 
	ENDGLSL 
	}}}