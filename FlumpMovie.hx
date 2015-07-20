package com.michaelgreenhut.openflump ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Transform;
import flash.Lib;
import openfl.display.DisplayObjectContainer;

/**
 * ...
 * @author Michael Greenhut
 */
class FlumpMovie extends Sprite
{
	
	private var _layers:Array<Layer>;
	private var _callback:Void->Void;
	private var _internalX:Float;
	private var _internalY:Float;

	public function new() 
	{
		super();
		_layers = new Array<Layer>();
	}
	
	
	public function clone():FlumpMovie
	{
		var fm:FlumpMovie = new FlumpMovie();
		for (i in 0..._layers.length)
		{
			fm.addLayer(_layers[i].clone());
		}
		
		return fm;
	}
	
	public override function toString():String 
	{
		var returnString:String = "[";
		for (i in 0..._layers.length)
		{
			if (_layers[i].getImage() == null)
				returnString += "null";
			else
			{
				for (j in 0..._layers[i].getLength())
					returnString += ("image: " + _layers[i].hasImageNamed());
			}
		}
		returnString += "]";
		
		return returnString;
	}
	
	public function addLayer(layer:Layer):Void
	{
		_layers.push(layer);
		if (layer.hasImageNamed() != null)
		{
			var textureSprite:Sprite = FlumpTextures.get().getTextureByName(layer.hasImageNamed());
			//trace("layer name", layer.hasImageNamed(), textureSprite);
			if (textureSprite == null)
			{
				var mv:FlumpMovie = FlumpParser.get().getMovieByName(layer.hasImageNamed());
				layer.setMovie(mv);
			}
			else 
			{
				var originalbm:Bitmap = cast(textureSprite.getChildAt(0), Bitmap);
				layer.setImage(originalbm.bitmapData.clone());
			}
		}
	}
	
	public function process():Void 
	{
		trace("num layers", _layers.length, this.name);
		for (i in 0..._layers.length)
		{
			_layers[i].process();
			checkForImage(_layers[i]);
		}
	}
	
	public function getLayer(name:String):Layer
	{
		for (i in 0..._layers.length)
		{
			if (_layers[i].name == name)
				return _layers[i];
		}
		
		return null;
	}

	public function internalX():Float
	{
		return _internalX;
	}

	public function internalY():Float 
	{
		return _internalY;
	}
	
	public function checkForImage(layer:Layer):Void 
	{
		if (layer.getImage() != null)
		{
			var image:DisplayObjectContainer = layer.getImage();
			if (layer.isShown())
			{
				addChild(image);
			}
			else 
			{
				if (contains(image))
				{
					removeChild(image);
				}
			}
			_internalX = image.x;
			_internalY = image.y;
			
		}
		
		trace("internal Y", _internalY, this.name);
	}
	
	public function play(callb:Void->Void = null):Void
	{
		_callback = callb;
		process();
		if (!hasEventListener(Event.ENTER_FRAME))
			addEventListener(Event.ENTER_FRAME, playInternal);
	}
	
	public function rewind(callb:Void->Void = null):Void 
	{
		_callback = callb;
		process();
		if (!hasEventListener(Event.ENTER_FRAME))
			addEventListener(Event.ENTER_FRAME, rewindInternal);
	}
	
	private function playInternal(e:Event):Void
	{
		//trace("playing" + name);
		if (!nextFrame())
		{
			removeEventListener(Event.ENTER_FRAME, playInternal);
			if (_callback != null)
				_callback();
		}
	}
	
	private function rewindInternal(e:Event):Void
	{
		
		if (!prevFrame())
		{
			removeEventListener(Event.ENTER_FRAME, rewindInternal);
			if (_callback != null)
				_callback();
		}
	}
	
	public function nextFrame():Bool
	{
		var more:Bool = false;
		for (i in 0..._layers.length)
		{
			more = _layers[i].advance();
			_layers[i].process();
			checkForImage(_layers[i]);
		}
		
		return more;
	}
	
	public function prevFrame():Bool 
	{
		var more:Bool = false;
		for (i in 0..._layers.length)
		{
			more = _layers[i].back();
			_layers[i].process();
			checkForImage(_layers[i]);
		}
		
		return more;
	}
	
	public function gotoEnd():Void 
	{
		for (i in 0..._layers.length)
		{
			_layers[i].goto(_layers[i].getLength());
			_layers[i].process();
		}
	}
	
	
	//needs work
	public function gotoStart():Void 
	{
		for (i in 0..._layers.length)
		{
			_layers[i].goto(0);
			_layers[i].process();
		}
	}
	
}