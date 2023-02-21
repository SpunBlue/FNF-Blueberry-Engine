package game;

import engine.modding.SpunModLib.ModAssets;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.display.Display.Package;
import util.ui.PreferencesMenu;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";
	var randomGameover:Int = 1;

	public var fallback:Bool = false;

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = 'bf';

		switch(daStage.toLowerCase()){
			case 'school' | 'schoolevil':
				stageSuffix = '-pixel';
		}

		daBf = PlayState.SONG.player1;

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);

		if (bf.animation.exists('firstDeath'))
			bf.playAnim('firstDeath');
		else{
			if (!bf.animation.exists('singLEFTmiss'))
				bf.playAnim('singLEFT');
			else
				bf.playAnim('singLEFTmiss');
			fallback = true;
		}
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		var randomCensor:Array<Int> = [];

		if (PreferencesMenu.getPref('censor-naughty'))
			randomCensor = [1, 3, 8, 13, 17, 21];

		randomGameover = FlxG.random.int(1, 25, randomCensor);
	}

	var playingDeathSound:Bool = false;

	override function update(elapsed:Float)
	{
		// makes the lerp non-dependant on the framerate
		// FlxG.camera.followLerp = CoolUtil.camLerpShit(0.01);

		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			PlayState.deathCounter = 0;
			FlxG.sound.music.stop();

			FlxG.switchState(new FreeplayState());
		}

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(bf.curCharacter));
		#end

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		switch (PlayState.storyWeek)
		{
			case 7:
				if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished && !playingDeathSound)
				{
					playingDeathSound = true;

					bf.startedDeath = true;
					coolStartDeath(0.2);

					FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + randomGameover), 1, false, null, true, function()
					{
						if (!isEnding)
							FlxG.sound.music.fadeIn(4, 0.2, 1);
					});
				}
			default:
				if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
				{
					bf.startedDeath = true;
					coolStartDeath();
				}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	private function coolStartDeath(?vol:Float = 1):Void
	{
		if (!isEnding)
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix), vol);
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if (bf.animation.exists('deathConfirm'))
				bf.playAnim('deathConfirm', true);
			else if (bf.animation.exists('singDOWNmiss'))
				bf.playAnim('singDOWNmiss');
			else
				bf.playAnim('singDOWN');
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
