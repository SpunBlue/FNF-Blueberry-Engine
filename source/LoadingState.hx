package;

import engine.OptionsData;
import engine.modding.Modding;
import lime.utils.AssetCache;
import game.PlayState;
import lime.app.Promise;
import lime.app.Future;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import haxe.io.Path;

class LoadingState extends MusicBeatState // yoinked this from sublime trol
{
	inline static var MIN_TIME = 1.0;
	
	var target:FlxState;
	var callbacks:MultiCallback;
	
	var funkay:FlxSprite;
	var scale:Float = 1;

	var modID:String;
	
	function new(target:FlxState, ?modID:String)
	{
		super();
		this.target = target;

		if (modID != null)
			this.modID = modID;
	}
	
	override function create()
	{
		funkay = new FlxSprite(0, 0).loadGraphic(Paths.image('funkay')); //gigachad funkay vs gfDance the weak
		funkay.antialiasing = true;
		funkay.scale.x = 1;
		funkay.scale.y = 1;
        funkay.screenCenter();
		funkay.updateHitbox();
		add(funkay);

		#if NO_PRELOAD_ALL
			initSongsManifest().onComplete
			(
				function (lib)
				{
					checkLoadSong(getSongPath());
					if (PlayState.SONG.needsVoices)
						checkLoadSong(getVocalPath());
					checkLibrary("shared");
					if (PlayState.storyWeek > 0)
						checkLibrary("week" + PlayState.storyWeek);
					else
						checkLibrary("tutorial");

					callbacks = new MultiCallback(onLoad);
					var introComplete = callbacks.add("introComplete");
					
					var fadeTime = 0.5;
					FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
					new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
				}
			);
		#end

		super.create();
		
		var timer:FlxTimer = new FlxTimer();
		timer.start(1.25, function(timer:FlxTimer):Void {
			if (modID != null && modID != '')
				Modding.preloadMod(modID);

			callbacks = new MultiCallback(onLoad);
			var introComplete = callbacks.add("introComplete");

			var fadeTime = 0.5;
			FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
			new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
		});
	}


	
	function checkLoadSong(path:String)
	{
		if (!Assets.cache.hasSound(path))
		{
			var library = Assets.getLibrary("songs");
			final symbolPath = path.split(":").pop();
			// @:privateAccess
			// library.types.set(symbolPath, SOUND);
			// @:privateAccess
			// library.pathGroups.set(symbolPath, [library.__cacheBreak(symbolPath)]);
			var callback = callbacks.add("song:" + path);
			Assets.loadSound(path).onComplete(function (_) { callback(); });
		}
	}
	
	function checkLibrary(library:String)
	{
		trace(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw "Missing library: " + library;
			
			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function (_) { callback(); });
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (scale != 1) {
			scale -= 0.01;
		}

		if (FlxG.keys.justPressed.SPACE) {
			scale = 1.1;
		}

		if (scale > 0.9) {
			funkay.scale.x = scale;
		    funkay.scale.y = scale;
		} else {
			scale = 1;
			funkay.scale.x = 1;
		    funkay.scale.y = 1;
		}
	}
	
	function onLoad()
	{
		FlxG.sound.music.stop();
		
		FlxG.switchState(target);
	}
	
	static function getSongPath()
	{
		return Paths.inst(PlayState.SONG.song);
	}
	
	static function getVocalPath()
	{
		return Paths.voices(PlayState.SONG.song);
	}
	
	inline static public function loadAndSwitchState(target:FlxState, modID:String)
	{
		Paths.setCurrentLevel("week" + PlayState.storyWeek);

		FlxG.switchState(new LoadingState(target, modID));
	}
	
	#if NO_PRELOAD_ALL
	static function isSoundLoaded(path:String):Bool
	{
		return Assets.cache.hasSound(path);
	}
	
	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}
	#end
	
	override function destroy()
	{
		super.destroy();
		
		callbacks = null;
	}
	
	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
			promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;
	
	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();
	
	public function new (callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}
	
	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function ()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;
				
				if (logId != null)
					log('fired $id, $numRemaining remaining');
				
				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}
	
	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}
	
	public function getFired() return fired.copy();
	public function getUnfired() return [for (id in unfired.keys()) id];
}
