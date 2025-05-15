namespace flowergarden;
using System;
using RaylibBeef;
using static RaylibBeef.Raylib;

static class StringBeans
{
	public static void draw_vector3(Vector3 vec, String buffer,int32 x,int32 y,int32 text_size = 16,Color color = RED) {
		vec.x.ToString(buffer);
		buffer.Append(", ");
		vec.y.ToString(buffer);
		buffer.Append(", ");
		vec.z.ToString(buffer);
		DrawText(buffer,x,y,text_size,color);
		buffer.Clear();
	}
}