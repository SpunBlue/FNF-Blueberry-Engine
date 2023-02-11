package engine.modding;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import lime.utils.Assets;
import hscript.Parser;
import hscript.Interp;
import sys.io.File;
import sys.FileSystem;
import game.PlayState;
import engine.modding.Modding;
import engine.modding.Stages.StageObject;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Hscript
{
	public var interp = new Interp();
	public var parser = new Parser();
	public var script:hscript.Expr;

	public function new(){
		parser.allowTypes = true;
		parser.allowJSON = true;
		parser.allowMetadata = true;

		interp.variables.set("Int",Int);
		interp.variables.set("String",String);
		interp.variables.set("Float",Float);
		interp.variables.set("Array",Array);
		interp.variables.set("Bool",Bool);
		interp.variables.set("Dynamic",Dynamic);
		interp.variables.set("Math",Math);
		interp.variables.set("Main",Main);
		interp.variables.set("Std",Std);

		interp.variables.set("FlxG",FlxG);
		interp.variables.set("FlxText",FlxText);
		interp.variables.set("FlxMath",FlxMath);
		interp.variables.set("FlxEase",FlxEase);
		interp.variables.set("FlxTween",FlxTween);
		interp.variables.set("FlxCamera",FlxCamera);
		interp.variables.set("FlxSound",FlxSound);
		interp.variables.set("FlxSprite",FlxSprite);
		interp.variables.set("FlxAtlasFrames", FlxAtlasFrames);

        interp.variables.set("File",File);
		interp.variables.set("Paths",Paths);
        interp.variables.set("Assets",Assets);
        interp.variables.set("Modding",Modding);
		interp.variables.set("CoolUtil",CoolUtil);
		interp.variables.set("Conductor",Conductor);
		interp.variables.set("PlayState",PlayState);
        interp.variables.set("FileSystem",FileSystem);
		interp.variables.set("StageObject", StageObject);
		interp.variables.set("StringTools",StringTools);

        interp.allowStaticVariables = interp.allowPublicVariables = true;
	}

	public function call(funcName:String, ?args:Array<Dynamic>):Dynamic{
		if (args == null)
			args = [];

		try{
			var func:Dynamic = interp.variables.get(funcName);
			if (func != null && Reflect.isFunction(func))
				return Reflect.callMethod(null, func, args);
		}
		catch (e){
			FlxG.log.add(e.details());
		}

		return true;
	}

	public function loadScript(key:String, isMod:Bool = true){
		if (isMod == true)
		    script = parser.parseString(Modding.retrieveContent(key + '.hx', 'scripts'));
	    else
			script = parser.parseString(Assets.getText(Paths.hx(key)));
		interp.execute(script);
	}

	public function loadScriptStage(key:String, isMod:Bool = true){
		if (isMod == true)
		    script = parser.parseString(Modding.retrieveContent(key + '.hx', 'data/stages'));
	    else
			script = parser.parseString(Assets.getText(Paths.hx(key)));
		interp.execute(script);
	}
}
