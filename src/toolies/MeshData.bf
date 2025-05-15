namespace flowergarden;
using RaylibBeef;
using static RaylibBeef.Raylib;
using System;

public class MeshData
{
	public MeshVert[1024][3] triangles;
	private int tri_pos; 

	public this() {
		tri_pos = 0;
		triangles = MeshVert[1024][3]();
	}

	public void add_triangle(MeshVert _v1,MeshVert _v2,MeshVert _v3) {
		if (tri_pos >= 1024) {
			System.Console.WriteLine("Triangle limit reached!!!!");
			return;
		}
		triangles[tri_pos][0] = _v1;
		triangles[tri_pos][1] = _v2;
		triangles[tri_pos][2] = _v3;

		tri_pos += 1;
	}

	public void add_triangle_atlas(ref MeshVert _v1,ref MeshVert _v2,ref MeshVert _v3,Rectangle rec,Texture atlas) {
		if (tri_pos >= 1024) {
			System.Console.WriteLine("Triangle limit reached!!!!");
			return;
		}
		_v1.texcoord.x *= rec.width / atlas.width;
		_v1.texcoord.y *= rec.height / atlas.height;
		_v1.texcoord.x += rec.x / atlas.width;
		_v1.texcoord.y += rec.y / atlas.height;

		_v2.texcoord.x *= rec.width / atlas.width;
		_v2.texcoord.y *= rec.height / atlas.height;
		_v2.texcoord.x += rec.x / atlas.width;
		_v2.texcoord.y += rec.y / atlas.height;

		_v3.texcoord.x *= rec.width / atlas.width;
		_v3.texcoord.y *= rec.height / atlas.height;
		_v3.texcoord.x += rec.x / atlas.width;
		_v3.texcoord.y += rec.y / atlas.height;

		///apply
		triangles[tri_pos][0] = _v1;
		triangles[tri_pos][1] = _v2;
		triangles[tri_pos][2] = _v3;

		tri_pos += 1;
	}


	public void cleanup() {
		delete this;
	}

	public Mesh* create_mesh() {
		int32 tri_count = (int32)tri_pos;
		int32 vert_count = (int32)tri_pos*3;

		Mesh* mesh = new Mesh(vert_count,tri_count,null,null,null,null,null,null,null,null,null,null,null,null,0,0,null);
		mesh.vertices = (float*)MemAlloc(mesh.vertexCount * 3 * sizeof(float));    // 3 vertices, 3 coordinates each (x, y, z)
		mesh.texcoords = (float*)MemAlloc(mesh.vertexCount * 2 * sizeof(float));   // 3 vertices, 2 coordinates each (x, y)
		mesh.normals = (float*)MemAlloc(mesh.vertexCount * 3 * sizeof(float));
		//mesh.colors = (float*)MemAlloc(mesh.vertexCount * 4 * sizeof(float));
		//mesh.colors = (float *)MemAlloc(vert_count*4*sizeof(float));

		Console.WriteLine(mesh.vertices);

		float* m_verticies = (float*)mesh.vertices;
		float* m_normals = (float*)mesh.normals;
		float* m_texcoords = (float*)mesh.texcoords;
		//float* m_colors = (float*)mesh.colors;
		int vcount = 0;
		int tcount = 0;
		int ncount = 0;
		int ccount = 0;

		for (int i = 0; i < tri_count; i++) {
			var tri = triangles[i];

			var v1 = tri[0];
			var v2 = tri[1];
			var v3 = tri[2];

			///V1
			m_verticies[vcount] = v1.position.x;
			m_verticies[vcount+1] = v1.position.y;
			m_verticies[vcount+2] = v1.position.z;
			vcount += 3;
			m_normals[ncount] = v1.normal.x;
			m_normals[ncount+1] = v1.normal.y;
			m_normals[ncount+2] = v1.normal.z;
			ncount += 3;
			m_texcoords[tcount] = v1.texcoord.x;
			m_texcoords[tcount+1] = v1.texcoord.y;
			tcount += 2;
			//m_colors[ccount] = v1.color.x;
			//m_colors[ccount+1] = v1.color.y;
			//m_colors[ccount+2] = v1.color.z;
			//m_colors[ccount+3] = v1.color.w;
			ccount += 4;

			///V2
			m_verticies[vcount] = v2.position.x;
			m_verticies[vcount+1] = v2.position.y;
			m_verticies[vcount+2] = v2.position.z;
			vcount += 3;
			m_normals[ncount] = v2.normal.x;
			m_normals[ncount+1] = v2.normal.y;
			m_normals[ncount+2] = v2.normal.z;
			ncount += 3;
			m_texcoords[tcount] = v2.texcoord.x;
			m_texcoords[tcount+1] = v2.texcoord.y;
			tcount += 2;
			//m_colors[ccount] = v2.color.x;
			//m_colors[ccount+1] = v2.color.y;
			//m_colors[ccount+2] = v2.color.z;
			//m_colors[ccount+3] = v2.color.w;
			ccount += 4;

			m_verticies[vcount] = v3.position.x;
			m_verticies[vcount+1] = v3.position.y;
			m_verticies[vcount+2] = v3.position.z;
			vcount += 3;
			m_normals[ncount] = v3.normal.x;
			m_normals[ncount+1] = v3.normal.y;
			m_normals[ncount+2] = v3.normal.z;
			ncount += 3;
			m_texcoords[tcount] = v3.texcoord.x;
			m_texcoords[tcount+1] = v3.texcoord.y;
			tcount += 2;
			//m_colors[ccount] = v3.color.x;
			//m_colors[ccount+1] = v3.color.y;
			//m_colors[ccount+2] = v3.color.z;
			//m_colors[ccount+3] = v3.color.w;
			ccount += 4;
		}

		/*
		m_verticies[0] = 0;
		m_verticies[1] = 0;
		m_verticies[2] = 0;
		m_normals[0] = 0;
		m_normals[1] = 0;
		m_normals[2] = 1;
		m_texcoords[0] = 0;
		m_texcoords[1] = 0;

		m_verticies[3] = 8;
		m_verticies[4] = 0;
		m_verticies[5] = 0;
		m_normals[3] = 0;
		m_normals[4] = 0;
		m_normals[5] = 1;
		m_texcoords[2] = 0;
		m_texcoords[3] = 0;

		m_verticies[6] = 0;
		m_verticies[7] = 8;
		m_verticies[8] = 0;
		m_normals[6] = 0;
		m_normals[7] = 0;
		m_normals[8] = 1;
		m_texcoords[4] = 0;
		m_texcoords[5] = 0;

		for (int i = 0; i < tri_count; i++) {
			var tri = triangles[i];

			for (int j = 0; j<3; j++) {
				Console.WriteLine(tri[j].position.x);
				///vert
				m_verticies[vcount] = tri[j].position.x;
				vcount += 1;
				m_verticies[vcount] = tri[j].position.y;
				vcount += 1;
				m_verticies[vcount] = tri[j].position.z;
				vcount += 1;

				///normal
				m_normals[ncount] = tri[j].normal.x;
				ncount += 1;
				m_normals[ncount] = tri[j].normal.y;
				ncount += 1;
				m_normals[ncount] = tri[j].normal.z;
				ncount += 1;

				///normal
				m_texcoords[tcount] = tri[j].texcoord.x;
				tcount += 1;
				m_texcoords[tcount] = tri[j].texcoord.y;
				tcount += 1;

				/*
				///colors
				mesh.colors[ccount] = tri[j].color.r;
				ccount += 1;
				mesh.colors[ccount] = tri[j].color.g;
				ccount += 1;
				mesh.colors[ccount] = tri[j].color.b;
				ccount += 1;
				mesh.colors[ccount] = tri[j].color.a;
				ccount += 1;
				*/
			}
		}
		*/

		//UploadMesh(mesh,false);
		return mesh;
	}
}

/*

using System;
using Raylib; // Assuming Raylib bindings exist in Beef

namespace MyRaylibApp
{
    class Program
    {
        static void Main()
        {
            Mesh mesh = default;

            mesh.triangleCount = 1;
            mesh.vertexCount = mesh.triangleCount * 3;

            mesh.vertices = (float*)MemAlloc((uint)(mesh.vertexCount * 3 * sizeof(float)));
            mesh.texcoords = (float*)MemAlloc((uint)(mesh.vertexCount * 2 * sizeof(float)));
            mesh.normals = (float*)MemAlloc((uint)(mesh.vertexCount * 3 * sizeof(float)));

            // Vertex 1 (0, 0, 0)
            mesh.vertices[0] = 0;
            mesh.vertices[1] = 0;
            mesh.vertices[2] = 0;
            mesh.normals[0] = 0;
            mesh.normals[1] = 1;
            mesh.normals[2] = 0;
            mesh.texcoords[0] = 0;
            mesh.texcoords[1] = 0;

            // Vertex 2 (1, 0, 2)
            mesh.vertices[3] = 1;
            mesh.vertices[4] = 0;
            mesh.vertices[5] = 2;
            mesh.normals[3] = 0;
            mesh.normals[4] = 1;
            mesh.normals[5] = 0;
            mesh.texcoords[2] = 0.5f;
            mesh.texcoords[3] = 1.0f;

            // Vertex 3 (2, 0, 0)
            mesh.vertices[6] = 2;
            mesh.vertices[7] = 0;
            mesh.vertices[8] = 0
