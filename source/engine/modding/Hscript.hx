package engine.modding;

import flixel.FlxCamera;
import engine.modding.Stages.StageObject;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import lime.utils.Assets;
import hscript.Parser;
import hscript.Interp;
import sys.io.File;
import sys.FileSystem;
import game.PlayState;
import engine.modding.Modding;

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
		interp.variables.set("FlxMath",FlxMath);
		interp.variables.set("Std",Std);
		interp.variables.set("StringTools",StringTools);
		interp.variables.set("FlxG",FlxG);
		interp.variables.set("FlxSound",FlxSound);
		interp.variables.set("FlxSprite",FlxSprite);
		interp.variables.set("FlxText",FlxText);
		interp.variables.set("FlxTween",FlxTween);
		interp.variables.set("FlxCamera",FlxCamera);
        interp.variables.set("File",File);
		interp.variables.set("Paths",Paths);
		interp.variables.set("CoolUtil",CoolUtil);
        interp.variables.set("Assets",Assets);
        interp.variables.set("Modding",Modding);
        interp.variables.set("FileSystem",FileSystem);
		interp.variables.set("PlayState",PlayState);
		interp.variables.set("StageObject", StageObject);

        interp.allowStaticVariables = interp.allowPublicVariables = true;

        interp.variables.set("trace", function(value:Dynamic) {
            trace(value);
        });

        interp.variables.set("import", function(class_name:String) {
            var classes = class_name.split(".");

            if(Type.resolveClass(class_name) != null)
                interp.variables.set(classes[classes.length - 1], Type.resolveClass(class_name));
            else if(Type.resolveEnum(class_name) != null)
            {
                var enum_new = {};
                var good_enum = Type.resolveEnum(class_name);

                for(constructor in good_enum.getConstructors())
                {
                    Reflect.setField(enum_new, constructor, good_enum.createByName(constructor));
                }

                interp.variables.set(classes[classes.length - 1], enum_new);
            }
            else
                trace(class_name + " isn't a valid class or enum!");
        });
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
