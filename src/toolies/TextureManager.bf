namespace flowergarden;
using System;
using System.Collections;
using RaylibBeef;
using static RaylibBeef.Raylib;

static public class TextureManager
{
	static public Dictionary<String,Texture> textures;

	static public this() {
		textures = new Dictionary<String,Texture>();
	}

	static public Texture texture_load(String path) {
		if (!textures.ContainsKey(path)) {
			let pathstring = scope String();
			pathstring.Append(GetApplicationDirectory());
			pathstring.Append(path);
			textures.Add(path,LoadTexture(pathstring));
		}

		return textures.GetValue(path);
	}

	static public void clean() {
		delete textures;
	}
}