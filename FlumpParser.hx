package com.michaelgreenhut.openflump ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import haxe.xml.Fast;
import openfl.Assets;

/**
 * ...
 * @author Michael Greenhut
 * Flump was created at Three Rings by Charlie Groves, Tim Conkling, and Bruno Garcia. 
 * This Flump parser for openFL was created by Michael Greenhut.
 * For directions on how to use Flump, visit:
 * http://threerings.github.io/flump/
	 * Note that this parser makes use of XML only (at the moment), so be sure to export your Flump files 
	 * using the XML option. 
 * 
 * 
 */
class FlumpParser
{
	private var _fast:Fast;
	private var _atlas:Bitmap;
	private var _fm:FlumpMovie;
	private var _movies:Array<FlumpMovie>;
	private var _loadedPaths:Array<String>;
	private static var _flumpParser:FlumpParser;
	
	public function new(fpkey:FPKey) 
	{
		_loadedPaths = new Array<String>();
		_movies = new Array<FlumpMovie>();
	}
	
	public function loadPath(resourcePath:String):Void 
	{
		if (Lambda.indexOf(_loadedPaths, resourcePath) != -1)
		{
			//trace("Already loaded this set.");
			return;
		}
		var text:String = Assets.getText(resourcePath);
		_fast = new Fast(Xml.parse(text));	
		_loadedPaths.push(resourcePath);
		makeTextures();
		makeMovies();
	}
	
	public static function get():FlumpParser
	{
		if (_flumpParser == null)
			_flumpParser = new FlumpParser(new FPKey());
			
		return _flumpParser;
	}
	
	public function textToPoint(text:String):Point 
	{
		var pointArray:Array<String> = text.split(",");
		return new Point(Std.parseFloat(pointArray[0]), Std.parseFloat(pointArray[1]));
	}
	
	public function textToRect(text:String):Rectangle
	{
		var rectArray:Array<String> = text.split(",");
		return new Rectangle(Std.parseFloat(rectArray[0]), Std.parseFloat(rectArray[1]), Std.parseFloat(rectArray[2]), Std.parseFloat(rectArray[3]));
	}
	
	private function makeTextures():Void 
	{
		for (textureGroups in _fast.node.resources.nodes.textureGroups)
		{
			for (textureGroup in textureGroups.nodes.textureGroup)
			{
				for (atlas in textureGroup.nodes.atlas)
				{
					var bd:BitmapData = Assets.getBitmapData("assets/"+atlas.att.file);
					var bm:Bitmap = new Bitmap(bd);
					for (texture in atlas.nodes.texture)
					{
						var rectArray:Array<String> = texture.att.rect.split(",");
						var pointArray:Array<String> = texture.att.origin.split(",");
						var rect:Rectangle = textToRect(texture.att.rect);
						var origin:Point = textToPoint(texture.att.origin);
						FlumpTextures.get().makeTexture(bm, rect, texture.att.name,origin);
					}
				}
			}
		}
	}
	
	private function makeMovies():Void 
	{
		
		for (movie in _fast.node.resources.nodes.movie)
		{
			var fm:FlumpMovie = new FlumpMovie();
			fm.name = movie.att.name;
			for (layer in movie.nodes.layer)
			{
				var movieLayer:Layer = new Layer();
				movieLayer.name = layer.att.name;
				for (keyframe in layer.nodes.kf)
				{
					//var kf:Keyframe = new Keyframe(Std.int(keyframe.node.duration));
					var ref:String = "";
					var loc:Null<Point> = null;
					var scale:Null<Point> = null;
					var pivot:Null<Point> = new Point(0,0);
					var tweened:Bool = false;
					var ease:Null<Float> = null;
					var skew:Null<Point> = new Point(0,0);
					var alpha:Float = 1;
					if (keyframe.has.ref)
					{
						ref = keyframe.att.ref;
					}
					//fix by gigbig@libero.it
					loc = keyframe.has.loc ? textToPoint(keyframe.att.loc) : new Point(0, 0);
					
					if (keyframe.has.tweened)
					{
						tweened = keyframe.att.tweened == "false" ? false : true;
					}
					else
						tweened = true;
					if (keyframe.has.scale)
					{
						scale = textToPoint(keyframe.att.scale);
					}
					if (keyframe.has.pivot)
					{
						pivot = textToPoint(keyframe.att.pivot);
					}
					if (keyframe.has.skew)
					{
						skew = textToPoint(keyframe.att.skew);
					}
					if (keyframe.has.ease)
					{
						tweened = true;
						ease = Std.parseFloat(keyframe.att.ease);
					}
					if (keyframe.has.alpha)
					{
						alpha = Std.parseFloat(keyframe.att.alpha);
					}
					var kf:Keyframe = new Keyframe(Std.parseInt(keyframe.att.duration), ref, loc, scale, pivot, tweened, ease, alpha, skew);
					movieLayer.addKeyframe(kf);
					//trace("movie ", movieLayer.name);
				}
				fm.addLayer(movieLayer);
			}
			fm.process();
			_movies.push(fm);
		}
		trace("made movies", _movies);
	}
	
	public function getMovieByName(name:String):FlumpMovie
	{
		for (i in 0..._movies.length)
		{
			if (_movies[i].name == name)
			{
				var movieToReturn:FlumpMovie = _movies[i];
				//_movies.splice(i, 1);
				//trace("returning movie ", name, movieToReturn);
				return movieToReturn;
			}
		}
		
		return null;
	}
	
}

class FPKey
{
	public function new() 
	{
		
	}
}
