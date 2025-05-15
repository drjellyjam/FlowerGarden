namespace flowergarden;
using RaylibBeef;
using System;
using static RaylibBeef.Raymath;

abstract class Entity
{
	public int index;
	public World myworld;
	public Vector3 position = Vector3(0,0,0);
	public Vector3 hitbox = Vector3(1,1,1);
	public bool active = true;
	public bool visible = true;

	public abstract void update();
	public abstract void draw();
	public abstract void ready();
	public virtual void clean() {
		delete this;
	}

	private bool above = false;

	public bool renderable() {
		if (!visible) {
			return false;
		}
		if (position.x < myworld.camera.position.x) {
			return false;
		}

		return (Vector3Distance(myworld.camera.position,position) <= myworld.entity_render_distance);
	}

	public Vector2I get_block_pos(Vector3 ppos) {
		return Vector2I((int)Math.Floor(ppos.x),(int)Math.Floor(ppos.y));
	}

	public void snap_to_floor() {
		Vector2I blockpos = Vector2I((int)Math.Floor(position.x),(int)Math.Floor(position.y));
		if (myworld.world_block_inrange(blockpos)) {
			ChunkBlock at = myworld.get_world_block(blockpos);
			if (at.above) {
				above = true;
				position.z = 1 + (hitbox.z/2);
			}
			else {
				above = false;
				position.z = (hitbox.z/2);
			}
		}
	}

	public bool check_collision_point(Vector3 velocity) {
		Vector3 ppos = Vector3(position.x+velocity.x,position.y+velocity.y,position.z+velocity.z);
		Vector2I blockpos = Vector2I((int)Math.Floor(ppos.x),(int)Math.Floor(ppos.y));
		if (!myworld.world_block_inrange(blockpos)) {
			return false;
		}
		if (!myworld.get_world_block(blockpos).above) {
			if (position.z <= 0) {
				return true;
			}
		}
		else {
			if (position.z <= 1) {
				return true;
			}
		}
		return false;
	}

	public void check_collision(ref Vector3 velocity) {
		Vector3 ppos = Vector3(position.x+velocity.x,position.y+velocity.y,position.z+velocity.z);
		Vector3I blockpos = Vector3I((int)Math.Floor(ppos.x),(int)Math.Floor(ppos.y),(int)Math.Floor(ppos.z));
		Vector3I hitboxblock = Vector3I((int)Math.Ceiling(hitbox.x),(int)Math.Ceiling(hitbox.y),(int)Math.Ceiling(hitbox.z));
		float feet_y = ppos.z - (hitbox.z/2);
		bool coolide_x = false;
		bool coolide_y = false;

		for (int x = -hitboxblock.x; x<=hitboxblock.x; x++) {
			Vector2I checkblockpos = Vector2I(blockpos.x + x,blockpos.y);
			if (myworld.world_block_inrange(checkblockpos)) {
				if (myworld.get_world_block(checkblockpos).above) {
					if (ppos.x + (hitbox.x/2) >= checkblockpos.x && ppos.x - (hitbox.x/2) <= checkblockpos.x+1) {
						coolide_x = true;
					}
				}
			}
		}
		for (int y = -hitboxblock.y; y<=hitboxblock.y; y++) {
			Vector2I checkblockpos = Vector2I(blockpos.x,blockpos.y + y);
			if (myworld.world_block_inrange(checkblockpos)) {
				if (myworld.get_world_block(checkblockpos).above) {
					if (ppos.y + (hitbox.y/2) >= checkblockpos.y && ppos.y - (hitbox.y/2) <= checkblockpos.y+1) {
						coolide_y = true;
					}
				}
			}
		}

		if (above) {
			if (coolide_x || coolide_y) {
				if (feet_y <= 1) {
					velocity.z = 0;
					position.z = 1 + (hitbox.z/2);
				}
			}
			else {
				above = false;
			}
		}
		else {
			if (coolide_y) {
				velocity.y = 0;
			}
			if (coolide_x) {
				velocity.x = 0;
			}
			if (feet_y > 1) {
				above = true;
			}
			else {
				if (feet_y <= 0) {
					velocity.z = 0;
					position.z = hitbox.z/2;
				}
			}
		}
	}
}