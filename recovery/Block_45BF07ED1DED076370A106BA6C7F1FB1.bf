using System;
using System.Interop;
using RaylibBeef;
using static RaylibBeef.Raylib;
namespace flowergarden;

public struct Block {
	public Vector2 top_texture;
	public Vector2 side_texture;

	public this(Vector2 _top_texture,Vector2 _side_texture) {
		this.top_texture = _top_texture;
		this.side_texture = _side_texture;
	}
}

public  struct ChunkBlock {
	public bool above;
	public int blockid;

	public this(bool _above,int _blockid) {
		this.above = _above;
		this.blockid = _blockid;
	}
}