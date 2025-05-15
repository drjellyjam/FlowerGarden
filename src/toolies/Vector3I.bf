using System;
using System.Interop;

namespace flowergarden;

[CRepr]
public struct Vector3I
{
	/// 
	public int x;
	
	/// 
	public int y;
	
	/// 
	public int z;
	
	public this(int x, int y, int z)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
}
