namespace flowergarden;

static class Meth
{
	///good
	static public Vector2I idx2pos(int idx,int width) {
		return Vector2I(
		    idx % width,
			idx / width
		);
	}

	static public int pos2idx(Vector2I pos,int width) {
		return pos.y * width + pos.x;
	}
}