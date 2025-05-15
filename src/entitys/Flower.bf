namespace flowergarden;
using System;
using RaylibBeef;
using static RaylibBeef.Raylib;

class Flower : Entity
{
	private Texture2D texture;
	public int growth = 0;
	public int maxgrowth = 50;
	private float max_size = (float)GetRandomValue(80,130)/(float)100;
	private int petal_create = 0;
	private int petal_create_end = 10;
	private int texture_x = 0;
	private float anim = 0;
	
	public this() {
		texture = TextureManager.texture_load("/data/textures/flower.png");

		hitbox.x = 1;
		hitbox.y = 1;
		hitbox.z = 1;

		texture_x = GetRandomValue(0,1)*32;
	}

	public override void ready() {
		snap_to_floor();
		petal_create_end = GetRandomValue(5,15)*2;
	}

	public override void update() {
		growth += 1;
		if (growth >= maxgrowth) {
			growth = maxgrowth;
		}

		if (texture_x == 32) {
			texture_x = 0;
		}
		else {
			texture_x = 32;
		}

		petal_create += 1;
		if (petal_create >= petal_create_end) {
			petal_create = 0;
			petal_create_end = GetRandomValue(5,15)*2;
			Vector3 pp = position;
			pp.x += (float)GetRandomValue(-50,50)/(float)100;
			pp.y += (float)GetRandomValue(-50,50)/(float)100;
			pp.z += 0.2f;
			myworld.add_entity(new Petal(),pp,true);
		}
	}

	public override void draw() {
		let s = (float)Math.Lerp(0.25,max_size,(float)growth/(float)maxgrowth);
		//BeginShaderMode(myworld.bilboard_shader);
		//DrawBillboard(*myworld.camera,texture,position,1f,WHITE);
		myworld.draw_billboard(texture,Vector3(position.x,position.y,position.z - 0.5f + (s/2)),Vector2(s,s),ref Rectangle(texture_x,0,32,32));
		//DrawBillboardPro(*myworld.camera,texture,Rectangle(0,0,texture.width,texture.height),position,Vector3(0,0,1),Vector2(s,s),Vector2(0.5f,0.5f),0,WHITE);
		//EndShaderMode();
		//DrawCubeWires(position,hitbox.x,hitbox.y,hitbox.z,RED);
	}
}