package game;

import util.EventNote.ChartEvent;
import flixel.system.FlxAssets.FlxSoundAsset;
import engine.modding.SpunModLib.Mod;
import haxe.io.Path;
import game.editors.ChartingState;
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

typedef StageJSON = {
	var defaultZoom:Float;
	var spawnGirlfriend:Bool;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var dad:Array<Dynamic>;
}

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var storyWeek:Int = 0;
	public static var songPlaylist:Array<SongData> = [];
	public static var inLoopMode:Bool = false;
	public static var deathCounter:Int = 0;
	public static var practiceMode:Bool = false;

	var halloweenLevel:Bool = false;

	var doof:DialogueBox;

	private var vocals:FlxSound;
	private var inst:FlxSoundAsset;

	private var vocalsFinished:Bool = false;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	public var curBF:Boyfriend;
	public var curDAD:Character;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNotes> = new FlxTypedGroup<StrumNotes>();
	public var noteSplashGroup:FlxTypedGroup<NoteSplash>;

	private var playerStrums:StrumNotes;
	private var cpuStrums:StrumNotes;

	public var camZooming:Bool = false;
	public var curSong:String = "";

	public var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public var gfVersion:String = 'gf';

	var dialogue:DialogueShitJson;

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;
	var hitsTxt:FlxText;
	var textSpacer = '';

	public var shits:Int = 0;
	public var bads:Int = 0;
	public var goods:Int = 0;
	public var sicks:Int = 0;
	public var mints:Int = 0;

	public var songHits:Int = 0;
	public var songMisses:Int = 0;

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05;
	public var defaultHudZoom:Float = 1;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	public static var inCutscene:Bool = false;

	var songLength:Float = 0;

	#if discord_rpc
	// Discord RPC variables;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	var daDRPCText:String = 'hi';
	var rpcTimer:FlxTimer = new FlxTimer();
	#end

	public var script:Hscript = new Hscript();

	// layers
	public var boyfriendGroup:FlxTypedGroup<Boyfriend> = new FlxTypedGroup();
	public var dadGroup:FlxTypedGroup<Character> = new FlxTypedGroup();
	public var gfGroup:FlxTypedGroup<Character> = new FlxTypedGroup();

	// stage layers
	public var layer0:FlxGroup = new FlxGroup();
	public var layer1:FlxGroup = new FlxGroup();
	public var layer2:FlxGroup = new FlxGroup();
	
	var ext:String = #if web 'mp3' #else 'ogg' #end;

	var songEvents:Array<ChartEvent> = [];

	/**
	 * Hscript is so fucking goofy. Variables won't update automatically for some fucking reason.
	 * @param onlyUpdate Only add variables that update in-game.
	 */
	function setScriptVar(?onlyUpdate:Bool = false, script:Hscript){
		if (!onlyUpdate){
			// Functions
			script.interp.variables.set("add", function(value:Dynamic)
			{
				add(value);
			});
			script.interp.variables.set("setDefaultZoom", function(value:Dynamic)
			{
				defaultCamZoom = value;
			});
			script.interp.variables.set("setGF", function(value:Dynamic)
			{
				gfVersion = value;
			});
			script.interp.variables.set("curGF", function()
			{
				return gfVersion;
			});
			script.interp.variables.set("createTrail", function(char:Dynamic, graphic:Dynamic, length:Dynamic, delay:Dynamic, alpha:Dynamic, diff:Dynamic, ?addInGroup:Dynamic, ?group:Dynamic){
				var trail = new FlxTrail(char, graphic, length, delay, alpha, diff);
				
				if (addInGroup == true && group != null)
					group.add(trail);
				else
					add(trail);
			});

			// No idea if this will work
			script.interp.variables.set("addCharacter", addCharacter);
			script.interp.variables.set("removeCharacter", removeCharacter);
			script.interp.variables.set("getCharFromID", getCharFromID);

			// Stage shit
			script.interp.variables.set("BackgroundDancer", BackgroundDancer);
			script.interp.variables.set("BackgroundGirls", BackgroundGirls);
			script.interp.variables.set("WiggleEffect", WiggleEffect);
			script.interp.variables.set("FlxWaveEffect", FlxWaveEffect);
			script.interp.variables.set("FlxWaveMode", FlxWaveMode);
			script.interp.variables.set("TankmenBG", TankmenBG);
			script.interp.variables.set("BGSprite", BGSprite);

			// Shaders
			script.interp.variables.set("BuildingShaders", BuildingShaders);
			script.interp.variables.set("ColorSwap", ColorSwap);

			// sijdg
			script.interp.variables.set("curMod", ModLib.curMod);
			script.interp.variables.set("StrumNotes", StrumNotes);
		}

		// camFollow
		script.interp.variables.set("camFollow", camFollow);

		// Stage Layers
		script.interp.variables.set("stageLayer0", layer0); // Behind all
		script.interp.variables.set("stageLayer1", layer1); // In front of GF
		script.interp.variables.set("stageLayer2", layer2); // In front of Dad & Boyfriend.

		// Characters
		script.interp.variables.set("boyfriend", boyfriend);
		script.interp.variables.set("dad", dad);
		script.interp.variables.set("gf", gf);

		// Group of Characters
		script.interp.variables.set("boyfriendGroup", boyfriendGroup);
		script.interp.variables.set("dadGroup", dadGroup);
		script.interp.variables.set("gfGroup", gfGroup);

		// Cameras
		script.interp.variables.set("camHUD", camHUD);
		script.interp.variables.set("camGame", camGame);

		// Song Variables
		script.interp.variables.set("daPixelZoom", daPixelZoom);
		script.interp.variables.set("defaultCamZoom", defaultCamZoom);
		script.interp.variables.set("curSong", SONG.song);
		script.interp.variables.set("SONG", SONG);
		script.interp.variables.set("curStage", curStage);
		script.interp.variables.set("gfVersion", gfVersion);

		// Misc
		script.interp.variables.set("this", this);

		script.interp.variables.set("inCutscene", inCutscene);
		script.interp.variables.set("curBeat", curBeat);
		script.interp.variables.set("curStep", curStep);

		script.interp.variables.set("playerStrums", playerStrums);
		script.interp.variables.set("cpuStrums", cpuStrums);
		script.interp.variables.set("strumLines", strumLineNotes);

		script.interp.variables.set("replaceStrum", replaceArrows);

		script.interp.variables.set('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
		script.interp.variables.set('altAnim', SONG.notes[Math.floor(curStep / 16)].altAnim);
	}

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		trace(songPlaylist);

		if (SONG == null){
			if (songPlaylist == null || songPlaylist == [])
				SONG = Song.loadFromJson('test', 'test');
			else{
				SONG = Song.loadFromJson(SONG.song.toLowerCase(),SONG.song.toLowerCase());
				FlxG.log.warn('FORCED RELOAD');

				#if release
				trace('FORCED RELOAD');
				#end
			}
		}

		// i am so... so... so sorry.
		if (SONG.events != null){
			for (section in SONG.events){
				if (section != null){
					for (event in section.eventNotes){
						if (event != null)
							songEvents.push(event);
					}
				}
			}
		}

		if (songPlaylist[0] != null && storyWeek != songPlaylist[0].week)
			storyWeek = songPlaylist[0].week;
		if (songPlaylist[0] == null)
			trace('Playlist is null!! High risk of crash!');

		/*FlxG.sound.cache(Paths.inst(PlayState.SONG.song));
		FlxG.sound.cache(Paths.voices(PlayState.SONG.song));*/

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

		var modID:String = ModLib.getModID(ModLib.curMod);

		if (ModAssets.assetExists('data/charts/' + SONG.song.toLowerCase() + '/dialogue.json', null, modID, null)){
			dialogue = Json.parse(ModAssets.getContent('data/charts/' + SONG.song.toLowerCase() + '/dialogue.json', null, modID, null));
		}

		for (file in FileSystem.readDirectory(ModAssets.getPath("data/charts/" + SONG.song.toLowerCase() + "/", null, modID, null))){
			if (file != null && Path.extension(file).toLowerCase() == 'hx'){
				trace('Attempting to load script: $file');

				script.loadScriptFP(ModAssets.getPath("data/charts/" + SONG.song.toLowerCase() + "/" + file, null, modID));
			}
			else if (file == null){
				trace('File is null?! Cannot load script... if it even is a script.');
			}
		}

		for (file in FileSystem.readDirectory(ModAssets.getPath("data/scripts/", null, modID, null))){
			if (file != null && Path.extension(file).toLowerCase() == 'hx'){
				trace('Attempting to load script: $file');

				script.loadScriptFP(ModAssets.getPath("data/scripts/" + file, null, modID));
			}
			else if (file == null){
				trace('File is null?! Cannot load script... if it even is a script.');
			}
		}

		/*if (ModAssets.assetExists('data/charts/' + SONG.song.toLowerCase() + '/script.hx', null, modID, null)){
			script.loadScript('charts/' + SONG.song.toLowerCase(), 'script', modID);
		}*/

		// TEMPORARY!!!
		if (SONG.stage == null){
			switch (SONG.song.toLowerCase()){
				default:
					curStage = 'stage';
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'philly' | 'blammed':
					curStage = 'philly';
				case 'satin-panties' | 'high' | 'milf':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
			}
		}
		else{
			curStage = SONG.stage;
		}

		if (SONG.gfVersion == null){
			switch (curStage)
			{
				default:
					gfVersion = 'gf';
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
			}
		}
		else{
			gfVersion = SONG.gfVersion;
		}

		if (ModAssets.assetExists('data/stages/' + curStage.toLowerCase() + '/script.hx', null, modID, 'shared')){
			trace('Loading Custom Stage...');
			script.loadScript('stages/' + curStage.toLowerCase(), 'script', modID);
		}
		else{
			curStage = 'stage';
		}

		setScriptVar(false, script);

		script.call("onCreate"); // A lot of stuff here will not run or work properly.

		var stageData = ModAssets.getAsset('data/stages/' + curStage.toLowerCase() + '/data.json', modID, null, 'shared');
		var parsed:StageJSON = cast Json.parse(stageData);

		defaultCamZoom = parsed.defaultZoom != null ? parsed.defaultZoom : 1.05;

		gf = new Character(parsed.girlfriend[0], parsed.girlfriend[1], gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		if (parsed.spawnGirlfriend)
		    gfGroup.add(gf);

		switch (gfVersion)
		{
			case 'pico-speaker':
				gf.x -= 50;
				gf.y -= 200;
		}

		curDAD = (dad = new Character(parsed.dad[0], parsed.dad[1], SONG.player2));
		curDAD.ID = (dad.ID = 0);
		dadGroup.add(dad);

		curBF = (boyfriend = new Boyfriend(parsed.boyfriend[0], parsed.boyfriend[1], SONG.player1));
		curBF.ID = (boyfriend.ID = 0);
		boyfriendGroup.add(boyfriend);

		dad.setPosition(dad.x + dad.charJson.Position[0], dad.y + dad.charJson.Position[1]);
		boyfriend.setPosition(boyfriend.x + boyfriend.charJson.Position[0], boyfriend.y + boyfriend.charJson.Position[1]);

		if (dad.curCharacter == gf.curCharacter)
			gf.visible = false;

		add(layer0);

		if (parsed.spawnGirlfriend)
		    add(gfGroup);

		add(layer1);

		add(dadGroup);
		add(boyfriendGroup);

		add(layer2);

		// Characters
		script.interp.variables.set("boyfriend", boyfriend);
		script.interp.variables.set("dad", dad);
		script.interp.variables.set("gf", gf);

		if (dialogue != null){
			doof = new DialogueBox(false, dialogue);
			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
			doof.cameras = [camHUD];
			doof.finishThing = startCountdown;
		}

		Conductor.songPosition = -5000;

		var s:String = null;

		if (s == null){
			switch (SONG.song.toLowerCase()){
				case 'senpai' | 'roses' | 'thorns':
					s = 'pixel';
				default:
					s = '';
			}
		}
		else
			s = SONG.style;

		generateStaticArrows(s, PreferencesMenu.getPref('middle-scroll'), PreferencesMenu.getPref('downscroll'));
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

		healthBarBG = new FlxSprite(0, FlxG.height * 0.875).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		if (PreferencesMenu.getPref('downscroll'))
			healthBarBG.y = FlxG.height * 0.1;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthBarColors[0], dad.healthBarColors[1], dad.healthBarColors[2]),
			FlxColor.fromRGB(boyfriend.healthBarColors[0], boyfriend.healthBarColors[1], boyfriend.healthBarColors[2]));
		add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreTxt = new FlxText(0, healthBar.y + 32, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("PhantomMuff.ttf"), 24, FlxColor.WHITE, CENTER);
		scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		scoreTxt.antialiasing = true;
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		hitsTxt = new FlxText(0, 0, FlxG.width, "", 20);

		if (PreferencesMenu.getPref('downscroll'))
			hitsTxt.y = FlxG.height - (hitsTxt.height * 2);

		hitsTxt.setFormat(Paths.font("PhantomMuff.ttf"), 24, FlxColor.WHITE, CENTER);
		hitsTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		hitsTxt.antialiasing = true;
		hitsTxt.scrollFactor.set();
		add(hitsTxt);

		noteSplashGroup.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		hitsTxt.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (PreferencesMenu.getPref('cutscenes') == true){
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
		}
		else
			startCountdown();

		super.create();

		setScriptVar(true, script);
		script.call("createPost");

		#if discord_rpc
		rpcTimer.start(3 + FlxG.random.float(0, 2.5), function(timer:FlxTimer){
			var newText:String = 'Score: $songScore - Acc: ' + calculateRatingPercent() + '% - Miss: $songMisses';

			if (PreferencesMenu.getPref('botplay') == true)
				newText += ' - BOTPLAY';

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
				else{
					if (dialogue == null)
						startCountdown();
					else{
						dialogueBox = doof;
						add(dialogueBox);
					}
				}

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

			curBF.dance();
			curDAD.dance();

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
		var curSong:String = SONG.song;

		startingSong = false;

		previousFrameTime = FlxG.game.ticks;

		if (!paused){
			FlxG.sound.playMusic(inst, 1, false);

			vocals.play();
		}

		FlxG.sound.music.onComplete = endSong;

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

		inst = ModAssets.getSound('songs/${curSong.toLowerCase()}/Inst.$ext', null, ModLib.getModID(ModLib.curMod), null);

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(ModAssets.getSound('songs/${curSong.toLowerCase()}/Voices.$ext', null, ModLib.getModID(ModLib.curMod), null));
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

				if (songNotes[4] != null)
					swagNote.sangByCharID = songNotes[4];

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var finalSusLen:Int;

				if (FlxMath.roundDecimal(susLength, 1) - Math.round(susLength) >= 0.5)
					finalSusLen = Math.round(susLength) + 1;
				else
					finalSusLen = Math.round(susLength);

				for (susNote in 0...finalSusLen)
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, strum.arrows[daNoteData], noteStyle, false);
					sustainNote.sangByCharID = oldNote.sangByCharID;
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

	private function generateStaticArrows(style:String, ?midScroll:Bool = false, ?downscroll:Bool = false, ?dontGenCPU:Bool = false, ?skipTransition:Bool = false):Void
	{
		var pos:Float = (FlxG.width / 2);

		if (midScroll == true){
			dontGenCPU = true;
			pos = pos / 1.75;
		}

		var strumLine:Float = 65;

		if (downscroll)
			strumLine = FlxG.height - 165;

		cpuStrums = new StrumNotes(0, 0, strumLine, pos / 6, style, downscroll);

		if (!dontGenCPU){
			strumLineNotes.add(cpuStrums);
		}
		else{
			for (arrow in cpuStrums){
				arrow.visible = false;
			}
		}

		playerStrums = new StrumNotes(0, 0, strumLine, pos, style, downscroll);
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

		generateStaticArrows(style, false, false, dontGenCPU, skipTransition);

		// update the funny notes

		notes.forEach(function(note:Note){
			if (note.style != style)
				note.updateStyle(style);

			if (note.mustPress)
				note.updateTracker(playerStrums.arrows[note.noteData]);
			else{
				if (!dontGenCPU){
					note.updateTracker(cpuStrums.arrows[note.noteData]);
					note.hideBitch = false;
				}
				else
					note.hideBitch = true;
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
					note.hideBitch = false;
				}
				else
					note.hideBitch = true;
			}
		}

		if (skipTransition){
			for (strum in strumLineNotes){
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

			if (!FlxG.sound.music.playing)
				FlxG.sound.music.play();
		}

		super.closeSubState();
	}

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

	// putting this here so i don't have to scroll down LOL
	function performEvent(event:ChartEvent){
		if (event == null)
			trace('Event: $event seems to be null? Probably gonna crash LOL');

		switch (event.event.toLowerCase()){
			case 'setzoom':
				camZooming = true;

				if (event.variable1.toLowerCase() == 'game'){
					defaultCamZoom = Std.parseFloat(event.variable2);

					if (event.variable3.toLowerCase() == 'true')
						FlxG.camera.zoom = Std.parseFloat(event.variable2);
				}
				else if (event.variable1.toLowerCase() == 'hud'){
					defaultHudZoom = Std.parseFloat(event.variable2);

					if (event.variable3.toLowerCase() == 'true')
						camHUD.zoom = Std.parseFloat(event.variable2);
				}
			case 'beatzoom':
				camZooming = true;

				if (event.variable1.toLowerCase() == 'game')
					FlxG.camera.zoom += Std.parseFloat(event.variable2);
				else if (event.variable1.toLowerCase() == 'hud')
					camHUD.zoom += Std.parseFloat(event.variable2);
			case 'swapcharacter':
				switch(event.variable1.toLowerCase()){
					case 'dad':
						var newDad:Character = new Character(dad.x - dad.charJson.Position[0], dad.y - dad.charJson.Position[1], event.variable2);
						newDad.setPosition(newDad.x + newDad.charJson.Position[0], newDad.y + newDad.charJson.Position[1]);

						dad.kill();

						curDAD = (dad = newDad);
						dadGroup.add(dad);
					case 'bf' | 'boyfriend' | 'bluehaired bitch':
						var newBF:Boyfriend = new Boyfriend(boyfriend.x - boyfriend.charJson.Position[0], boyfriend.y - boyfriend.charJson.Position[1], event.variable2);
						newBF.setPosition(newBF.x + newBF.charJson.Position[0], newBF.y + newBF.charJson.Position[1]);

						boyfriend.kill();
						
						curBF = (boyfriend = newBF);
						
						boyfriendGroup.add(boyfriend);
				}
			case 'runscript':
				var eventScript:Hscript = new Hscript();

				var modID:String = '';

				if (event.variable2 != null && event.variable2 != '')
					modID = event.variable2;
				else if (ModLib.curMod != null)
					modID = ModLib.curMod.id;

				eventScript.loadScriptFP(ModAssets.getPath(event.variable1, null, modID, null, false));
				setScriptVar(false, eventScript);
				eventScript.call("event");
			case 'addcharacter':
				var bool:Bool = false;

				switch (event.variable2.toLowerCase()){
					case 'dad':
						bool = true;
					case 'bf' | 'boyfriend':
						bool = false;
				}

				addCharacter(event.variable1, Std.parseInt(event.variable3), bool, Std.parseFloat(event.variable4), Std.parseFloat(event.variable5));
			case 'deletecharacter':
				var bool:Bool = false;

				switch (event.variable2.toLowerCase()){
					case 'dad':
						bool = true;
					case 'bf' | 'boyfriend':
						bool = false;
				}

				removeCharacter(Std.parseInt(event.variable1), bool);
			case 'playanimcharid':
				var bool:Bool = false;

				switch (event.variable2.toLowerCase()){
					case 'dad':
						bool = true;
					case 'bf' | 'boyfriend':
						bool = false;
				}

				var character:Dynamic = getCharFromID(Std.parseInt(event.variable1), bool);
				character.playAnim(event.variable3);
			case 'playanimation':
				switch(event.variable1.toLowerCase()){
					case 'dad':
						dad.playAnim(event.variable2);
					case 'bf' | 'boyfriend':
						boyfriend.playAnim(event.variable2);
				}
			case 'selectcharacter':
				switch (event.variable2.toLowerCase()){
					case 'dad':
						curDAD = getCharFromID(Std.parseInt(event.variable1), true);
					case 'bf' | 'boyfriend':
						curBF = getCharFromID(Std.parseInt(event.variable1), false);
				}
		}
	}

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
					// trace('MISSED FRAME');
				}
			}
			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (!inCutscene && !paused && generatedMusic && FlxG.sound.music.playing){
			for (event in songEvents){
				if (Conductor.songPosition >= event.strumtime){
					// trace('$event was played at ${Conductor.songPosition} in song $curSong');
					performEvent(event);
					songEvents.remove(event);
				}
			}
		}

		setScriptVar(true, script);

		script.call("update", [elapsed]);

		super.update(elapsed);

		#if (windows||linux)
		textSpacer = '•';
		#else
		textSpacer = '-';
		#end

		// Timer looks ugly, gona make an actual bar one day. Might not though since having the timer kinda ruins shit for me personallly.
		scoreTxt.text = 'Score: $songScore $textSpacer Misses: $songMisses $textSpacer Combo: $combo\n' /*+
		'${(Math.floor((Conductor.songPosition / 1000) / 60))}:${(Math.floor((Conductor.songPosition / 1000) % 60) < 10 ? '0' : '') + Math.floor((Conductor.songPosition / 1000) % 60)}'.replace('\n', '')*/;

		if (!PreferencesMenu.getPref('downscroll'))
			hitsTxt.text = 'SHITS: $shits $textSpacer BADS: $bads $textSpacer GOODS: $goods $textSpacer SICKS: $sicks $textSpacer MINTS: $mints\nAccuracy: ' + funnyRatingText(calculateRatingPercent());
		else
			hitsTxt.text = 'Accuracy: ' + funnyRatingText(calculateRatingPercent()) + '\nSHITS: $shits $textSpacer BADS: $bads $textSpacer GOODS: $goods $textSpacer SICKS: $sicks $textSpacer MINTS: $mints';

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			var boyfriendPos = boyfriend.getScreenPosition();
			var pauseSubState = new PauseSubState(boyfriendPos.x, boyfriendPos.y);
			openSubState(pauseSubState);
			pauseSubState.camera = camHUD;
			boyfriendPos.put();
		}

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
			camHUD.zoom = FlxMath.lerp(defaultHudZoom, camHUD.zoom, 0.95);
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
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		if (!inCutscene && !_exiting)
		{
			// RESET = Quick Game Over Screen
			if (controls.RESET)
			{
				health = 0;
				trace("RESET = True");
			}

			#if CAN_CHEAT // brandon's a pussy
			if (controls.CHEAT)
			{
				health += 1;
				trace("User is cheating!");
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
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song);
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

				if ((daNote.strumTrack.isDownscroll && daNote.y < -daNote.height)
					|| (!daNote.strumTrack.isDownscroll && daNote.y > FlxG.height))
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

				if (daNote.strumTrack.isDownscroll)
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

					var cID = daNote.sangByCharID;

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							getCharFromID(cID, true).playAnim('singLEFT' + altAnim, true);
						case 1:
							getCharFromID(cID, true).playAnim('singDOWN' + altAnim, true);
						case 2:
							getCharFromID(cID, true).playAnim('singUP' + altAnim, true);
						case 3:
							getCharFromID(cID, true).playAnim('singRIGHT' + altAnim, true);
					}

					// if (!daNote.isSustainNote && !daNote.hideBitch){
						// spawnNoteSplash(daNote.noteData);
					// }

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

					curDAD.holdTimer = 0;

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

					++songMisses;

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

		if (!inCutscene){
			keyShit();
		}

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
				trace('Continuing');
			case 'stress':
				playCutscene('kickstarterTrailer', true);
				return;
			case 'eggnog':
				var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
					-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				blackShit.scrollFactor.set();
				add(blackShit);
				camHUD.visible = false;
	
				FlxG.sound.play(Paths.sound('Lights_Shut_off'));
		}

		songPlaylist.remove(songPlaylist[0]);

		if (songPlaylist.length <= 0){
			songPlaylist = []; // reset the playlist lol

			if (!inLoopMode){
				DiscordClient.changePresence('In the Menus', null);

				ModLib.setMod(null, false);

				FlxG.sound.music.stop();
				FlxG.switchState(new FreeplayState());

				return;
			}
			else{
				for (song in FreeplayState.loopList){
					songPlaylist.push(song);
				}

				if (songPlaylist[0].mod != null)
					ModLib.setMod(songPlaylist[0].mod.id, false);

				PlayState.storyWeek = songPlaylist[0].week;
				
				DiscordClient.changePresence('Loading...', null);
				PlayState.SONG = Song.loadFromJson(songPlaylist[0].songName.toLowerCase(), songPlaylist[0].songName);
			}
		}
		else{
			PlayState.storyWeek = songPlaylist[0].week;

			trace('LOADING NEXT SONG');

			if (songPlaylist[0].mod != null)
				ModLib.setMod(songPlaylist[0].mod.id, false);

			PlayState.SONG = Song.loadFromJson(songPlaylist[0].songName.toLowerCase(), songPlaylist[0].songName);
			
			FlxG.sound.music.stop();

			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			prevCamFollow = camFollow;
			
		}

		DiscordClient.changePresence('Loading...', null);
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

		var daRating:String = "mint";

		if (noteDiff > Conductor.safeZoneOffset * 0.55)
		{
			daRating = 'shit';
			score = 50;
			++shits;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.375)
		{
			daRating = 'bad';
			score = 100;
			++bads;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
			++goods;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.05){
			spawnNoteSplash(daNote.noteData);
			daRating = 'sick';
			score = 350;
			++sicks;
		}
		else{
			spawnNoteSplash(daNote.noteData);
			++mints;
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
		var library:String = null;

		if (SONG.style == 'pixel' || curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
			library = 'week6';
		}

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2, library));
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
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2, library));
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
			dadCamGoofy_X = (curDAD.getMidpoint().x + 150) + curDAD.charJson.CamPosition[0];
			dadCamGoofy_Y = (curDAD.getMidpoint().y - 100) + curDAD.charJson.CamPosition[1];

			dadNeedsCamUpdate == false;
		}

		if (bfNeedsCamUpdate){
			bfCamGoofy_X = (curBF.getMidpoint().x - 100) + curBF.charJson.CamPosition[0];
			bfCamGoofy_Y = (curBF.getMidpoint().y - 100) + curBF.charJson.CamPosition[1];

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
			curBF.holdTimer = 0;

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

		for (bf in boyfriendGroup){
			if (bf.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true))
			{
				if (bf.animation.curAnim.name.startsWith('sing') && !bf.animation.curAnim.name.endsWith('miss'))
				{
					bf.playAnim('idle');
				}
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
		++songMisses;
		killCombo();

		if (!practiceMode)
			songScore -= 10;

		vocals.volume = 0;
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		switch (direction)
		{
			case 0:
				curBF.playAnim('singLEFTmiss', true);
			case 1:
				curBF.playAnim('singDOWNmiss', true);
			case 2:
				curBF.playAnim('singUPmiss', true);
			case 3:
				curBF.playAnim('singRIGHTmiss', true);
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
				++songHits;
				popUpScore(note.strumTime, note);
			}

			if (note.noteData >= 0)
				health += 0.05;
			else
				health += 0.005;

			var cID:Int = note.sangByCharID;

			switch (note.noteData)
			{
				case 0:
					getCharFromID(cID, false).playAnim('singLEFT', true);
				case 1:
					getCharFromID(cID, false).playAnim('singDOWN', true);
				case 2:
					getCharFromID(cID, false).playAnim('singUP', true);
				case 3:
					getCharFromID(cID, false).playAnim('singRIGHT', true);
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

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		for (gf in gfGroup){
			if (curBeat % gfSpeed == 0 && (gf.isDancing() || !gf.isDancing() && gf.animation.curAnim.finished))
				gf.dance();
		}

		for (boyfriend in boyfriendGroup){
			if (boyfriend.isDancing() || !boyfriend.isDancing() && !boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.animation.curAnim.finished 
				|| perfectMode && boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.animation.curAnim.finished)
			{
				boyfriend.dance();
			}
		}

		for (dad in dadGroup){
			if (dad.isDancing() || !dad.isDancing() && !dad.animation.curAnim.name.startsWith("sing") && dad.animation.curAnim.finished)
			{
				dad.dance();
			}
		}
		
		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			curBF.playAnim('hey', true);
		}
		
		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && curDAD.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			curDAD.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}
	}

	function calculateRatingPercent():Float{
		var ratingPercent = songScore / ((songHits + songMisses) * 350);

		if(!Math.isNaN(ratingPercent) && ratingPercent < 0)
			ratingPercent = 0;

		var rPercent:Float = FlxMath.roundDecimal(ratingPercent * 100, 2);

		if (Math.isNaN(rPercent))
			return -1;
		else
			return rPercent;
	}

	function funnyRatingText(ratingPercent:Float):String{
		var validRatings:Array<Dynamic> = [
			['SICK!!!', 100],
			['SICK!!', 95],
			['SICK!', 90],
			['GOOD!!!', 85],
			['GOOD!!', 70],
			['GOOD!', 65],
			['BAD!', 55],
			['BAD!!', 45],
			['BAD!!!', 40],
			['SHIT!', 35],
			['SHIT!!', 25],
			['SHIT!!!', 15],
			['SHIT!!!', 0]
		];

		if (ratingPercent != -1){
			for (i in 0...validRatings.length){
				if (validRatings[i + 1] != null && (ratingPercent > validRatings[i + 1][1] && ratingPercent <= validRatings[i][1]) || 
				validRatings[i + 1] == null && ratingPercent <= validRatings[i][1]){
					return '$ratingPercent% (' + validRatings[i][0] + ')';
				}
			}
		}

		return 'N/A';
	}

	function playCutscene(name:String, atEndOfSong:Bool = false, ?midSong:Bool = false)
	{	
		if (PreferencesMenu.getPref('vidscene') == true){
			var tVol:Float = 0;

			inCutscene = true;

			if (!midSong)
				FlxG.sound.music.stop();
			else
				FlxG.sound.music.volume = 0;
	
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
				else if (!midSong)
					startCountdown();
				else
					FlxG.sound.music.volume = 1;
			}
	
			video.playVideo(Paths.video(name));
			
			if (FlxG.sound.volume < 0.5)
				FlxG.sound.volume = 0.5;
		}
		else{
			trace('Attempted to play cutscene while cutscenes were disabled.');
			
			if (atEndOfSong == true){
				PlayState.SONG = Song.loadFromJson(songPlaylist[0].songName.toLowerCase(), songPlaylist[0].songName);
				LoadingState.loadAndSwitchState(new PlayState(), false);
			}
			else if (!midSong)
				startCountdown();
			else
				trace('Cutscene not allowed to be played.');
		}
	}

	function getCharFromID(id:Int, isDad:Bool = false){
		var group:FlxTypedGroup<Dynamic> = boyfriendGroup;

		if (isDad)
			group = dadGroup;

		for (character in group){
			if (character.ID == id && character != null)
				return character;
		}

		try{
			trace('Unable to find character of ID "$id" in group ${if (isDad == true) return "dadGroup"; else return "boyfriendGroup";}');
		}
		catch(e:Dynamic){
			trace('If you see this, my trace for saying "Unable to find character of ID" didn\'t work properly, and gave the error of "$e". Please report this to me immediatly.');
		}

		return 0;
	}

	public inline function spawnNoteSplash(noteData:Int) {
		var staticNote:FlxSprite = playerStrums.members[noteData];
		createNoteSplash(staticNote.x, staticNote.y, noteData);
	}

	public inline function createNoteSplash(x:Float, y:Float, noteData:Int) {
		var splash:NoteSplash = new NoteSplash(x, y, noteData);
		noteSplashGroup.add(splash);
	}
 
	/**
	 * Adds another Character to the stage
	 * @param charName Character Name
	 * @param charID ID of Character
	 * @param isDad Is the Character the opponent?
	 * @param xOff X Offset
	 * @param yOff Y Offset
	 */
	function addCharacter(charName:String, charID:Int = 0, isDad = false, xOff:Float, yOff:Float){
		if (isDad){
			var character = new Character(dad.x + xOff, dad.y + yOff, charName);
			character.ID = charID;
			dadGroup.add(character);
		}
		else{
			var character = new Boyfriend(boyfriend.x + xOff, boyfriend.y + yOff, charName);
			character.ID = charID;
			boyfriendGroup.add(character);
		}
	}

	/**
	 * Removes a character
	 * @param charID ID of Character
	 * @param isDad Is the opponent?
	 */
	function removeCharacter(charID:Int = 0, isDad:Bool = false){
		var character:Dynamic = getCharFromID(charID, isDad);

		if (isDad){
			if (curDAD == character){
				if (character == dad)
					trace('Yo uh, we are 100% about to crash. You are trying to remove what is most likely the default character.');
				else
					curDAD = dad;
			}
		}
		else{
			if (curBF == character){
				if (character == boyfriend)
					trace('Yo uh, we are 100% about to crash. You are trying to remove what is most likely the default character.');
				else
					curBF = boyfriend;
			}
		}

		character.kill();

		if (isDad){
			dadGroup.remove(character, true);
		}
		else{
			boyfriendGroup.remove(character, true);
		}

		character.destroy(); // Don't leave anything left >:3
	}
}

typedef SongData = {
	var songName:String;
	var ?week:Int;
	var ?mod:Mod;
}
