namespace flowergarden;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.Raymath;
using System;

class Chunk
{
	public Mesh* mesh;
	public Vector2I chunkpos;
	ChunkBlock[] chunk;
	Vector2I size;
	int fullsize;
	public Material mesh_material;
	private Matrix mesh_matrix;
	private Model mesh_model;
	public bool generated = false;
	public bool changed = false;

	public this(Vector2I _chunkpos,int _width,int _height,ChunkBlock _fill = ChunkBlock(false,0)) {
		size = Vector2I(_width,_height);
		fullsize = _width * _height;
		chunk = new ChunkBlock[fullsize];
		chunk.SetAll(_fill);
		chunkpos = _chunkpos;
		
		mesh_matrix = MatrixAdd(MatrixTranslate(chunkpos.x*size.x*2,chunkpos.y*size.y*2,0),MatrixScale(1,1,1));
	}

	public void draw() {
		//DrawCubeWires(Vector3((chunkpos.x+0.5f) * size.x, (chunkpos.y+0.5f) * size.y,0.5f),size.x,size.y,1,BLACK);
		if (generated) {
			DrawMesh(*mesh,mesh_material,mesh_matrix);
		}
	}

	public void replace_mesh(MeshData new_mesh) {
		if (generated) {
			System.Console.WriteLine("Unloading chunk mesh");
			UnloadMesh(*mesh);
			delete mesh;
			generated = false;
		}

		mesh = new_mesh.create_mesh();
		UploadMesh(mesh,false);
		//mesh_model = LoadModelFromMesh(*new_mesh);
		generated = true;
	}

	public void cleanup() {
		if (generated) {
			System.Console.WriteLine("Unloading chunk mesh");
			UnloadMesh(*mesh);
			generated = false;
		}
		delete mesh;
		delete chunk;
		delete this;
	}

	public ChunkBlock get(Vector2I pos) {
		return chunk[Meth.pos2idx(pos,size.x)];
	}

	public void set(Vector2I pos, ChunkBlock setto) {
		chunk[Meth.pos2idx(pos,size.x)] = setto;
	}

	public void set_above(Vector2I pos, bool setto) {
		chunk[Meth.pos2idx(pos,size.x)].above = setto;
	}

	public void set_value(Vector2I pos, int setto) {
		chunk[Meth.pos2idx(pos,size.x)].blockid = setto;
	}
}