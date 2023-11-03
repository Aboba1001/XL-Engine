package openfl.display;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
import flixel.FlxG;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

#if openfl
import openfl.system.System;
#end

import ClientPrefs;
import CoolUtil;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;
        public var totalFPS(default, null):Int;

	public var currentMem:Float;
	public var maxMem:Float;
	
	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 15, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		totalFPS = Math.round(currentFPS + currentCount / 8);
		if (currentFPS > ClientPrefs.framerate) currentFPS = ClientPrefs.framerate;
                if (totalFPS < 10)
			totalFPS = 0;
		
		if (currentCount != cacheCount /*&& visible*/)
		{
			text = "FPS: " + currentFPS;
			var memoryMegas:Float = 0;
			
	              currentMem = memoryMegas;
			if (currentMem >= maxMem)
				maxMem = currentMem;
			
			#if openfl
			memoryMegas = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));
		      if(ClientPrefs.showTotalFPS) {
			text += "\nTotal FPS: " + totalFPS;
		      }
		      if(ClientPrefs.showMemory) {
			text += "\nMEM: " + currentMem + " MB";
		      }
		      if(ClientPrefs.showTotalMemory) {
			text += "\nMEM Peak: " + maxMem + " MB";
		      }
		      if(ClientPrefs.showVersion) {
			text += "\nEngine Version: " + MainMenuState.abobaEngineVersion;
		      }
		      if(ClientPrefs.debugInfo) {
			text += '\nState: ${Type.getClassName(Type.getClass(FlxG.state))}';
			if (FlxG.state.subState != null)
	                        text += '\nSubstate: ${Type.getClassName(Type.getClass(FlxG.state.subState))}';
			//text += Math.floor(1 / currentFPS * 10000 + 0.5) / 10 + "ms";
			text += "\nOperating System: " + '${lime.system.System.platformLabel} ${lime.system.System.platformVersion}';
		      }
			#end

			textColor = 0xFFFFFFFF;
			if (memoryMegas > 3000 || currentFPS <= ClientPrefs.framerate / 2)
			{
				textColor = 0xFFFF0000;
			}

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end

			text += "\n";
		}

		cacheCount = currentCount;
	}
}
