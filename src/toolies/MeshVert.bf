using System;
using System.Interop;
using RaylibBeef;
using static RaylibBeef.Raylib;
namespace flowergarden;

public struct MeshVert
{
	public Vector3 position;
	public Vector3 normal;
	public Vector2 texcoord;
	public Vector4 color;

	public this(Vector3 _pos, Vector3 _norm = Vector3(0,0,1), Vector2 _tex = Vector2(0,0), Color _color = RED) {
		this.position = _pos;
		this.normal = _norm;
		this.texcoord = _tex;
		this.color = Vector4(1,1,1,1);
	}
}
