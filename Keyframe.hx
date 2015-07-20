package com.michaelgreenhut.openflump ;
import flash.geom.Point;

/**
 * ...
 * @author Michael Greenhut
 * TODO: put loc and scale for standard, untransformed instances.
 */
class Keyframe
{

	private var _duration:Int;
	private var _index:Int = 0;
	private var _ref:String;
	private var _location:Point;
	private var _scale:Point;
	private var _pivot:Point;
	private var _tweened:Bool;
	private var _ease:Float;
	private var _alpha:Float;
	private var _skew:Point;
	
	public function new(duration:Int, ref:String = null, location:Point = null, scale:Point = null, pivot:Point = null, tweened:Bool = false, ease:Float = 0, alpha:Float = 1, skew:Point = null ) 
	{
		_duration = duration;
		_location = location;
		_ref = ref;
		if (scale == null)
			scale = new Point(1, 1);
		_scale = scale;
		_pivot = pivot;
		_tweened = tweened;
		_ease = ease;
		_alpha = alpha;
		if (skew == null)
			_skew = new Point(0, 0);
		else
			_skew = skew;
	}
	
	public function clone():Keyframe
	{
		return new Keyframe(_duration,_ref,_location,_scale,_pivot,_tweened,_ease,_alpha,_skew);
	}
	
	public function back():Bool 
	{
		if (_index > 0)
			_index--;
		
		return (_index > 0);
	}
	
	public function advance():Bool
	{
		if (_index < _duration)
			_index++;
		
		return (_index < _duration);
	}
	
	public function reset():Void
	{
		_index = 0;
	}
	
	public function internalIndex():Int 
	{
		return _index;
	}
	
	public function getRef():String
	{
		return _ref;
	}
	
	public function getDuration():Int 
	{
		return _duration;
	}
	
	public function getLocation():Point 
	{
		return _location;
	}
	
	public function getSkew():Point
	{
		return _skew;
	}
	
	public function getScale():Point 
	{
		return _scale;
	}
	
	public function getPivot():Point
	{
		return _pivot;
	}
	
	public function getTweened():Bool
	{
		return _tweened;
	}
	
	public function getEase():Float
	{
		return _ease;
	}
	
	public function getAlpha():Float
	{
		return _alpha;
	}
	
}