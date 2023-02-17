package engine.modutil;

import flixel.math.FlxAngle;
import flixel.util.FlxTimer;
import util.ui.PreferencesMenu;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import haxe.io.Path;
import flixel.group.FlxGroup;
import engine.modding.SpunModLib.ModLib;
import engine.modding.SpunModLib.ModAssets;
import game.PlayState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import hscript.Interp;
import hscript.Parser;
import openfl.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Hscript
{
	public var interp = new Interp();
	public var parser = new Parser();
	public var script:hscript.Expr;

	public function new()
	{
		parser.allowTypes = true;
		parser.allowJSON = true;
		parser.allowMetadata = true;

		interp.variables.set("Int", Int);
		interp.variables.set("String", String);
		interp.variables.set("Float", Float);
		interp.variables.set("Array", Array);
		interp.variables.set("Bool", Bool);
		interp.variables.set("Dynamic", Dynamic);
		interp.variables.set("Math", Math);
		interp.variables.set("Main", Main);
		interp.variables.set("FlxMath", FlxMath);
		interp.variables.set("Std", Std);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("FlxText", FlxText);
		interp.variables.set("FlxTimer", FlxTimer);
		interp.variables.set("FlxAngle", FlxAngle);
		interp.variables.set("FlxGraphic", FlxGraphic);
		interp.variables.set("FlxEase", FlxEase);
		interp.variables.set("FlxTween", FlxTween);
		interp.variables.set("FlxCamera", FlxCamera);
		interp.variables.set("File", File);
		interp.variables.set("Assets", Assets);
		interp.variables.set("FileSystem", FileSystem);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("FlxGroup", FlxGroup);
		interp.variables.set("FlxTypedGroup", FlxTypedGroup);
		interp.variables.set("Paths", Paths);
		interp.variables.set("Path", Path);

		interp.variables.set("FlxAtlasFrames", FlxAtlasFrames);
		interp.variables.set("FlxAtlas", FlxAtlas);

		// FNF stuff
		interp.variables.set("Character", Character);
		interp.variables.set("Boyfriend", Boyfriend);
		interp.variables.set("PreferencesMenu", PreferencesMenu);

		// Charting Shit
		interp.variables.set("Song", Song);
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("Section", Section);

		// Modding System
		interp.variables.set("ModAssets", ModAssets);

		interp.variables.set("getModID", function(value:Dynamic)
		{
			return ModLib.curMod.id;
		});

		interp.allowStaticVariables = interp.allowPublicVariables = true;
	}

	public function call(funcName:String, ?args:Array<Dynamic>):Dynamic
	{
		if (args == null)
			args = [];

		try{
			var func:Dynamic = interp.variables.get(funcName);
			if (func != null && Reflect.isFunction(func))
				return Reflect.callMethod(null, func, args);
		}
		catch(e:Dynamic){
			trace('Hscript Error! $e');
		}

		return true;
	}

	/**
	 * Load App Script
	 * @param location Location of the Script (Root starts at 'data', you can't change this.)
	 * @param scriptName name of Script.
	 */
	public function loadScript(location:String, scriptName:String, ?modID:String = null)
	{
		try{
			script = parser.parseString(ModAssets.getAsset('$location/$scriptName.hx', null, modID));
			interp.execute(script);
		}
		catch(e:Dynamic){
			trace('Hscript Error! $e');
		}
	}
}
