package game;

import engine.OptionsData;
import engine.editors.ChartingState;
import engine.Engine;
import engine.modding.Stages;
import engine.Engine;
import engine.modding.Stages;
import engine.modding.Modding;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Charter'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float)
	{
		super();

		if (Modding.modLoaded){
			//menuItems.push('Reload Data');
			menuItems.push('Exit to menu');
		}
		else
			menuItems.push('Exit to menu');

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('pause'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "If you see this, something went wrong.", 32);

		//var tempArray = PlayState.SONG.song.split('-');

		for (i in 0...PlayState.songPlaylist.length){
			var breaker:String = '\n';

			if (i == 0){
				levelInfo.text = '';
			}

			if (i < 21){
				if (i > 0)
					levelInfo.text += PlayState.songPlaylist[i].songName.toString().toUpperCase() + breaker;
				else
					levelInfo.text += '> ' + PlayState.songPlaylist[i].songName.toString().toUpperCase() + ' <' + breaker;
			}
			else if (i == 21){
				var lol:Int = PlayState.songPlaylist.length - i;
				levelInfo.text += 'And $lol more...';
				break;
			}
		}

		/*for (i in 0...tempArray.length){
			levelInfo.text += tempArray[i];

			if (i != tempArray.length - 1)
				levelInfo.text += ' ';
		}*/

		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		levelInfo.updateHitbox();
		add(levelInfo);

		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					Stages.reset();
					FlxG.resetState();
				case "Exit to menu":
					Stages.reset();

					FlxG.switchState(new MainMenuState());
				case "Charter":
					Stages.reset();

					FlxG.switchState(new ChartingState());
				case "Animation Debug":
					Stages.reset();
					FlxG.switchState(new AnimationDebug(PlayState.SONG.player2));
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
