namespace flowergarden;
using System;

public struct WorldInformation
{
	public String world_name;
 	public int32 world_seed;

	public this(String _name,int32 _seed) {
		world_name = _name;
		world_seed = _seed;
	}
}