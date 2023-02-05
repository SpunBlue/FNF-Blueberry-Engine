package;

import sys.FileSystem;
import lime.utils.Assets;
import engine.modding.Hscript;
import Conductor.BPMChangeEvent;
import engine.modding.Modding;
import flixel.FlxG;
import flixel.FlxSubState;
import engine.Engine;

class MusicBeatSubstate extends FlxSubState
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

		if (FileSystem.exists(Modding.getFilePath(scriptName + '.hx', "scripts/substates/"))){
		    scripts.loadScript("substates/" + scriptName, true);
		}

		if (Assets.exists(Paths.hx("scripts/substates/" + scriptName))){
		    scripts.loadScript("scripts/substates/" + scriptName, false);
		}

		scripts.call('create');

		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();

		scripts.call("update", [elapsed]);

		super.update(elapsed);
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
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
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
		//do literally nothing dumbass
		scripts.call("beatHit");
	}
}
