namespace flowergarden;
using RaylibBeef;
using static RaylibBeef.Raylib;
using System;
using static RaylibBeef.Raymath;
using FastNoiseLite;

public class World
{
	public WorldInformation info;
	Chunk[] world;
	public Vector2I chunksize = Vector2I(16,16);
	Vector2I size = Vector2I(8,8);
	int fullsize;

	public Camera3D* camera;
	Entity[] live_entitys;
	Entity[] tick_entitys;
	int entity_focus = 0;
	int entity_limit = 128;
	private int open_live_entity_slot = 0;
	private int open_tick_entity_slot = 0;
	private int16 live_entity_count = 0;
	private int16 tick_entity_count = 0;
	private Vector3 entity_focus_position;
	private FastNoiseLite noise;
	private bool world_ready = false;
	private int tick_update_section = 0;
	public int camout = 5;
	public float camheight = 0.4f;
	public int entity_render_distance = 48;
	///billboard
	private Shader bilboard_shader;
	private Mesh* bilboard_mesh;
	private Material bilboard_material;
	private int32 bilbaord_shader_uni1;
	private int32 bilbaord_shader_uni2;
	private int32 bilbaord_shader_uni3;
	private int32 bilbaord_shader_uni4;
	private Texture terrain_texture;
	public Material terrain_material;

	public this(WorldInformation _info) {
		info = _info;
		camera = new Camera3D(Vector3(5,0,0),Vector3(0,0,0),Vector3(0,0,1),50,CameraProjection.CAMERA_PERSPECTIVE);

		live_entitys = new Entity[entity_limit];
		tick_entitys = new Entity[entity_limit];
		noise = new FastNoiseLite();
		noise.SetSeed(info.world_seed);

		fullsize = size.x * size.y;
		world = new Chunk[fullsize];

		let path = scope String();
		path.Append(GetWorkingDirectory());
		path.Append("/data/textures/terrain.png");
		terrain_texture = LoadTexture(path);

		terrain_material = LoadMaterialDefault();
		terrain_material.maps.texture = terrain_texture;

		for (int i = 0; i<fullsize; i++) {
			Chunk c = new Chunk(Meth.idx2pos(i,size.x),chunksize.x,chunksize.y);
			c.mesh_material = terrain_material;
			world[i] = c;
		}

		///shaders

		let fspath = scope String();
		fspath.Append(GetWorkingDirectory());
		fspath.Append("/data/shaders/bilboard.fs.txt");
		
		bilboard_shader = LoadShader(null,fspath);
		bilbaord_shader_uni1 = GetShaderLocation(bilboard_shader,"rect1");
		bilbaord_shader_uni2 = GetShaderLocation(bilboard_shader,"rect2");
		bilbaord_shader_uni3 = GetShaderLocation(bilboard_shader,"rect3");
		bilbaord_shader_uni4 = GetShaderLocation(bilboard_shader,"rect4");

		///bilboard mesh

		bilboard_material = LoadMaterialDefault();
		bilboard_material.shader = bilboard_shader;

		MeshData bmesh = new MeshData();

		bmesh.add_triangle(
			MeshVert(Vector3(0,-0.5f,0.5f),Vector3(-1,0,0),Vector2(1,0)),
			MeshVert(Vector3(0,-0.5f+1,0.5f),Vector3(-1,0,0),Vector2(0,0)),
			MeshVert(Vector3(0,-0.5f,0.5f-1),Vector3(-1,0,0),Vector2(1,1))
		);
		bmesh.add_triangle(
			MeshVert(Vector3(0,-0.5f,0.5f-1),Vector3(-1,0,0),Vector2(1,1)),
			MeshVert(Vector3(0,-0.5f+1,0.5f),Vector3(-1,0,0),Vector2(0,0)),
			MeshVert(Vector3(0,-0.5f+1,0.5f-1),Vector3(-1,0,0),Vector2(0,1))
		);

		bilboard_mesh = bmesh.create_mesh();
		UploadMesh(bilboard_mesh,false);

		

		delete bmesh;
	}

	public void ready() {
		for (int i=0; i<entity_limit; i++) {
			Entity ent = live_entitys[i];
			if (ent != null) {
				ent.ready();
			}
			Entity tent = tick_entitys[i];
			if (tent != null) {
				tent.ready();
			}
		}
		world_ready = true;
	}

	public void update() {
		///update entitys
		for (int i=0; i<entity_limit; i++) {
			Entity ent = live_entitys[i];
			if (ent != null && ent.active) {
				ent.update();
			}
		}

		///camera focus
		if (live_entitys[entity_focus] != null) {
			Entity ent = live_entitys[entity_focus];
			camera.target = ent.position;
			camera.position = ent.position;
			camera.position.x -= camout;
			camera.position.z += camout*camheight;
			entity_focus_position = ent.position;
		}
	}

	public void tick() {
		///update entitys
		int max = Math.Min(tick_update_section+64,entity_limit);
		for (int i=tick_update_section; i<max; i++) {
			Entity ent = tick_entitys[i];
			if (ent != null && ent.active) {
				ent.update();
			}
		}
		tick_update_section += 64;
		if (tick_update_section >= entity_limit) {
			tick_update_section = 0;
		}
	}

	public void draw() {
		let ppos = Vector2I((int)((entity_focus_position.x/chunksize.x)+0.5),(int)((entity_focus_position.y/chunksize.y)+0.5));

		//draw world
		for (int x = -3; x<3; x++) {
			for (int y = -3; y<3; y++) {
				Vector2I cpos = Vector2I(ppos.x+x,ppos.y+y);
				if (cpos.x >= 0 && cpos.x < size.x && cpos.y >= 0 && cpos.y < size.y) {
					let idx = Meth.pos2idx(cpos,size.x);
					Chunk c = world[idx];
					if (c.changed) {
						c.changed = false;
						generate_chunk_mesh(cpos);
					}

					c.draw();
				}
			}
		}

		//draw entitys
		for (int i=0; i<entity_limit; i++) {
			Entity ent = live_entitys[i];
			Entity tent = tick_entitys[i];
			if (ent != null && ent.renderable()) {
				ent.draw();
			}
			if (tent != null && tent.renderable()) {
				tent.draw();
			}
		}
	}

	public void clean() {
		for (int i=0; i<fullsize; i++) {
			world[i].cleanup();
		}
		delete world;

		for (int i=0; i<entity_limit; i++) {
			if (live_entitys[i] != null) {
				live_entitys[i].clean();
			}
			if (tick_entitys[i] != null) {
				tick_entitys[i].clean();
			}
		}
		UnloadMesh(*bilboard_mesh);
		delete bilboard_mesh;
		delete live_entitys;
		delete tick_entitys;
		delete camera;
		delete noise;
		delete this;
	}

	public Entity get_focused_entity() {
		Entity ent = live_entitys[entity_focus];
		return ent;
	}

	public void remove_entity(int index,bool live = true) {
		if (live) {
			delete live_entitys[index];
			live_entitys[index] = null;
			live_entity_count -= 1;
			Console.WriteLine("live entity deleted");
		}
		else {
			delete tick_entitys[index];
			tick_entitys[index] = null;
			tick_entity_count -= 1;
			Console.WriteLine("tick entity deleted");
		}
	}

	public void add_entity(Entity ent,Vector3 position = Vector3(0,0,0),bool live = true) {
		ent.myworld = this;
		ent.position = position;
		if (world_ready) {
			ent.ready();
		}

		if (live) {
			if (live_entity_count >= entity_limit) {
				Console.WriteLine("Live entity limit reached!");
				delete ent;
				return;
			}

			live_entity_count++;
			ent.index = open_live_entity_slot;
			live_entitys[open_live_entity_slot] = ent;
			
			Console.Write("LIVE ENTITYS: ");
			Console.Write(live_entity_count);
			Console.WriteLine("");
			let start = open_live_entity_slot;
			while (live_entitys[open_live_entity_slot] != null) {
				open_live_entity_slot += 1;
				if (open_live_entity_slot >= entity_limit) {
					open_live_entity_slot = 0;
				}
				if (open_live_entity_slot == start-1) {
					Console.WriteLine("start");
					break;
				}
			}
		}
		else {
			if (tick_entity_count >= entity_limit) {
				Console.WriteLine("Tick entity limit reached!");
				delete ent;
				return;
			}

			tick_entity_count++;
			ent.index = open_tick_entity_slot;
			tick_entitys[open_tick_entity_slot] = ent;
			
			Console.Write("TICK ENTITYS: ");
			Console.Write(tick_entity_count);
			Console.WriteLine("");
			let start = open_live_entity_slot;
			while (tick_entitys[open_tick_entity_slot] != null) {
				open_tick_entity_slot += 1;
				if (open_tick_entity_slot >= entity_limit) {
					open_tick_entity_slot = 0;
				}
				if (open_live_entity_slot == start-1) {
					Console.WriteLine("start");
					break;
				}
			}
		}
	}

	public bool world_block_inrange(Vector2I wpos) {
		Vector2I cpos = Vector2I(wpos.x / chunksize.x,wpos.y / chunksize.y);
		if (cpos.x < 0 || cpos.x >= size.x || cpos.y < 0 || cpos.y >= size.y) {
			return false;
		}

		Vector2I bpos = Vector2I(wpos.x % chunksize.x, wpos.y % chunksize.y);
		if (bpos.x < 0 || bpos.x >= chunksize.x || bpos.y < 0 || bpos.y >= chunksize.y) {
			return false;
		}

		return true;
	}

	public ChunkBlock get_world_block(Vector2I wpos) {
		
		Vector2I cpos = Vector2I(wpos.x / chunksize.x,wpos.y / chunksize.y);
		Chunk chunk = world[Meth.pos2idx(cpos,size.x)];
		Vector2I bpos = Vector2I(wpos.x % chunksize.x, wpos.y % chunksize.y);
		return chunk.get(bpos);
	}

	public void set_world_block_value(Vector2I wpos, int value) {
		
		Vector2I cpos = Vector2I(wpos.x / chunksize.x,wpos.y / chunksize.y);
		Chunk chunk = world[Meth.pos2idx(cpos,size.x)];
		Vector2I bpos = Vector2I(wpos.x % chunksize.x, wpos.y % chunksize.y);

		ChunkBlock old = chunk.get(bpos);
		chunk.set_value(bpos,value);

		if (old.blockid != value) {
			chunk.changed = true;
		}
	}

	//generation

	public void generate_world() {
		for (int i = 0; i<fullsize; i++) {
			Vector2I pos = Meth.idx2pos(i,size.x);
			fill_chunk(pos);
			generate_chunk_mesh(pos);
		}
	}

	public void fill_chunk(Vector2I pos) {
		int idx = Meth.pos2idx(pos,size.x);
		Chunk chunk = world[idx];

		for (int i = 0; i<(chunksize.x*chunksize.y); i++) {
			Vector2I local_bpos = Meth.idx2pos(i,chunksize.x);
			Vector2I world_bpos = Vector2I((chunk.chunkpos.x * chunksize.x) + local_bpos.x,(chunk.chunkpos.y * chunksize.y) + local_bpos.y);
			float bnoise = noise.GetNoise(world_bpos.x*4,world_bpos.y*4);
			if (bnoise > 0.2f) {
				chunk.set_above(local_bpos,true);
			}
		}
	}

	public void generate_chunk_mesh(Vector2I pos) {
		int idx = Meth.pos2idx(pos,size.x);
		Chunk chunk = world[idx];

		MeshData meshdata = new MeshData();

		//meshdata.add_triangle(MeshVert(Vector3(0,0,0)),MeshVert(Vector3(8,0,0)),MeshVert(Vector3(0,8,0)));
		//meshdata.add_triangle(MeshVert(Vector3(8,8,0)),MeshVert(Vector3(0,8,0)),MeshVert(Vector3(8,0,0)));

		for (int x = 0; x<chunksize.x; x++) {
			for (int y = 0; y<chunksize.y; y++) {
				Vector2I wpos = Vector2I((pos.x * chunksize.x) + x,( pos.y * chunksize.y) + y);
				ChunkBlock wblock = get_world_block(wpos);
				int bheight = 0;
				if (wblock.above) {
					bheight = 1;
				}
				Block block = Blocks.blocks[wblock.blockid];
				Rectangle texrec = Rectangle(block.top_texture.x * 32,block.top_texture.y * 32,32,32);
				meshdata.add_triangle_atlas(
					ref MeshVert(Vector3(x,y,bheight),Vector3(0,0,1),Vector2(0,0),WHITE),
					ref MeshVert(Vector3(x+1,y,bheight),Vector3(0,0,1),Vector2(1,0),WHITE),
					ref MeshVert(Vector3(x,y+1,bheight),Vector3(0,0,1),Vector2(0,1),WHITE),
					texrec,
					terrain_texture
				);
				meshdata.add_triangle_atlas(
					ref MeshVert(Vector3(x+1,y,bheight),Vector3(0,0,1),Vector2(1,0),WHITE),
					ref MeshVert(Vector3(x+1,y+1,bheight),Vector3(0,0,1),Vector2(1,1),WHITE),
					ref MeshVert(Vector3(x,y+1,bheight),Vector3(0,0,1),Vector2(0,1),WHITE),
					texrec,
					terrain_texture
				);

				///sides

				if (wblock.above) {
					Vector2I wpos_down = Vector2I(wpos.x-1,wpos.y);
					if (world_block_inrange(wpos_down)) {
						ChunkBlock wblock_down = get_world_block(wpos_down);
						if (!wblock_down.above) {
							Rectangle s_texrec = Rectangle(block.side_texture.x * 32,block.side_texture.y * 32,32,32);
							meshdata.add_triangle_atlas(
								ref MeshVert(Vector3(x,y+1,bheight),Vector3(-1,0,0),Vector2(1,0)),
								ref MeshVert(Vector3(x,y+1,0),Vector3(-1,0,0),Vector2(1,1)),
								ref MeshVert(Vector3(x,y,0),Vector3(-1,0,0),Vector2(0,1)),
								s_texrec,
								terrain_texture
							);

							meshdata.add_triangle_atlas(
								ref MeshVert(Vector3(x,y,0),Vector3(-1,0,0),Vector2(0,1)),
								ref MeshVert(Vector3(x,y,bheight),Vector3(-1,0,0),Vector2(0,0)),
								ref MeshVert(Vector3(x,y+1,bheight),Vector3(-1,0,0),Vector2(1,0)),
								s_texrec,
								terrain_texture
							);
						}
						
					}


					Vector2I wpos_left = Vector2I(wpos.x,wpos.y-1);
					if (world_block_inrange(wpos_left)) {
						ChunkBlock wblock_left = get_world_block(wpos_left);
						if (!wblock_left.above) {
							Rectangle s_texrec = Rectangle(block.side_texture.x * 32,block.side_texture.y * 32,32,32);
							meshdata.add_triangle_atlas(
								ref MeshVert(Vector3(x,y,0),Vector3(-1,0,0),Vector2(0,1)),
								ref MeshVert(Vector3(x+1,y,0),Vector3(-1,0,0),Vector2(1,1)),
								ref MeshVert(Vector3(x+1,y,bheight),Vector3(-1,0,0),Vector2(1,0)),
								s_texrec,
								terrain_texture
							);

							meshdata.add_triangle_atlas(
								ref MeshVert(Vector3(x+1,y,bheight),Vector3(-1,0,0),Vector2(1,0)),
								ref MeshVert(Vector3(x,y,bheight),Vector3(-1,0,0),Vector2(0,0)),
								ref MeshVert(Vector3(x,y,0),Vector3(-1,0,0),Vector2(0,1)),
								s_texrec,
								terrain_texture
							);
						}
						
					}


					Vector2I wpos_right = Vector2I(wpos.x,wpos.y+1);
					if (world_block_inrange(wpos_right)) {
						ChunkBlock wblock_right = get_world_block(wpos_right);
						if (!wblock_right.above) {
							Rectangle s_texrec = Rectangle(block.side_texture.x * 32,block.side_texture.y * 32,32,32);
							meshdata.add_triangle_atlas(
								ref MeshVert(Vector3(x+1,y+1,bheight),Vector3(1,0,0),Vector2(1,0)),
								ref MeshVert(Vector3(x+1,y+1,0),Vector3(1,0,0),Vector2(1,1)),
								ref MeshVert(Vector3(x,y+1,0),Vector3(1,0,0),Vector2(0,1)),
								s_texrec,
								terrain_texture
							);

							meshdata.add_triangle_atlas(
								ref MeshVert(Vector3(x,y+1,0),Vector3(1,0,0),Vector2(0,1)),
								ref MeshVert(Vector3(x,y+1,bheight),Vector3(1,0,0),Vector2(0,0)),
								ref MeshVert(Vector3(x+1,y+1,bheight),Vector3(1,0,0),Vector2(1,0)),
								s_texrec,
								terrain_texture
							);
						}
						
					}
				}
			}
		}

		chunk.replace_mesh(meshdata);
		meshdata.cleanup();

		Console.WriteLine("GENERATED CHUNK");
	}

	///drawling

	public void draw_billboard(Texture texture,Vector3 position,Vector2 scale,ref Rectangle draw_rect) {
		draw_rect.width = draw_rect.width/ texture.width;
		draw_rect.height = draw_rect.height/ texture.height;
		draw_rect.x = draw_rect.x/texture.width;
		draw_rect.y = draw_rect.y/texture.height;
		SetShaderValue(bilboard_shader,bilbaord_shader_uni1,&draw_rect.width,ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
		SetShaderValue(bilboard_shader,bilbaord_shader_uni2,&draw_rect.height,ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
		SetShaderValue(bilboard_shader,bilbaord_shader_uni3,&draw_rect.x,ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
		SetShaderValue(bilboard_shader,bilbaord_shader_uni4,&draw_rect.y,ShaderUniformDataType.SHADER_UNIFORM_FLOAT);

		bilboard_material.maps.texture = texture;
		
		Matrix bilboard_matrix = MatrixMultiply(MatrixScale(0,scale.x,scale.y),MatrixTranslate(position.x,position.y,position.z));
		DrawMesh(*bilboard_mesh,bilboard_material,bilboard_matrix);
	}
}