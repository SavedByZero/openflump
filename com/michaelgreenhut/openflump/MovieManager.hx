package com.michaelgreenhut.openflump;

/**
 * ...
 * @author Michael Greenhut
 */
class MovieManager
{

	private var _motionFunctions:Array<Void->Bool> ;
	private static var _movieManager:MovieManager;
	
	public function new(mmkey:MMKey) 
	{
		_motionFunctions = new Array<Void->Bool>();
	}
	
	public static function get():MovieManager
	{
		if (_movieManager == null)
			_movieManager = new MovieManager(new MMKey());
			
		return _movieManager;
	}
	
	/*
	 * These are for collections of two SPECIFIC functions only, nextFrame or prevFrame.  The idea is that by using the 
	 * MovieManager and the animateMovies function, you only have to rely on a single enterFrame loop to process multiple movies. 
	 * This allows you to pause/resume them all very easily and in sync, and it saves you from ODing on enterFrame functions.
	 * 
	 * */
	public function addAnimationFunction(animationFunc:Void->Bool):Void 
	{
		Type.getClass(animationFunc);
		_motionFunctions.push(animationFunc);
	}
	
	/*
	 * Put a call to this in a single enterFrame function.  Stop the enterFrame function when you want to pause all the 
	 * movies involved.
	 * 
	 * */
	public function animateMovies():Void 
	{
		if (_motionFunctions.length == 0)
			return;
		trace("num", _motionFunctions.length);
		var numFuncs:Int = -1 * (_motionFunctions.length-1);
		
		for (i in numFuncs...1)
		{
			trace("eye", i);
			var fn:Void->Bool = _motionFunctions[ -i];
			trace(Reflect.isFunction(fn));
			var moved:Bool = fn();//Reflect.callMethod(FlumpMovie, _motionFunctions[ -i], []);
			if (!moved)   //if this movie cannot animate any further in its given direction, remove it.
			{
				_motionFunctions.splice( -i, 1);
			}
		}
	}
	
}

class MMKey
{
	public function new()
	{
		
	}
}