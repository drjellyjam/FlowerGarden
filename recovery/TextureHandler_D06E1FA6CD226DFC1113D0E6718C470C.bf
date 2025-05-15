namespace flowergarden;
using System;
using System.Collections;
using RaylibBeef;
using static RaylibBeef.Raylib;

static class TextureManager
{
	public static Dictionary<String,Texture> texture_dict;

	public static this() {
		let path = scope String();
		path.Append(GetApplicationDirectory());
		path.Append("/data/textures/missing.png");
		texture_dict.Add("missing",LoadTexture(path));
	}

	public static Texture hi() {
		Console.WriteLine("hi");

		return TextureManager.texture_dict.GetValue("missing");
	}
	/*
	static public Dictionary<String,Texture2D> textures;
	static public Texture2D missing_texture;
	static public char8* working_directory;

	static public this() {
		textures = new Dictionary<String,Texture2D>();

		working_directory = GetApplicationDirectory();
		String endpath = scope .();
		endpath.Append(working_directory);
		endpath.Append("/data/textures/missing.png");
		missing_texture = LoadTexture(endpath);
	}

	static public void upload_texture(String path) {
		if (!textures.ContainsKey(path)) {
			String endpath = scope .();
			endpath.Append(working_directory);
			endpath.Append(path);
			textures.Add(path,LoadTexture(endpath));
		}
	}

	static public Texture2D get_texture(String path) {
		/*
		if (textures.ContainsKey(path)) {
			return textures.GetValue(path);
		}
		*/
		return missing_texture;
	}
	*/
}