package;

import flixel.FlxObject;
import sys.FileSystem;
import engine.modding.Modding;
import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxObject;
	var sprOff:Int = 0;
	var sprYOff:Int = 0;

	public function new(char:String = 'bf', isPlayer:Bool = false, ?sprOffset:Int, ?sprYOffset:Int)
	{
		super();

		sprOff = sprOffset;
		sprYOff = sprYOffset;

		trace('char: $char');

		antialiasing = true;

		if (FileSystem.exists(Modding.getFilePath('icon-$char.png', 'images/icons'))){
			loadGraphic(Modding.retrieveImage('icon-$char', 'images/icons', 'IconIMGASSET'), true, 150, 150);

			animation.add('$char', [0, 1], 0, false, isPlayer);

			animation.play(char);
		}
		else if (FileSystem.exists('assets/shared/images/icons/icon-$char.png')){
			loadGraphic(Paths.image('icons/icon-$char', 'shared'), true, 150, 150);

			animation.add('$char', [0, 1], 0, false, isPlayer);

			animation.play(char);
		}
		else{
			loadGraphic(Paths.image('iconGrid'), true, 150, 150);

			animation.add('bf', [0, 1], 0, false, isPlayer);
			animation.add('bf-car', [0, 1], 0, false, isPlayer);
			animation.add('bf-christmas', [0, 1], 0, false, isPlayer);
			animation.add('bf-pixel', [21, 21], 0, false, isPlayer);
			animation.add('spooky', [2, 3], 0, false, isPlayer);
			animation.add('pico', [4, 5], 0, false, isPlayer);
			animation.add('mom', [6, 7], 0, false, isPlayer);
			animation.add('mom-car', [6, 7], 0, false, isPlayer);
			animation.add('tankman', [8, 9], 0, false, isPlayer);
			animation.add('face', [10, 11], 0, false, isPlayer);
			animation.add('dad', [12, 13], 0, false, isPlayer);
			animation.add('senpai', [22, 22], 0, false, isPlayer);
			animation.add('senpai-angry', [22, 22], 0, false, isPlayer);
			animation.add('spirit', [23, 23], 0, false, isPlayer);
			animation.add('bf-old', [14, 15], 0, false, isPlayer);
			animation.add('gf', [16], 0, false, isPlayer);
			animation.add('parents-christmas', [17], 0, false, isPlayer);
			animation.add('monster', [19, 20], 0, false, isPlayer);
			animation.add('monster-christmas', [19, 20], 0, false, isPlayer);
	
			if (animation.exists(char))
				animation.play(char);
			else
				animation.play('face');
	
			scrollFactor.set();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + (sprTracker.width + 10) + sprOff, (sprTracker.y - 30) + sprYOff);
	}
}
