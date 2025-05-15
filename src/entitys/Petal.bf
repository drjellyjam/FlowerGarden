namespace flowergarden;
using RaylibBeef;
using static RaylibBeef.Raylib;
using System;

class Petal : Entity
{
	private Vector3 movedir;
	private Texture texture;
	private int texture_x = 0;
	private float anim = 0;

	public this() {
		movedir = Vector3(0,0,0);

		texture = TextureManager.texture_load("/data/textures/petal.png");
	}

	public override void ready() {
		movedir.x = 0;
		movedir.y = 2f;
		movedir.z = -0.25f;
		hitbox.x = 0.1f;
		hitbox.y = 0.1f;
		hitbox.z = 0.1f;
	}

	public override void update() {
		let dt = GetFrameTime();

		anim += dt;
		if (anim >= 1) {
			anim = 0;

			if (texture_x == 16) {
				texture_x = 0;
			}
			else {
				texture_x = 16;
			}
		}

		position.x += movedir.x * dt;
		position.y += movedir.y * dt;
		position.z += movedir.z * dt;

		if (check_collision_point(movedir)) {
			Vector2I pos = get_block_pos(position);
			if (myworld.world_block_inrange(pos)) {
				ChunkBlock block = myworld.get_world_block(pos);
				if (block.blockid == 0) {
					myworld.set_world_block_value(pos,1);
				}
				else if (block.blockid == 1) {
					myworld.set_world_block_value(pos,2);
				}
				else if (block.blockid == 2) {
					myworld.set_world_block_value(pos,3);
				}
				else if (block.blockid == 3) {
					myworld.set_world_block_value(pos,4);
				}
				else if (block.blockid == 4) {
					myworld.set_world_block_value(pos,5);
				}
				else if (block.blockid == 5) {
					myworld.set_world_block_value(pos,6);
				}
			}
			myworld.remove_entity(index,true);
		}
	}

	public override void draw() {
		//DrawSphere(position,0.1f,YELLOW);
		myworld.draw_billboard(texture,position,Vector2(0.25f,0.25f),ref Rectangle(texture_x,0,16,16));
	}
}