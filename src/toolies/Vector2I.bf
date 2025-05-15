using System;
using System.Interop;

namespace flowergarden;

[CRepr]
public struct Vector2I
{
	/// 
	public int x;
	
	/// 
	public int y;
	
	public this(int x, int y)
	{
		this.x = x;
		this.y = y;
	}
}
