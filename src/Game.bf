namespace flowergarden;
using RaylibBeef;
using System;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;
using System.Collections;

class Game
{
	Texture sky;
	public this() {
		let scale = 1;
		SetConfigFlags(flags:.FLAG_VSYNC_HINT);
		InitWindow(800*scale,600*scale,"Flower Garden");
		SetTargetFPS(60);

		let path = scope String();
		path.Append(GetWorkingDirectory());
		path.Append("/data/textures/sky.png");
		sky = LoadTexture(path);
		
		//TextureManager.upload_texture("/data/textures/flower.png");
	}

	public void run() {
		float ticker = 0;

		World world = new World(WorldInformation("World Name",100));
		world.add_entity(new Player());
		world.add_entity(new Flower(),Vector3(3,3,0.5f),false);
		world.generate_world();
		world.ready();

		String debug_string1 = scope .();
		let focus_ent = world.get_focused_entity();

		while (!WindowShouldClose()) {
			///UPDATING
			world.update();
			ticker += 1f * GetFrameTime();
			if (ticker >= 0.5f) {
				ticker = 0;
				world.tick();
			}

			///DRAWING
			BeginDrawing();
			ClearBackground(BLACK);
			DrawTextureEx(sky,Vector2(0,0),0,2,WHITE);

			BeginMode3D(*world.camera);

			world.draw();
			//DrawMesh(testmesh,mat,matrix);

			EndMode3D();
			DrawFPS(10,10);

			//StringBeans.draw_vector3(focus_ent.position,debug_string1,10,20);
			StringBeans.draw_vector3(Vector3(Math.Floor(focus_ent.position.x / world.chunksize.x),Math.Floor(focus_ent.position.y / world.chunksize.y),0),debug_string1,10,40);
			ticker.ToString(debug_string1);
			DrawText(debug_string1,10,70,24,BLACK);
			debug_string1.Clear();

			EndDrawing();
		}
		CloseWindow();
		Blocks.clean();
		TextureManager.clean();
		world.clean();
		delete this;
	}
}