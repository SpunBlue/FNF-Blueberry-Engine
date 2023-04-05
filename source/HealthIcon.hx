package;

import game.PlayState;
import flixel.FlxSprite;
import engine.modding.SpunModLib.ModLib;
import engine.modding.SpunModLib.ModAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	var char:String = '';

	var sprOff:Int = 0;
	var sprYOff:Int = 0;
	
	var isPlayer:Bool = false;

	public function new(?char:String, isPlayer:Bool = false, ?sprOffset:Int, ?sprYOffset:Int)
	{
		super();

		sprOff = sprOffset;
		sprYOff = sprYOffset;

		this.isPlayer = isPlayer;

		changeIcon(char);
		antialiasing = true;
		scrollFactor.set();
	}

	public var isOldIcon:Bool = false;

	public function swapOldIcon():Void
	{
		isOldIcon = !isOldIcon;

		if (isOldIcon)
			changeIcon('bf-old');
		else
			changeIcon(PlayState.SONG.player1);
	}

	public function changeIcon(newChar:String):Void
	{
		if (newChar != 'bf-pixel' && newChar != 'bf-old')
			newChar = newChar.split('-')[0].trim();

		if (newChar != char)
		{
			if (animation.getByName(newChar) == null)
			{
				loadGraphic(ModAssets.getGraphic('images/icons/icon-$newChar.png', ModLib.curMod, null), true, 150, 150);
				// loadGraphic(Paths.image('icons/icon-' + newChar), true, 150, 150);
				animation.add(newChar, [0, 1], 0, false, isPlayer);
			}
			animation.play(newChar);
			char = newChar;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + (sprTracker.width + 10) + sprOff, (sprTracker.y - 30) + sprYOff);
	}
}
