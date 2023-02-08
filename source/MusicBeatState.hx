package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import engine.Engine;
import sys.FileSystem;
import lime.utils.Assets;
import engine.modding.Hscript;
import engine.modding.Modding;

class MusicBeatState extends FlxUIState
{
	public var scripts = new Hscript();

	public var scriptsAllowed:Bool = true;

	public var scriptName:String = null;

	public function new(scriptsAllowed:Bool = true, ?scriptName:String)
	{
		this.scriptsAllowed = #if SOFTCODED_STATES scriptsAllowed #else false #end;
		this.scriptName = scriptName;

		var className = Type.getClassName(Type.getClass(this));
		var scriptName = this.scriptName != null ? this.scriptName : className.substr(className.lastIndexOf(".")+1);

		if (FileSystem.exists(Modding.getFilePath(scriptName + '.hx', "scripts/states/"))){
		    scripts.loadScript("states/" + scriptName, true);
		}

		if (Assets.exists(Paths.hx("scripts/states/" + scriptName))){
		    scripts.loadScript("scripts/states/" + scriptName, false);
		}

		scripts.call('create');

		super();

		scripts.call('createPost');
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	private var allowCamBeat:Bool = false;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		if (transIn != null)
			Engine.debugPrint('reg ' + transIn.region);

		FlxSprite.defaultAntialiasing = true;

		scripts.call('create');

		super.create();

		scripts.call('createPost');
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		if (allowCamBeat)
			camera.zoom = FlxMath.lerp(camera.zoom, camera.initialZoom, 0.1);

		scripts.call("update", [elapsed]);

		super.update(elapsed);

		script.call("updatePost", [elapsed]);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();

		scripts.call("stepHit");
	}

	public function beatHit():Void
	{
		if (allowCamBeat){
			camera.zoom += 0.01;

			if (curBeat % 4 == 0)
			{
				camera.zoom += 0.05;
			}
		}
		scripts.call("beatHit");
	}
}
