package com.michaelgreenhut.openflump ;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.display.DisplayObjectContainer;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Transform;
import flash.Lib;

/**
 * ...
 * @author Michael Greenhut
 */
class Layer
{

	private var _index:Int = 0;
	private var _keyframes:Array<Keyframe>;
	private var _currentTexture:String;
	private var _previousTexture:String;
	private var _currentLocation:Point;
	private var _currentScale:Point;
	private var _currentPivot:Point;
	private var _currentSkew:Point;
	private var _currentAlpha:Float = 1;
	private var _image:DisplayObjectContainer;
	private var _length:Int = 0;
	
	public var name:String;
	public var visible:Bool = true;
	private var _containsImage:String;
	private var _destinationIndex:Int;
	private var _preTweenIndex:Int = 0;
	private var _originalMatrix:Matrix;
	public function new() 
	{
		_keyframes = new Array<Keyframe>();
		_preTweenIndex = _index;
		_image = new Sprite();
	}
	
	public function addKeyframe(kf:Keyframe):Void
	{
		_keyframes.push(kf);
		_length += kf.getDuration();
		if (kf.getRef() != null)
			_containsImage = kf.getRef();
	}
	
	public function back():Bool 
	{    
		if (_index >= 0)
		{
			if (!_keyframes[_index].back())
			{
				if (_index > 0)
				{
					_index--;
					return true;
				}
				else
					return false;
			}
			
			return true;
		}
		
		return false;
	}
	
	public function advance():Bool
	{
		
		if (_index < _keyframes.length)
		{
			if (!_keyframes[_index].advance())
			{
				if (_index < _keyframes.length - 1)
				{
					_index++;
					{
						return true;  //if the current keyframe is at the end, and there are more to go
					}
				}
				else 
				{
					return false;  //if the current keyframe is at the end, and there are no more to go.
				}
			}
			return true;  //if the current keyframe isn't at the end, and there are more to go

		}
		return false;
	}
	
	public function process():Void 
	{
		if (_index < 0 || _index >= _keyframes.length)
			return;
		if (_keyframes[_index].getLocation() != null)
		{
			populateCurrentValues(_index);
			
			var textureSprite:Sprite = FlumpTextures.get().getTextureByName(_currentTexture);
			
			if (textureSprite != null)
			{
				var originalbm:Bitmap = cast(textureSprite.getChildAt(0), Bitmap);
				setImage(originalbm.bitmapData.clone());
			}
			else 
			{
				 //it must be a flump movie  or flipbook, and we don't need to call setImage at all.
                if (_image != FlumpParser.get().getMovieByName(_currentTexture))
                    _image = FlumpParser.get().getMovieByName(_currentTexture);

                if (!cast(_image, FlumpMovie).nextFrame())
                    cast(_image, FlumpMovie).gotoStart();  //this loops the internal flipbook
			}
			
			if (_image != null)
			{
				if (_keyframes[_index].getTweened()) //Stop-gap code to handle tweens
				{  
				
					_destinationIndex = _index + 1;
					_preTweenIndex = _index;
					var nextLoc:Point = _keyframes[_destinationIndex].getLocation().clone();  
					var nextScale:Point = _keyframes[_destinationIndex].getScale().clone();
					var nextPivot:Point = _keyframes[_destinationIndex].getPivot().clone();
					var nextAlpha:Float = _keyframes[_destinationIndex].getAlpha();
					var nextSkew:Point = _keyframes[_destinationIndex].getSkew().clone();
					_keyframes[_index].internalIndex();
					var multiplier:Float = _keyframes[_preTweenIndex].internalIndex() /_keyframes[_preTweenIndex].getDuration();
				
					_currentAlpha = _keyframes[_preTweenIndex].getAlpha() + (nextAlpha - _keyframes[_preTweenIndex].getAlpha()) * multiplier;
					_currentScale.x = _keyframes[_preTweenIndex].getScale().x + (nextScale.x - _keyframes[_preTweenIndex].getScale().x) * multiplier;
					_currentScale.y = _keyframes[_preTweenIndex].getScale().y + (nextScale.y - _keyframes[_preTweenIndex].getScale().y) * multiplier;
					_currentLocation.x = _keyframes[_index].getLocation().x + (nextLoc.x - _keyframes[_preTweenIndex].getLocation().x) * multiplier;
				
					_currentLocation.y = _keyframes[_index].getLocation().y + (nextLoc.y - _keyframes[_preTweenIndex].getLocation().y) * multiplier;
					
					_currentPivot.x = _keyframes[_index].getPivot().x + (nextPivot.x - _keyframes[_preTweenIndex].getPivot().x) * multiplier;
					_currentPivot.y = _keyframes[_index].getPivot().y + (nextPivot.y - _keyframes[_preTweenIndex].getPivot().y) * multiplier;
					_currentPivot.x *= _currentScale.x;
					_currentPivot.y *= _currentScale.y;
					_currentSkew.x = _keyframes[_index].getSkew().x + (nextSkew.x - _keyframes[_preTweenIndex].getSkew().x) * multiplier;
					_currentSkew.y = _keyframes[_index].getSkew().y + (nextSkew.y - _keyframes[_preTweenIndex].getSkew().y) * multiplier;
				
				}
				_image.scaleX = _currentScale.x;
				_image.scaleY = _currentScale.y;
				
				_image.x = _currentLocation.x;
				_image.y = _currentLocation.y;
				if (_image.numChildren > 0)
				{
					_image.getChildAt(0).x = -_currentPivot.x;
					_image.getChildAt(0).y = -_currentPivot.y;
				}
				
				//if (_currentSkew.x != 0 || _currentSkew.y != 0)
				{
					_image.rotation = _currentSkew.x * 180 / Math.PI;
				}
				
				_image.visible = visible;
				_image.alpha = _currentAlpha;
				
			}
			//else 
			//	trace("NON TWEEN", this.name, "keyframe ", _index);
		}
		else // _keyframes[_index].getLocation() is never == null, so this "else" will never be executed
		{
			if (_image != null && _image != {})
				_image.visible = false; 
			_currentLocation = null;
			_currentTexture = null;
			_currentScale = null;
			_currentPivot = null;
		}
	}
	
	private function populateCurrentValues(index:Int):Void 
	{
		_previousTexture = _currentTexture;
		_currentTexture = _keyframes[index].getRef();
		
		_currentScale = _keyframes[index].getScale().clone();
		_currentLocation = _keyframes[index].getLocation().clone();
		_currentPivot = _keyframes[index].getPivot().clone();
		_currentPivot.x *= _currentScale.x;
		_currentPivot.y *= _currentScale.y;
		_currentAlpha = _keyframes[index].getAlpha();
		_currentSkew = _keyframes[index].getSkew().clone();
	}
	
	public function isShown():Bool
	{
		return _image.visible;
	}
	
	public function setImage(bd:BitmapData):Void 
	{
		/*var bm:Bitmap = new Bitmap(bd);
		_image = new Sprite();
		_image.addChild(bm);
		_originalMatrix = _image.transform.matrix.clone();*/
		
		if (_currentTexture != _previousTexture) {
			var bm:Bitmap = new Bitmap(bd);
			if (_image.numChildren > 0 && _image.getChildAt(0) != null) (_image.removeChildAt(0));
			_image.addChild(bm);
			_originalMatrix = _image.transform.matrix.clone();
		}
	}
	
	public function setMovie(mv:FlumpMovie)
	{
		_image = mv;
	}
	
	public function getImage():DisplayObjectContainer
	{
		return _image;
	}
	
	public function getMovie():FlumpMovie
	{
		var mv:FlumpMovie = cast(_image, FlumpMovie);
		
		return mv;
	}
	
	public function hasImageNamed():String
	{
		return _containsImage;
	}
	
	public function reset():Void 
	{
		goto(0);
	}
	
	/*
	 *  Goes to absolute frame value. 
	 * 
	 */
	public function goto(internalIndex:Int):Void 
	{
		_index = 0;	
	
		//var count:Int = 0;
		for (i in 0..._keyframes.length)
		{	
			_keyframes[i].reset();
		}
		
		while(_index < _keyframes.length )
		{
			if (_index/*count*/ == internalIndex)
			{
				break;
			}
			if (!_keyframes[_index].advance())
			{
				_index++;	
			}	
			//count++;
			
		}
	}
	
	public function getFrame():Int 
	{
		return _index;
	}
	
	public function getLength():Int 
	{
		return _length;
	}
	
}