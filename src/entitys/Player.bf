namespace flowergarden;
using System;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;

class Player : Entity
{
	private Texture texture;
	private float texture_x = 0;
	private float texture_y = 0;
	private Vector3 movedir;
	private const float movespeed = 0.8f;
	private const float drag = 1.1f;
	private const float gravity = 0.4f;
	private const float jumpheight = 0.135f;

	public this() {
		hitbox.x = 0.5f;
		hitbox.y = 0.5f;
		hitbox.z = 1.5f;

		texture = TextureManager.texture_load("/data/textures/player.png");
	}

	public override void ready() {
		snap_to_floor();
	}

	public override void update() {
		let dt = GetFrameTime();
		float w_axis = ((IsKeyDown(key:.KEY_W) ? 1 : 0) - (IsKeyDown(key:.KEY_S) ? 1 : 0));
		float a_axis = ((IsKeyDown(key:.KEY_A) ? 1 : 0) - (IsKeyDown(key:.KEY_D) ? 1 : 0));
		var keydir = Vector3(w_axis,a_axis,0);

		movedir = Vector3Add(movedir,Vector3(keydir.x*movespeed*dt,keydir.y*movespeed*dt,0));

		if (IsKeyPressed(key:.KEY_R)) {
			Vector2I cpos = Vector2I((int)position.x / myworld.chunksize.x,(int)position.y / myworld.chunksize.y);
			myworld.generate_chunk_mesh(cpos);
		}

		if (IsKeyPressed(key:.KEY_E)) {
			myworld.add_entity(new Flower(),position,false);
		}

		if (IsKeyPressed(key:.KEY_F4)) {
			ToggleFullscreen();
		}

		if (IsKeyPressed(key:.KEY_SPACE)) {
			movedir.z = jumpheight;
		}

		if (IsKeyPressed(key:.KEY_DOWN)) {
			myworld.camout += 1;
		}
		if (IsKeyPressed(key:.KEY_UP)) {
			myworld.camout -= 1;
		}

		movedir.z -= gravity * dt;

		check_collision(ref movedir);

		movedir.x /= drag;
		movedir.y /= drag;

		///apply
		position.x += movedir.x;
		position.y += movedir.y;
		position.z += movedir.z;

		///animation

		if (keydir == Vector3(0,1,0)) {
			texture_x = 32*3;
		}
		else if (keydir == Vector3(0,-1,0)) {
			texture_x = 32;
		}
		else if (keydir == Vector3(1,0,0)) {
			texture_x = 32*2;
		}
		else if (keydir == Vector3(-1,0,0)) {
			texture_x = 0;
		}
	}

	public override void draw() {
		//DrawCubeWires(position,hitbox.x,hitbox.y,hitbox.z,PINK);
		myworld.draw_billboard(texture,position,Vector2(hitbox.z/2,hitbox.z),ref Rectangle(texture_x,0,32,64));
		//BeginShaderMode(myworld.bilboard_shader);
		//DrawBillboardPro(*myworld.camera,texture,Rectangle(texture_x,texture_y,32,64),position,Vector3(0,0,1),Vector2(hitbox.z/2,hitbox.z),Vector2(hitbox.z/4,hitbox.z/2),0,WHITE);
		//EndShaderMode();
	}
}