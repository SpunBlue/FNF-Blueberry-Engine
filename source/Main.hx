package;

import lime.system.System;
import flixel.system.FlxVersion;
import haxe.display.Protocol.Version;
import sys.thread.Thread;
import openfl.events.UncaughtErrorEvent;
import openfl.events.EventType;
import util.ui.PreferencesMenu;
import lime.app.Application;
import sys.io.File;
import sys.FileSystem;
import haxe.PosInfos;
import haxe.Log;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.AsyncErrorEvent;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.NetStatusEvent;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import game.TitleState;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	#if web
	var framerate:Int = 60; // How many frames per second the game should run at.
	#else
	var framerate:Int = 128; // How many frames per second the game should run at.

	#end
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (!FileSystem.isDirectory('logs/'))
			FileSystem.createDirectory('logs');

		var logName:String = (Date.now().getMonth() + 1) + '-' + Date.now().getDate() + '-' + Date.now().getFullYear() + ' ' + 
			cnvrtBetterTime(Date.now().getHours(), Date.now().getMinutes());

		// this variable scares me.
		var content:String = '${Sys.systemName()} ${System.platformVersion} - Blueberry Engine v${Application.current.meta.get('version')} - Friday Night Funkin\' v0.2.8\n';

		Log.trace = function(v:Dynamic, ?infos:PosInfos){
			try{
				if (PreferencesMenu.getPref('debugfilelog')){
					content += '\n(Line:${infos.lineNumber} Class:${infos.className} Method:${infos.methodName})::$v';

					// Creates a thread, threads basically run tasks in the background and doesn't wait for completion. Helps with performance, shouldn't do this with everything though.
					#if (!html5 && target.threaded)
					Thread.create(() -> {
						File.saveContent('logs/$logName.txt', content);
					});
					#else
					File.saveContent('logs/$logName.txt', content); // do it anyways lol
					#end
				}
	
				#if (sys && desktop)
				if (PreferencesMenu.getPref('debuglog')){
					#if (target.threaded)
					Thread.create(() -> {
						Sys.println('(Line: ${infos.lineNumber} Class: "${infos.className}" Method: "${infos.methodName}")::$v');
					});
					#else
					Sys.println('(Line: ${infos.lineNumber} Class: "${infos.className}" Method: "${infos.methodName}")::$v');
					#end
				}
				#end
			}
			catch(e:Dynamic){
				#if (sys && desktop)
				try{
					Sys.println('Debugging Error! $e');
				}
				#end
			}
		}

		Application.current.window.title = 'Friday Night Funkin\' Blueberry Engine v${Application.current.meta.get('version')}';

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	function cnvrtBetterTime(hour:Int, minute:Int, ?spacer:String = '.'):String {
		var min:String;

		if (Std.string(minute).length == 1)
			min = '0$minute';
		else
			min = '$minute';

		var convertedHour:Int = hour % 12;
		if (convertedHour == 0) {
			convertedHour = 12;
		}
		var result:String = '$convertedHour$spacer$min';
		if (hour >= 12) {
			result += 'PM';
		} else {
			result += 'AM';
		}
		return result;
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	var video:Video;
	var netStream:NetStream;
	private var overlay:Sprite;

	public static var fpsCounter:FPS;

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));

		#if !mobile
		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		#end
	}

	// Copied from a personal project
	/**
	 * Create a thread to run a specific task, allows running the same task even if creating threads is not possible.
	 * @param task Function
	 * @param allowNonThread Allow `task` to run even if threading isn't possible, defaults to `true`.
	 */
	public static function createThread(task:Void->Void, allowNonThread:Bool = true)
	{
		try
		{
			#if (target.threaded)
			sys.thread.Thread.create(() ->
			{
				task();
			});
			#else
			if (allowNonThread)
				task(); // do it anyways LOL
			#end
		}
		catch (e:Dynamic)
		{
			trace('ERROR DURRING THREAD PROCESS, $e');
		}
	}
}
