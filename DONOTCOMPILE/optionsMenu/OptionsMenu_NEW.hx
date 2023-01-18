package engine.optionsMenu;

import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import engine.optionsMenu.misc.OptionTextButton;

class OptionsMenu extends MusicBeatState
{
    var mouseCursor:FlxSprite;

	var optionGroup:FlxTypedGroup<OptionTextButton> = new FlxTypedGroup();

	var uiGroup:FlxGroup = new FlxGroup();
	var mouseGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

	var optionsArray:Array<String> = ['Gameplay', 'Graphics', 'Modding'];

	var uiBG:FlxSprite;
    
    override public function create()
    {
        super.create();

		allowCamBeat = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.scrollFactor.set();
		add(bg);

		uiBG = new FlxSprite(512, 0).makeGraphic(704, 640, FlxColor.BLUE);
		uiBG.screenCenter(Y);
		uiBG.alpha = 0.6;
		add(uiBG);

		add(uiGroup);
		add(optionGroup);
		add(mouseGroup);

		mouseCursor = new FlxSprite().loadGraphic(Paths.image('optionsmenu/cursor'));
		mouseGroup.add(mouseCursor);

		var lastY:Float = 0;

		for (option in optionsArray){
			trace(option);

			var option:OptionTextButton = new OptionTextButton(0, lastY + 192, option);
			optionGroup.add(option);

			lastY += (192 / 2);
		}
	}

	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time;

		camera.zoom = FlxMath.lerp(camera.zoom, camera.initialZoom, 0.1);

		super.update(elapsed);

		mouseCursor.setPosition(FlxG.mouse.x, FlxG.mouse.y);

		if (controls.BACK)
        {
            FlxG.switchState(new game.MainMenuState());
        }

		for (option in optionGroup.members){
			if (option.isClicked())
				loadMenu(option.text);
		}
	}

	private function loadMenu(menu:String){
		for (members in uiGroup.members){
			if (members != null){
				members.kill();
				uiGroup.remove(members);
			}
		}

		switch (menu.toLowerCase()){
			case 'gameplay':
				// bruh
		}
	}
}