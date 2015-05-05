package com.michaelgreenhut.openflump ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * ...
 * @author Michael Greenhut
 */
class FlumpTextures
{
	
	private var _textures:Map<String,Sprite>;
	private static var _flumpTextures:FlumpTextures;

	public function new(ft:FlumpTexturesKey) 
	{
		_textures = new Map<String,Sprite>(); 
	}
	
	public function makeTexture(sourcebm:Bitmap, rect:Rectangle, name:String, origin:Point):Void
	{
	//trace("old name", name);
		//name = StringTools.replace(name, "_flipbook_", "");
		//trace("new name", name);
		var newbd:BitmapData = new BitmapData(Std.int(rect.width), Std.int(rect.height), true, 0xffffffff);
		newbd.copyPixels(sourcebm.bitmapData, rect, new Point(0, 0));
		var newbm:Bitmap = new Bitmap(newbd);
		newbm.name = name;
		newbm.x = -origin.x;
		newbm.y = -origin.y;
		var textureSprite:Sprite = new Sprite();
		textureSprite.addChild(newbm);
		textureSprite.name = name;
		_textures.set(name, textureSprite);
		textureSprite.visible = false;
	}
	
	public static function get():FlumpTextures
	{
		if (_flumpTextures == null)
			_flumpTextures = new FlumpTextures(new FlumpTexturesKey());
			
		return _flumpTextures;
	}
	
	public function getTextureByName(name:String):Sprite
	{
		return _textures.get(name);
	}
	
	public function cloneTextureByName(name:String):Sprite
	{
		var texture:Sprite = _textures.get(name);
		var bd:BitmapData = new BitmapData(Std.int(texture.width), Std.int(texture.height),true,0xffffff);
		bd.draw(texture.getChildAt(0));
		var bm:Bitmap = new Bitmap(bd);
		var clone:Sprite = new Sprite();
		clone.addChild(bm);
		return clone;
	}
	
}

class FlumpTexturesKey
{
	public function new()
	{
		
	}
}
