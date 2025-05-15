namespace flowergarden;
using RaylibBeef;
using System;
using System.Collections;

static public class Blocks
{
	static public Block[] blocks = new Block[32];

	static public this() {
		///grass block
		blocks[0] = Block(Vector2(0,0),Vector2(1,0) );
		////petal blocks
		blocks[1] = Block(Vector2(2,0),Vector2(1,0) );
		blocks[2] = Block(Vector2(3,0),Vector2(1,0) );
		blocks[3] = Block(Vector2(4,0),Vector2(1,0) );
		blocks[4] = Block(Vector2(5,0),Vector2(1,0) );
		blocks[5] = Block(Vector2(6,0),Vector2(1,0) );
		blocks[6] = Block(Vector2(7,0),Vector2(0,1) );
	}

	static public void clean() {
		delete blocks;
	}
}