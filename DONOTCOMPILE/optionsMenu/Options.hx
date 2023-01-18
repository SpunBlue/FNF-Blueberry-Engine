package engine.optionsMenu;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class Options
{
	public static var masterVolume:Float = 1;
	public static var userControls:Array<FlxKey> = /*[W,A,S,D]*/ [J,F,D,K];

	public static function init(){
		// load existing shit lol
		if (FlxG.save.data.userControls != null)
			Options.userControls = FlxG.save.data.userControls;

		// if null
	}
}
