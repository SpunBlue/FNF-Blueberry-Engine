package game;

import engine.modutil.Hscript;
import engine.modding.SpunModLib.ModLib;
import engine.modding.SpunModLib.ModAssets;
import StrumNotes;
import engine.Engine;
import flixel.math.FlxRandom;
import hxcodec.VideoHandler;
import util.ui.PreferencesMenu;
import sys.io.File;
import sys.FileSystem;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import DialogueBox.DialogueShitJson;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import shaderslmfao.BuildingShaders.BuildingShader;
import shaderslmfao.BuildingShaders;
import shaderslmfao.ColorSwap;

using StringTools;

#if discord_rpc
import Discord.DiscordClient;
#end

class PlayState extends MusicBeatState
{
	public static var instance:PlayState;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var storyWeek:Int = 0;
	public static var songPlaylist:Array<SongData> = [];
	public static var inLoopMode:Bool = false;
	public static var deathCounter:Int = 0;
	public static var practiceMode:Bool = false;

	var halloweenLevel:Bool = false;

	var doof:DialogueBox;

	public var vocals:FlxSound;
	public var vocalsFinished:Bool = false;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	public var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNotes> = new FlxTypedGroup<StrumNotes>();
	public var playerStrums:StrumNotes;
	public var cpuStrums:StrumNotes;

	public var camZooming:Bool = false;
	public var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public var layer1:FlxTypedGroup<FlxBasic>;
	public var layer2:FlxTypedGroup<FlxBasic>;
	public var layer3:FlxTypedGroup<FlxBasic>;

	var dialogue:DialogueShitJson;

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public var noteSplashGroup:FlxTypedGroup<NoteSplash>;

	public var tankmanRun:FlxTypedGroup<TankmenBG>;

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	public static var inCutscene:Bool = false;

	#if discord_rpc
	// Discord RPC variables
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	var daDRPCText:String = 'hi';
	#end

	public var script:Hscript = new Hscript();

	override public function create()
	{
		instance = this;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		Engine.debugPrint(songPlaylist);

		if (SONG == null){
			if (songPlaylist == null || songPlaylist == [])
				SONG = Song.loadFromJson('test', 'test');
			else{
				SONG = Song.loadFromJson(SONG.song.toLowerCase(),SONG.song.toLowerCase());
				FlxG.log.warn('FORCED RELOAD');

				#if release
				Engine.debugPrint('FORCED RELOAD');
				#end
			}
		}

		if (storyWeek != songPlaylist[0].week)
			storyWeek = songPlaylist[0].week;

		FlxG.sound.cache(Paths.inst(PlayState.SONG.song));
		FlxG.sound.cache(Paths.voices(PlayState.SONG.song));

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new SwagCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		persistentUpdate = true;
		persistentDraw = true;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		var modID:String = null;

		if (ModLib.curMod != null)
			modID = ModLib.curMod.id;

		if (FileSystem.exists('assets/data/charts/' + SONG.song.toLowerCase() + '/dialogue.json')){
			dialogue = Json.parse(File.getContent('assets/data/charts/' + SONG.song.toLowerCase() + '/dialogue.json'));
		}

		if (ModAssets.assetExists('data/charts/' + SONG.song.toLowerCase() + '/script.hx', null, modID)){
			script.loadScript('data/charts/' + SONG.song.toLowerCase(), 'script', modID);
		}

		switch (SONG.song.toLowerCase()){
			default:
				defaultCamZoom = 0.9;
				curStage = 'stage';
			case 'spookeez' | 'south' | 'monster':
				curStage = 'spooky';
			case 'pico' | 'philly' | 'philly-nice' | 'blammed':
				curStage = 'philly';
			case 'satin-panties' | 'high' | 'milf':
				defaultCamZoom = 0.9;
				curStage = 'limo';
			case "cocoa" | 'eggnog':
				defaultCamZoom = 0.8;
				curStage = 'mall';
			case 'winter-horrorland':
				curStage = 'mallEvil';
			case 'senpai' | 'roses':
				curStage = 'school';
			case 'thorns':
				curStage = 'schoolEvil';
			case 'guns' | 'stress' | 'ugh':
				defaultCamZoom = 0.9;
				curStage = 'tank';
		}

		if (ModAssets.assetExists('data/stages/' + curStage.toLowerCase() + '/script.hx', null, modID)){
			script.loadScript('data/stages/' + curStage.toLowerCase(), 'script', modID);
		}
		else{
			defaultCamZoom = 0.9;
			curStage = 'stage';
		}

		layer1 = new FlxTypedGroup<FlxBasic>();
		layer2 = new FlxTypedGroup<FlxBasic>();
		layer3 = new FlxTypedGroup<FlxBasic>();

		tankmanRun = new FlxTypedGroup<TankmenBG>();

		// Stage shit
		script.interp.variables.set("defaultCamZoom", defaultCamZoom);
		script.interp.variables.set("BackgroundDancer", BackgroundDancer);
		script.interp.variables.set("BackgroundGirls", BackgroundGirls);
		script.interp.variables.set("WiggleEffect", WiggleEffect);
		script.interp.variables.set("TankmenBG", TankmenBG);
		script.interp.variables.set("BGSprite", BGSprite);
		script.interp.variables.set("curStage", curStage);

		script.interp.variables.set("layer1", layer1);
		script.interp.variables.set("layer2", layer2);
		script.interp.variables.set("layer3", layer3);

		// Beat shit
		script.interp.variables.set("curBeat", curBeat);
		script.interp.variables.set("curStep", curStep);

		// Shaders
		script.interp.variables.set("BuildingShaders", BuildingShaders);
		script.interp.variables.set("ColorSwap", ColorSwap);

		// Characters
		script.interp.variables.set("boyfriend", boyfriend);
		script.interp.variables.set("dad", dad);
		script.interp.variables.set("gf", gf);

		// Goofy Ahhh functions
		script.interp.variables.set("camHUD", camHUD);
		script.interp.variables.set("camGame", camGame);

		script.interp.variables.set("add", function(value:Dynamic)
		{
			add(value);
		});

		script.interp.variables.set("remove", function(value:Dynamic)
		{
			remove(value);
		});

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school' | 'schoolEvil':
				gfVersion = 'gf-pixel';
			case 'tank':
				gfVersion = 'gf-tankmen';
		}

		if (SONG.song.toLowerCase() == 'stress')
			gfVersion = 'pico-speaker';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		switch (gfVersion)
		{
			case 'pico-speaker':
				gf.x -= 50;
				gf.y -= 200;

				var tempTankman:TankmenBG = new TankmenBG(20, 500, true);
				tempTankman.strumTime = 10;
				tempTankman.resetShit(20, 600, true);
				tankmanRun.add(tempTankman);
	
				for (i in 0...TankmenBG.animationNotes.length)
				{
					if (FlxG.random.bool(16))
					{
						var tankman:TankmenBG = tankmanRun.recycle(TankmenBG);
						tankman.strumTime = TankmenBG.animationNotes[i][0];
						tankman.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
						tankmanRun.add(tankman);
					}
				}
		}

		script.interp.variables.set("gfVersion", gfVersion);

		script.call("create"); // A lot of stuff here will not run or work properly.

		dad = new Character(100, 100, SONG.player2);

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;
			case 'mall':
				boyfriend.x += 200;
			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;

				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail);

				boyfriend.x += 200;
				boyfriend.y += 220;

				gf.x += 180;
				gf.y += 300;
			case "tank":
				gf.y += 10;
				gf.x -= 30;

				boyfriend.x += 40;
				boyfriend.y += 0;

				dad.y += 60;
				dad.x -= 80;

				if (gfVersion != 'pico-speaker')
				{
					gf.x -= 170;
					gf.y -= 75;
				}
		}

		dad.setPosition(dad.x + dad.charJson.Position[0], dad.y + dad.charJson.Position[1]);
		boyfriend.setPosition(boyfriend.x + boyfriend.charJson.Position[0], boyfriend.y + boyfriend.charJson.Position[1]);

		if (dad.curCharacter == gf.curCharacter)
			gf.visible = false;

        add(layer1);

		add(gf);

        add(layer2);

		add(dad);
		add(boyfriend);

        add(layer3);

		if (dialogue != null){
			doof = new DialogueBox(false, dialogue);
			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
			doof.cameras = [camHUD];
			doof.finishThing = startCountdown;
		}

		Conductor.songPosition = -5000;

		/*if (PreferencesMenu.getPref('downscroll'))
			daNote.strumTrack.y = FlxG.height - 150; // 150 just random ass number lol*/

		var s:String = '';

		switch (SONG.song.toLowerCase()){
			case 'senpai' | 'roses' | 'thorns':
				s = 'pixel';
		}
		
		generateStaticArrows(s, PreferencesMenu.getPref('middle-scroll'));
		add(strumLineNotes);

		noteSplashGroup = new FlxTypedGroup<NoteSplash>();
		add(noteSplashGroup);

		generateSong(s);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		var angrX:Float = (dad.getMidpoint().x + 150) + dad.charJson.CamPosition[0];
		var angrY:Float = (dad.getMidpoint().y - 100) + dad.charJson.CamPosition[1];
		
		camFollow.setPosition(angrX, angrY);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		if (PreferencesMenu.getPref('downscroll'))
			healthBarBG.y = FlxG.height * 0.1;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		noteSplashGroup.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		switch (curSong.toLowerCase())
		{
			case "winter-horrorland":
				var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				add(blackScreen);
				blackScreen.scrollFactor.set();
				camHUD.visible = false;

				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					remove(blackScreen);
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					camFollow.y = -2050;
					camFollow.x += 200;
					FlxG.camera.focusOn(camFollow.getPosition());
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				});
			case 'senpai' | 'roses' | 'thorns':
				schoolIntro();
			case 'ugh':
				ughIntro();
			case 'stress':
				stressIntro();
			case 'guns':
				gunsIntro();

			default:
				startCountdown();
		}

		super.create();

		script.call("createPost");

		#if discord_rpc
		rpcTimer.start(3, function(timer:FlxTimer){
			//var newText:String = 'Score: $songScore - Accuracy: ' + calculateRatingPercent() + ' - Misses: $songMisses - Combo: $combo';

			var newText:String = 'Score $songScore';

			if (OptionsData.botplay == true)
				newText += ' - Botplay is Enabled';

			if (daDRPCText != newText && paused == false){
				DiscordClient.changePresence("Playing " + SONG.song.toUpperCase() + ' | ' + newText, null);
				daDRPCText = newText;
			}
		}, 0);
		#end
	}

	function ughIntro()
	{
		playCutscene('ughCutscene');
	}

	function gunsIntro()
	{
		playCutscene('gunsCutscene');
	}

	function stressIntro()
	{
		playCutscene('stressCutscene');
	}

	function schoolIntro():Void
	{
		var dialogueBox = null;

		if (dialogue != null)
			dialogueBox = doof;
		
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * daPixelZoom));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += senpaiEvil.width / 5;
		senpaiEvil.antialiasing = false;

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
			else
				FlxG.sound.play(Paths.sound('ANGRY'));
			// moved senpai angry noise in here to clean up cutscene switch case lol
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
				tmr.reset(0.3);
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
								swagTimer.reset();
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
						add(dialogueBox);
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer = new FlxTimer();
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;
		camHUD.visible = true;

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			// this just based on beatHit stuff but compact
			if (swagCounter % gfSpeed == 0)
				gf.dance();

			boyfriend.dance();
			dad.dance();

			if (generatedMusic)
				notes.sort(sortNotes, FlxSort.DESCENDING);

			var introSprPaths:Array<String> = ["ready", "set", "go"];
			var altSuffix:String = "";

			if (curStage.startsWith("school"))
			{
				altSuffix = '-pixel';
				introSprPaths = ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel'];
			}

			var introSndPaths:Array<String> = ["intro3" + altSuffix, "intro2" + altSuffix,
				"intro1" + altSuffix, "introGo" + altSuffix];

			if (swagCounter > 0)
				readySetGo(introSprPaths[swagCounter - 1]);
			FlxG.sound.play(Paths.sound(introSndPaths[swagCounter]), 0.6);

			/* switch (swagCounter)
			{
				case 0:
					
				case 1:
					
				case 2:
					
				case 3:
					
			} */

			swagCounter += 1;
		}, 4);
	}

	function readySetGo(path:String):Void
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(path));
		spr.scrollFactor.set();

		if (curStage.startsWith('school'))
			spr.setGraphicSize(Std.int(spr.width * daPixelZoom));

		spr.updateHitbox();
		spr.screenCenter();
		add(spr);
		FlxTween.tween(spr, {y: spr.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				spr.destroy();
			}
		});
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if discord_rpc
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		#end
	}

	private function generateSong(noteStyle:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song));
		else
			vocals = new FlxSound();

		vocals.onComplete = function()
		{
			vocalsFinished = true;
		};
		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var strum:StrumNotes;

				if (gottaHitNote)
					strum = playerStrums
				else
					strum = cpuStrums;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, null, strum.arrows[daNoteData], noteStyle, false);
				swagNote.sustainLength = songNotes[2];
				swagNote.altNote = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, strum.arrows[daNoteData], noteStyle, false);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;
				}

				swagNote.mustPress = gottaHitNote;
			}
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	// Now you are probably wondering why I made 2 of these very similar functions
	// sortByShit(), and sortNotes(). sortNotes is meant to be used by both sortByShit(), and the notes FlxGroup
	// sortByShit() is meant to be used only by the unspawnNotes array.
	// and the array sorting function doesnt need that order variable thingie
	// this is good enough for now lololol HERE IS COMMENT FOR THIS SORTA DUMB DECISION LOL
	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return sortNotes(FlxSort.ASCENDING, Obj1, Obj2);
	}

	function sortNotes(order:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note)
	{
		return FlxSort.byValues(order, Obj1.strumTime, Obj2.strumTime);
	}

	// ^ These two sorts also look cute together ^
	// ^ I quite agree dev who will never see this -SpunBlue ^

	private function generateStaticArrows(style:String, ?dontGenCPU:Bool = false, ?skipTransition:Bool = false):Void
	{
		var strumLine:Float = 50;

		if (PreferencesMenu.getPref('downscroll'))
			strumLine = FlxG.height - 150;

		if (!dontGenCPU){
			cpuStrums = new StrumNotes(0, 0, strumLine, (FlxG.width / 2) / 6, style);
			strumLineNotes.add(cpuStrums);
		}

		playerStrums = new StrumNotes(0, 0, strumLine, (FlxG.width / 2), style);
		strumLineNotes.add(playerStrums);

		for (strum in strumLineNotes){
			if (!skipTransition)
				strum.doNoteTransition();
			else{
				for (arrow in strum.arrows){
					if (arrow.alpha == 0)
						arrow.alpha == 1;
				}
			}
		}
	}

	public function replaceArrows(style:String, ?skipTransition:Bool = false, ?dontGenCPU:Bool = false){
		for (strum in strumLineNotes){
			strum.kill();
		}

		generateStaticArrows(style, dontGenCPU);

		// update the funn

		notes.forEach(function(note:Note){
			if (note.style != style)
				note.updateStyle(style);

			if (note.mustPress)
				note.updateTracker(playerStrums.arrows[note.noteData]);
			else{
				if (!dontGenCPU){
					note.updateTracker(cpuStrums.arrows[note.noteData]);
					note.hideNote = false;
				}
				else
					note.hideNote = true;
			}
		});

		for (note in unspawnNotes){
			if (note.style != style)
				note.updateStyle(style);

			if (note.mustPress)
				note.updateTracker(playerStrums.arrows[note.noteData]);
			else{
				if (!dontGenCPU){
					note.updateTracker(cpuStrums.arrows[note.noteData]);
					note.hideNote = false;
				}
				else
					note.hideNote = true;
			}
		}

		for (strum in strumLineNotes){
			if (!skipTransition)
				strum.doNoteTransition();
			else{
				for (arrow in strum.arrows){
					if (arrow.alpha == 0)
						arrow.alpha == 1;
				}
			}
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if discord_rpc
			if (startTimer.finished)
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		super.closeSubState();
	}

	#if discord_rpc
	override public function onFocus():Void
	{
		if (health > 0 && !paused && FlxG.autoPause)
		{
			if (Conductor.songPosition > 0.0)
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (health > 0 && !paused && FlxG.autoPause)
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);

		super.onFocusLost();
	}
	#end

	function resyncVocals():Void
	{
		if (_exiting)
			return;

		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

		if (vocalsFinished)
			return;

		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		// makes the lerp non-dependant on the framerate
		// FlxG.camera.followLerp = CoolUtil.camLerpShit(0.04);

		#if !debug
		perfectMode = false;
		#end

		// do this BEFORE super.update() so songPosition is accurate
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset; // 20 is THE MILLISECONDS??
			// Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// Engine.debugPrint('MISSED FRAME');
				}
			}
			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		// Script Variables
		script.interp.variables.set("boyfriend", boyfriend);
		script.interp.variables.set("dad", dad);
		script.interp.variables.set("gf", gf);

		script.call("update", [elapsed]);

		super.update(elapsed);

		// strum testing
		for (strum in strumLineNotes.members){
			if (FlxG.keys.pressed.I)
				strum.y -= 2;
			else if (FlxG.keys.pressed.K)
				strum.y += 2;
			
			if (FlxG.keys.pressed.J)
				strum.x -= 2;
			else if (FlxG.keys.pressed.L)
				strum.x += 2;
		}

		if (FlxG.keys.justPressed.ALT)
			replaceArrows('pixel', false, true);

		scoreTxt.text = "Score:" + songScore;

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
			{
				var boyfriendPos = boyfriend.getScreenPosition();
				var pauseSubState = new PauseSubState(boyfriendPos.x, boyfriendPos.y);
				openSubState(pauseSubState);
				pauseSubState.camera = camHUD;
				boyfriendPos.put();
			}

			#if discord_rpc
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if discord_rpc
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.85)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.85)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		if (FlxG.keys.justPressed.EIGHT)
		{
			/* 	 8 for opponent char
			   SHIFT+8 for player char
				 CTRL+SHIFT+8 for gf   */
			if (FlxG.keys.pressed.SHIFT)
				if (FlxG.keys.pressed.CONTROL)
					FlxG.switchState(new AnimationDebug(gf.curCharacter));
				else 
					FlxG.switchState(new AnimationDebug(SONG.player1));
			else
				FlxG.switchState(new AnimationDebug(SONG.player2));
		}
		if (FlxG.keys.justPressed.PAGEUP)
			changeSection(1);
		if (FlxG.keys.justPressed.PAGEDOWN)
			changeSection(-1);
		#end

		if (generatedMusic && SONG.notes[Std.int(curStep / 16)] != null)
		{
			cameraRightSide = SONG.notes[Std.int(curStep / 16)].mustHitSection;

			cameraMovement();
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
			}
		}

		// better streaming of shit

		if (!inCutscene && !_exiting)
		{
			// RESET = Quick Game Over Screen
			if (controls.RESET)
			{
				health = 0;
				Engine.debugPrint("RESET = True");
			}

			#if CAN_CHEAT // brandon's a pussy
			if (controls.CHEAT)
			{
				health += 1;
				Engine.debugPrint("User is cheating!");
			}
			#end

			if (health <= 0 && !practiceMode)
			{
				// boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				// unloadAssets();

				deathCounter += 1;

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if discord_rpc
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
				#end
			}
		}

		while (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 1800 / SONG.speed)
		{
			var dunceNote:Note = unspawnNotes[0];
			notes.add(dunceNote);

			var index:Int = unspawnNotes.indexOf(dunceNote);
			unspawnNotes.shift();
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				// note interpolation
				daNote.y = (daNote.strumTrack.y - (songTime - daNote.strumTime) * (0.45 * /*songScrollSpeed*/ SONG.speed));

				if ((PreferencesMenu.getPref('downscroll') && daNote.y < -daNote.height)
					|| (!PreferencesMenu.getPref('downscroll') && daNote.y > FlxG.height))
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				var strumLineMid = daNote.strumTrack.y + Note.swagWidth / 2;

				if (PreferencesMenu.getPref('downscroll'))
				{
					daNote.y = (daNote.strumTrack.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

					if (daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith("end") && daNote.prevNote != null)
							daNote.y += daNote.prevNote.height;
						else
							daNote.y += daNote.height / 2;

						if ((!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))
							&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= strumLineMid)
						{
							// clipRect is applied to graphic itself so use frame Heights
							var swagRect:FlxRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);

							swagRect.height = (strumLineMid - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
							daNote.clipRect = swagRect;
						}
					}
				}
				else
				{
					daNote.y = (daNote.strumTrack.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

					if (daNote.isSustainNote
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))
						&& daNote.y + daNote.offset.y * daNote.scale.y <= strumLineMid)
					{
						var swagRect:FlxRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);

						swagRect.y = (strumLineMid - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;
						daNote.clipRect = swagRect;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					if (daNote.altNote)
						altAnim = '-alt';

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
						case 2:
							dad.playAnim('singUP' + altAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
					}

					if (cpuStrums != null){
						cpuStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
							}	
						});

						cpuStrums.updateOffsets();
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// removing this so whether the note misses or not is entirely up to Note class
				// var noteMiss:Bool = daNote.y < -daNote.height;

				// if (PreferencesMenu.getPref('downscroll'))
					// noteMiss = daNote.y > FlxG.height;

				/*if (daNote.isSustainNote && daNote.tooLate)
				{
					if ((!PreferencesMenu.getPref('downscroll') && daNote.y < -daNote.height)
						|| (PreferencesMenu.getPref('downscroll') && daNote.y > FlxG.height))
					{
						if (!daNote.noteFuckingDying)
							daNote.fuckNote(notes);
					}
				}
				else */
				if (daNote.tooLate && !daNote.noteFuckingDying){
					script.call("noteTooLate", [daNote]);

					if (daNote.isSustainNote)
						health -= 0.05;
					else
						health -= 0.1;

					vocals.volume = 0;
					killCombo();

					daNote.fuckNote(notes);
				}
				else if (daNote.wasGoodHit && !daNote.isSustainNote){
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		cpuStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		if (!inCutscene)
			keyShit();

		script.call("updatePost", [elapsed]);
	}

	function killCombo():Void
	{
		if (combo > 5 && gf.animOffsets.exists('sad'))
			gf.playAnim('sad');
		if (combo != 0)
		{
			combo = 0;
			displayCombo();
		}
	}

	#if debug
	function changeSection(sec:Int):Void
	{
		FlxG.sound.music.pause();

		var daBPM:Float = SONG.bpm;
		var daPos:Float = 0;
		for (i in 0...(Std.int(curStep / 16 + sec)))
		{
			if (SONG.notes[i].changeBPM)
			{
				daBPM = SONG.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		Conductor.songPosition = FlxG.sound.music.time = daPos;
		updateCurStep();
		resyncVocals();
	}
	#end

	function endSong():Void
	{
		deathCounter = 0;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		var lastWeek:Int = storyWeek;

		if (SONG.validScore)
		{
			Highscore.saveScore(SONG.song, songScore);
		}

		switch (SONG.song.toLowerCase()){
			default:
				Engine.debugPrint('Continuing');
		}

		songPlaylist.remove(songPlaylist[0]);

		if (SONG.song.toLowerCase() == 'eggnog')
		{
			var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
				-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			blackShit.scrollFactor.set();
			add(blackShit);
			camHUD.visible = false;

			FlxG.sound.play(Paths.sound('Lights_Shut_off'));
		}

		if (songPlaylist != null && songPlaylist[0] != null && songPlaylist[0].week != null && songPlaylist != [])
			storyWeek = songPlaylist[0].week;

		if (songPlaylist.length <= 0){
			songPlaylist = []; // reset the playlist lol

			if (!inLoopMode){
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.sound.music.fadeIn(0.5, 0, 1);
				Conductor.changeBPM(102);

				FlxG.switchState(new FreeplayState());

				return;
			}
			else{
				for (song in FreeplayState.loopList){
					songPlaylist.push(song);
				}

				PlayState.SONG = Song.loadFromJson(songPlaylist[0].songName.toLowerCase(), songPlaylist[0].songName);
			}
		}
		else{
			Engine.debugPrint('LOADING NEXT SONG');

			//Engine.debugPrint(songPlaylist[0].songName.toLowerCase());

			PlayState.SONG = Song.loadFromJson(songPlaylist[0].songName.toLowerCase(), songPlaylist[0].songName);
			
			FlxG.sound.music.stop();

			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			prevCamFollow = camFollow;
			
		}

		#if PRELOAD_ALL
		if (storyWeek != lastWeek)
			LoadingState.loadAndSwitchState(new PlayState(), false);
		else
			FlxG.resetState();
		#else
		LoadingState.loadAndSwitchState(new PlayState(), false);
		#end
	}

	// gives score and pops up rating
	private function popUpScore(strumtime:Float, daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.45)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.35)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.25)
		{
			daRating = 'good';
			score = 200;
		}
		else{
			spawnNoteSplash(daNote.noteData);
		}

		// Only add the score if you're not on practice mode
		if (!practiceMode)
			songScore += score;

		// ludum dare rating system
		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var ratingPath:String = daRating;

		if (curStage.startsWith('school'))
			ratingPath = "weeb/pixelUI/" + ratingPath + "-pixel";

		rating.loadGraphic(Paths.image(ratingPath));
		rating.x = FlxG.width * 0.55 - 40;
		// make sure rating is visible lol!
		if (rating.x < FlxG.camera.scroll.x)
			rating.x = FlxG.camera.scroll.x;
		else if (rating.x > FlxG.camera.scroll.x + FlxG.camera.width - rating.width)
			rating.x = FlxG.camera.scroll.x + FlxG.camera.width - rating.width;

		rating.y = FlxG.camera.scroll.y + FlxG.camera.height * 0.4 - 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		add(rating);

		if (curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
		}
		rating.updateHitbox();

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
		if (combo >= 10 || combo == 0)
			displayCombo();
	}

	function displayCombo():Void
	{
		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.y = FlxG.camera.scroll.y + FlxG.camera.height * 0.4 + 80;
		comboSpr.x = FlxG.width * 0.55;
		// make sure combo is visible lol!
		// 194 fits 4 combo digits
		if (comboSpr.x < FlxG.camera.scroll.x + 194)
			comboSpr.x = FlxG.camera.scroll.x + 194;
		else if (comboSpr.x > FlxG.camera.scroll.x + FlxG.camera.width - comboSpr.width)
			comboSpr.x = FlxG.camera.scroll.x + FlxG.camera.width - comboSpr.width;

		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.velocity.x += FlxG.random.int(1, 10);

		add(comboSpr);

		if (curStage.startsWith('school'))
		{
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}
		else
		{
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		comboSpr.updateHitbox();

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		var seperatedScore:Array<Int> = [];
		var tempCombo:Int = combo;

		while (tempCombo != 0)
		{
			seperatedScore.push(tempCombo % 10);
			tempCombo = Std.int(tempCombo / 10);
		}
		while (seperatedScore.length < 3)
			seperatedScore.push(0);

		// seperatedScore.reverse();

		var daLoop:Int = 1;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.y = comboSpr.y;

			if (curStage.startsWith('school'))
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			else
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			numScore.updateHitbox();

			numScore.x = comboSpr.x - (43 * daLoop); //- 90;
			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
	}

	var cameraRightSide:Bool = false;

	/**
	 * used for updating camera pos values
	 */
	var dadNeedsCamUpdate:Bool = true;

	/**
	 * used for updating camera pos values
	 */
	var bfNeedsCamUpdate:Bool = true;

	var dadCamGoofy_X:Float = 0;
	var dadCamGoofy_Y:Float = 0;

	var bfCamGoofy_X:Float = 0;
	var bfCamGoofy_Y:Float = 0;

	function cameraMovement()
	{
		if (dadNeedsCamUpdate){
			dadCamGoofy_X = (dad.getMidpoint().x + 150) + dad.charJson.CamPosition[0];
			dadCamGoofy_Y = (dad.getMidpoint().y - 100) + dad.charJson.CamPosition[1];

			dadNeedsCamUpdate == false;
		}

		if (bfNeedsCamUpdate){
			bfCamGoofy_X = (boyfriend.getMidpoint().x - 100) + boyfriend.charJson.CamPosition[0];
			bfCamGoofy_Y = (boyfriend.getMidpoint().y - 100) + boyfriend.charJson.CamPosition[1];

			bfNeedsCamUpdate == false;
		}

		if (camFollow.getPosition() != FlxPoint.get(dadCamGoofy_X, dadCamGoofy_Y) && !cameraRightSide)
		{
			camFollow.setPosition(dadCamGoofy_X, dadCamGoofy_Y);

			if (SONG.song.toLowerCase() == 'tutorial')
				tweenCamIn();
		}

		if (cameraRightSide && camFollow.getPosition() != FlxPoint.get(bfCamGoofy_X, bfCamGoofy_Y))
		{
			camFollow.setPosition(bfCamGoofy_X, bfCamGoofy_Y);

			if (SONG.song.toLowerCase() == 'tutorial')
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
		}
	}

	private function keyShit():Void
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var pressArray:Array<Bool> = [
			controls.NOTE_LEFT_P,
			controls.NOTE_DOWN_P,
			controls.NOTE_UP_P,
			controls.NOTE_RIGHT_P
		];
		var releaseArray:Array<Bool> = [
			controls.NOTE_LEFT_R,
			controls.NOTE_DOWN_R,
			controls.NOTE_UP_R,
			controls.NOTE_RIGHT_R
		];

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}

		// PRESSES, check for note hits
		if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = []; // notes that can be hit
			var directionList:Array<Int> = []; // directions that can be hit
			var dumbNotes:Array<Note> = []; // notes to kill later

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					if (directionList.contains(daNote.noteData))
					{
						for (coolNote in possibleNotes)
						{
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
							{ // if it's the same note twice at < 10ms distance, just delete it
								// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
								dumbNotes.push(daNote);
								break;
							}
							else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
							{ // if daNote is earlier than existing note (coolNote), replace
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});

			for (note in dumbNotes)
			{
				FlxG.log.add("killing dumb ass note at " + note.strumTime);
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			if (perfectMode)
				goodNoteHit(possibleNotes[0]);
			else if (possibleNotes.length > 0)
			{
				for (shit in 0...pressArray.length)
				{ // if a direction is hit that shouldn't be
					if (pressArray[shit] && !directionList.contains(shit))
						noteMiss(shit);
				}
				for (coolNote in possibleNotes)
				{
					if (pressArray[coolNote.noteData])
						goodNoteHit(coolNote);
				}
			}
			else
			{
				for (shit in 0...pressArray.length)
					if (pressArray[shit])
						noteMiss(shit);
			}
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idle');
			}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!holdArray[spr.ID])
				spr.animation.play('static');
		});

		playerStrums.updateOffsets();
	}

	function noteMiss(direction:Int = 1):Void
	{
		script.call("noteMiss", [direction]);

		health -= 0.1;
		killCombo();

		if (!practiceMode)
			songScore -= 10;

		vocals.volume = 0;
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		switch (direction)
		{
			case 0:
				boyfriend.playAnim('singLEFTmiss', true);
			case 1:
				boyfriend.playAnim('singDOWNmiss', true);
			case 2:
				boyfriend.playAnim('singUPmiss', true);
			case 3:
				boyfriend.playAnim('singRIGHTmiss', true);
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			script.call("goodNoteHit", [note]);

			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note.strumTime, note);
			}

			if (note.noteData >= 0)
				health += 0.05;
			else
				health += 0.005;

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public inline function spawnNoteSplash(noteData:Int) {
		var staticNote:FlxSprite = playerStrums.members[noteData];
		createNoteSplash(staticNote.x, staticNote.y, noteData);
	}

	public inline function createNoteSplash(x:Float, y:Float, noteData:Int) {
		var splash:NoteSplash = new NoteSplash(x, y, noteData);
		noteSplashGroup.add(splash);
	}

	override function stepHit()
	{
		super.stepHit();

		script.call("stepHit", [curStep]);

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}
	}

	override function beatHit()
	{
		super.beatHit();
		
		script.call("beatHit", [curBeat]);

		if (generatedMusic)
		{
			notes.sort(sortNotes, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
		}

		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0 && (gf.animation.curAnim.name.startsWith('dance') || gf.animation.curAnim.name != 'idle' && gf.animation.curAnim.finished))
			gf.dance();

		if (boyfriend.isDancing() || !boyfriend.isDancing() && !boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.animation.curAnim.finished 
			|| perfectMode && boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.animation.curAnim.finished)
		{
			boyfriend.dance();
		}

		if (dad.isDancing() || !dad.isDancing() && !dad.animation.curAnim.name.startsWith("sing") && dad.animation.curAnim.finished)
		{
			dad.dance();
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}
		
		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}
	}

	function playCutscene(name:String, atEndOfSong:Bool = false)
	{	
		var tVol:Float = 0;

		inCutscene = true;
		FlxG.sound.music.stop();

		tVol = FlxG.sound.volume;

		var video:VideoHandler = new VideoHandler();
		video.finishCallback = function()
		{
			FlxG.sound.volume = tVol;

			if (atEndOfSong)
			{
				songPlaylist.remove(songPlaylist[0]);

				if (songPlaylist.length <= 0)
					FlxG.switchState(new FreeplayState());
				else
				{
					PlayState.SONG = Song.loadFromJson(songPlaylist[0].songName.toLowerCase(), songPlaylist[0].songName);
					LoadingState.loadAndSwitchState(new PlayState(), false);
				}
			}
			else
				startCountdown();
		}

		video.playVideo(Paths.video(name));
		
		if (FlxG.sound.volume < 0.5)
			FlxG.sound.volume = 0.5;
	}
}

typedef SongData = {
	var songName:String;
	var ?week:Int;
	var ?modID:String;
}