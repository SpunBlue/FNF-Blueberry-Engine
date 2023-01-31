package game;

import Note.NoteActions;
import Note.NoteJson;
import engine.modding.Hscript;
import DialogueBox.DialogueShitJson;
import sys.FileSystem;
import Song.Events;
import engine.OptionsData;
import engine.Engine;
import sys.io.File;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.math.FlxRandom;
import engine.modding.Stages;
import engine.modding.Modding;
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
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
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
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

#if desktop
import Discord.DiscordClient;
#end

#if (hxCodec <= "2.5.1")
import vlc.MP4Handler;
#else
import hxcodec.VideoHandler;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var storyWeek:Int = 0;
	public static var songPlaylist:Array<SongData> = [];
	public static var isValidWeek:Bool = true;
	public static var inShuffleMode:Bool = true;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;
	private var vocals2:FlxSound;
	private var inst:FlxSoundAsset;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<FlxSprite>;
	public var playerStrums:FlxTypedGroup<FlxSprite>;
	public var dadStrums:FlxTypedGroup<FlxSprite>;

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

	var dialogue:DialogueShitJson;

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var evilTrail:FlxTrail;

	public var talking:Bool = true;
	public var songScore:Int = 0;
	public var scoreTxt:FlxText;

	public static var boyfriendGroup:FlxTypedGroup<Boyfriend> = new FlxTypedGroup();
	public static var dadGroup:FlxTypedGroup<Character> = new FlxTypedGroup();
	public static var gfGroup:FlxTypedGroup<Character> = new FlxTypedGroup();

	public var layer0:FlxTypedGroup<StageObject> = new FlxTypedGroup();
	public var layer1:FlxTypedGroup<StageObject> = new FlxTypedGroup();
	public var layer2:FlxTypedGroup<StageObject> = new FlxTypedGroup();

	public static var script = new Hscript();

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05;
	public var defaultHudZoom:Float = 1;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	public var inCutscene:Bool = false;

	public var shits:Int = 0;
	public var bads:Int = 0;
	public var goods:Int = 0;
	public var sicks:Int = 0;

	public var songHits:Int = 0;
	public var songMisses:Int = 0;

	var daDRPCText:String = 'hi';

	public var songScrollSpeed:Float = 1;

	private var midScrollOffset:Int = -280;

	var isSingle:Bool = false;

	// Why did I put this here?
	public static var validEvents:Array<Dynamic> = [
		["None", "Variable 1", "Variable 2", "Variable 3", "Variable 4", "Variable 5", "Information"],
		["deleteCharacter", "'bf' or 'dad'?", "Character ID (0 is default)", "", "", "", 'Delete a Character of an specific ID.\nWill crash if no characters left avaliable.\n'],
		["addCharacter", "'bf' or 'dad'?", "New Character", "Character ID", "X Offset", "Y Offset", "Add a Character and set as the current Character."],
		["replaceGF", "New Character", "X Offset", "Y Offset", "", "", "Replaces the current Girlfriend with a new one."],
		["singAsCharacter", "'bf' Group or 'dad' Group?", "Character ID", "", "", "", "Set current Character to specified ID."],
		["playAnimation", "'bf' Group, 'dad' Group or 'gf'?", "Character ID", "Animation Name", "", "", "Play Animation on Character with specific ID"],
		["Zoom", "Lerp Value? 'true' or 'false'", "Which Camera? 'game' or 'hud'", "Zoom Amount", "", "", "Zooms Camera to specified value.\nLerp will make the Camera do the Zoom In/Out effect.\nZoom Amount adds on to the current value. This number can be negative or positive."]
	];
	var songEvents:Array<Events> = [];

	var selectedDad:Int = 0;
	var selectedGF:Int = 0;
	var selectedBF:Int = 0;

	var doof:DialogueBox;

	public static var perfectMode:Bool = false;

	override public function create()
	{	
		instance = this;

		perfectMode = OptionsData.botplay;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (songPlaylist.length <= 1){
			Engine.debugPrint('In single mode!');
			isSingle = true;
		}

		if (FileSystem.exists(Modding.getFilePath(SONG.song.toLowerCase() + '.hx', "scripts/"))){
		    script.loadScript(SONG.song.toLowerCase(), true);
		}

		if (Assets.exists(Paths.hx("scripts/" + SONG.song.toLowerCase()))){
		    script.loadScript("scripts/" + SONG.song.toLowerCase(), false);
		}

		script.interp.variables.set("camFollow",camFollow);
		script.call('create');

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame]; //stfu

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		if (SONG.events != null){
			for (event in SONG.events){ // For some reason if I made songEvents = SONG.events it will manipulate SONG.events even though I specified "songEvents"
				if (event != null)
					songEvents.push(event);
			}
		}

		if (songPlaylist[0].modID == null){
			Modding.modLoaded = false;
			Engine.debugPrint('no mod loaded L');
		}

		if (SONG.needsVoices){
			if (SONG.seperatedVocalTracks == false || SONG.seperatedVocalTracks == null){
				if (Modding.modLoaded){
					vocals = new FlxSound().loadEmbedded(Modding.retrieveAudio('Voices', 'songs/' + PlayState.SONG.song));
					vocals2 = new FlxSound();
				}
				else{
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
					vocals2 = new FlxSound();
				}
			}
			else if(SONG.seperatedVocalTracks){
				if (Modding.modLoaded){
					vocals = new FlxSound().loadEmbedded(Modding.retrieveAudio('Voices-BF', 'songs/' + PlayState.SONG.song));
					vocals2 = new FlxSound().loadEmbedded(Modding.retrieveAudio('Voices-DAD', 'songs/' + PlayState.SONG.song));
				}
				else{
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, '-BF'));
					vocals2 = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, '-DAD'));
				}
			}
		}
		else{
			vocals = new FlxSound();
			vocals2 = new FlxSound();
		}

		if (Modding.modLoaded)
			inst = Modding.retrieveAudio('Inst', 'songs/' + PlayState.SONG.song);
		else
			inst = Paths.inst(PlayState.SONG.song);

		Engine.debugPrint(inst);

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (songScrollSpeed != PlayState.SONG.speed)
			songScrollSpeed = PlayState.SONG.speed;

		if (FileSystem.exists('assets/data/charts/' + SONG.song.toLowerCase() + '/dialogue.json')){
			dialogue = Json.parse(File.getContent('assets/data/charts/' + SONG.song.toLowerCase() + '/dialogue.json'));
		}
		else if (Modding.modLoaded && FileSystem.exists(Modding.getFilePath("dialogue.json", "data/charts/" + SONG.song.toLowerCase()))){
			dialogue = Json.parse(Modding.retrieveContent("dialogue.json", "data/charts/" + SONG.song.toLowerCase()));
		}

		if (storyWeek == 6)
			FlxSprite.defaultAntialiasing = false;

		#if desktop
		DiscordClient.changePresence("Playing " + SONG.song.toUpperCase(), null);
		#end

		if (SONG.stage == null){
			switch (SONG.song.toLowerCase()) // I ain't modifying every chart damn it.
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
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
				default:
					curStage = 'stage';
			}
		}
		else{
			curStage = SONG.stage;
		}

		var isCustomStage:Bool = true;
		var fnfStageList:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));

		if (SONG.stage != null && SONG.stage.toLowerCase() != 'stage'){
			for (stage in fnfStageList){
				if (SONG.stage.toLowerCase() == stage.toLowerCase()){
					isCustomStage = false;
					break;
				}
			}
		}
		else{
			Engine.debugPrint('Stage is null or is equal to "stage"');
			isCustomStage = false;
		}

		if (!isCustomStage){
			switch (curStage)
			{
				default:
					defaultCamZoom = 0.9;
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);
				case 'spooky':
					var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

					halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = true;
					add(halloweenBG);

					isHalloween = true;
					halloweenLevel = true;
				case 'philly':
					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					phillyCityLights = new FlxTypedGroup<FlxSprite>();
					add(phillyCityLights);

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = true;
						phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
					add(streetBehind);

					phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
					add(phillyTrain);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
					add(street);
				case 'limo':
					defaultCamZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
					skyBG.scrollFactor.set(0.1, 0.1);
					add(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
					overlayShit.alpha = 0.5;

					var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');

					limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = true;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
				case 'mall':
					defaultCamZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = true;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
					bgEscalator.antialiasing = true;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
					tree.antialiasing = true;
					tree.scrollFactor.set(0.40, 0.40);
					add(tree);

					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = true;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					add(bottomBoppers);

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
					fgSnow.active = false;
					fgSnow.antialiasing = true;
					add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = true;
					add(santa);
				case 'mallEvil':
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
					evilTree.antialiasing = true;
					evilTree.scrollFactor.set(0.2, 0.2);
					add(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
					evilSnow.antialiasing = true;
					add(evilSnow);
				case 'school':
					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					add(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (SONG.song.toLowerCase() == 'roses')
					{
							bgGirls.getScared();
					}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				case 'schoolEvil':
					var bg:FlxSprite = new FlxSprite(400, 200);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);
			}
		}
		else{ // Todo: Add support for Non-modded JSON Stages.
			var stagelol = engine.modding.Stages;

			stagelol.init(SONG.stage);

			var stageArray:Array<StageObj> = Stages.stageArray;

			var stageDebug:Bool = true;

			curStage = stagelol.stageName;
			FlxSprite.defaultAntialiasing = !stagelol.stageJson.disableAntialiasing;

			if (stagelol.stageJson.camZoom != null && stagelol.stageJson.camZoom > 0)
				defaultCamZoom = stagelol.stageJson.camZoom;

			for (object in stageArray){
				if (object != null){
					var stageObject:StageObject = new StageObject(object.position[0], object.position[1], object);

					stageObject.scrollFactor.set(object.scrollFactor[0], object.scrollFactor[1]);

					if (object.loop == null)
						object.loop = false;

					if (object.xmlPath == null || object.xmlPath == '')
						stageObject.loadGraphic(Modding.retrieveImage(object.image, '', 'StageIMGASSET'));
					else
						stageObject.frames = FlxAtlasFrames.fromSparrow(Modding.retrieveImage(object.image, '', 'StageIMGASSET'),
					File.getContent('mods/' + Modding.curLoaded + '/images/' + object.xmlPath));

					if (object.size != null)
						stageObject.setGraphicSize(Std.int(stageObject.width * object.size));

					if (object.blend != null)
						stageObject.blend = CoolUtil.returnBlendMode(object.blend);

					if (object.scale != null)
					{
						stageObject.scale.x = object.scale[0];
						stageObject.scale.y = object.scale[1];
					}

					if (object.antialiasing != null)
						stageObject.antialiasing = object.antialiasing;

					stageObject.alpha = object.alpha;
					stageObject.flipX = object.flipX;
					stageObject.flipY = object.flipY;

					if (object.isAnimated){
						if (object.indices == null)
							stageObject.animation.addByPrefix(object.name, object.xmlanim, object.fps, object.loop);
						else{
							stageObject.animation.addByIndices(object.name, object.xmlanim, object.indices, "", object.fps, object.loop);

							if (stageDebug)
								Engine.debugPrint('Added animation by Indices in ' + object.name);
						}
					}
					
					switch(object.layer){
						case 0:
							layer0.add(stageObject);
						case 1:
							layer1.add(stageObject);
						case 2:
							layer2.add(stageObject);
						default:
							layer0.add(stageObject);
					}

					if (object.isAnimated)
						stageObject.animation.play(object.name, true);
				}
			}
		}

		if (FileSystem.exists(Modding.getFilePath(curStage + '.hx', "data/stages/"))){
		    script.loadScriptStage(curStage, true);
		}

		if (Assets.exists(Paths.hx("data/stages/" + curStage))){
		    script.loadScriptStage("data/stages/" + curStage, false);
		}

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		if (!dad.isModded){
			switch (SONG.player2)
			{
				case 'gf':
					dad.setPosition(gf.x, gf.y);
					gf.visible = false;

					camPos.x += 600;
					tweenCamIn();
				case "spooky":
					dad.y += 200;
				case "monster":
					dad.y += 100;
				case 'monster-christmas':
					dad.y += 50;
				case 'dad':
					camPos.x += 400;
				case 'pico':
					camPos.x += 600;
					dad.y += 300;
				case 'parents-christmas':
					dad.x -= 500;
				case 'senpai':
					dad.x += 150;
					dad.y += 360;
					camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
				case 'senpai-angry':
					dad.x += 150;
					dad.y += 360;
					camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
				case 'spirit':
					dad.x -= 150;
					dad.y += 100;
					camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);

					evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				case 'tankman':
					dad.y += 150;
			}
		}
		else if (dad.jsonData.position != null){
			dad.x += dad.jsonData.position[0];
			dad.y += dad.jsonData.position[1];
		}

		if (SONG.song.toLowerCase() != 'stress')
			boyfriend = new Boyfriend(770, 450, SONG.player1);
		else{
			Engine.debugPrint('Character forced to default BF because i am too lazy to modify the chart');
			boyfriend = new Boyfriend(770, 450, 'bf');
		}

		// REPOSITIONING PER STAGE
		if (boyfriend.isModded && boyfriend.jsonData.position != null){
			boyfriend.x += boyfriend.jsonData.position[0];
			boyfriend.y += boyfriend.jsonData.position[1];
		}

		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;
			case 'mall' | 'mallEvil':
				boyfriend.x += 200;
			case 'school' | 'schoolEvil':
				boyfriend.x += 200;
				boyfriend.y += 220;
		}

		switch(gfVersion){
			case 'gf-pixel':
				gf.x += 180;
				gf.y += 300;
		}

		add(layer0);

		gf.ID = 0;
		gfGroup.add(gf);
		add(gfGroup);

		add(layer1);

		// Lol
		if (curStage == 'schoolEvil')
			add(evilTrail);
		else if (curStage == 'limo')
			add(limo);

		dad.ID = 0;
		dadGroup.add(dad);
		add(dadGroup);

		boyfriend.ID = 0;
		boyfriendGroup.add(boyfriend);
		add(boyfriendGroup);

		add(layer2);

		if (Stages.stageJson != null){
			if (Stages.stageJson.bfPosition != null && Stages.stageJson.bfPosition != []){
				boyfriendGroup.members[selectedBF].x = Stages.stageJson.bfPosition[0];
				boyfriendGroup.members[selectedBF].y = Stages.stageJson.bfPosition[1];
			}
	
			if (Stages.stageJson.gfPosition != null && Stages.stageJson.gfPosition != []){
				gfGroup.members[selectedGF].x = Stages.stageJson.gfPosition[0];
				gfGroup.members[selectedGF].y = Stages.stageJson.gfPosition[1];
			}
	
			if (Stages.stageJson.dadPosition != null && Stages.stageJson.dadPosition != []){
				dadGroup.members[selectedDad].x = Stages.stageJson.dadPosition[0];
				dadGroup.members[selectedDad].y = Stages.stageJson.dadPosition[1];
			}
		}
	
		if (dialogue != null){
			doof = new DialogueBox(false, dialogue);
			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
			doof.cameras = [camHUD];
			doof.finishThing = startCountdown;
		}

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		if (engine.OptionsData.downScroll)
			strumLine.y = FlxG.height - 130;
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		dadStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

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

		healthBarBG = new FlxSprite(0, engine.OptionsData.downScroll == false ? FlxG.height * 0.9 : 50).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		var barColor:FlxColor = 0xFFFF0000;
		var barColor2:FlxColor = 0xFF66FF33;

		for (color in CoolUtil.coolTextFile(Paths.txt('healthColors'))) {
			if (!color.startsWith('#')) {
				var eugh = color.split(':');

				if (dadGroup.members[selectedDad].curCharacter.toLowerCase().startsWith(eugh[0])) {
					barColor = new FlxColor(Std.parseInt(eugh[1]));
				}
				if (boyfriendGroup.members[selectedBF].curCharacter.toLowerCase().startsWith(eugh[0])) {
					barColor2 = new FlxColor(Std.parseInt(eugh[1]));
				}
			}
		}

		if (dadGroup.members[selectedDad].jsonCharacter && dadGroup.members[selectedDad].jsonData.healthColor != null)
			barColor = new FlxColor(Std.parseInt(dadGroup.members[selectedDad].jsonData.healthColor));
		if (boyfriendGroup.members[selectedBF].jsonCharacter && boyfriendGroup.members[selectedBF].jsonData.healthColor != null)
			barColor2 = new FlxColor(Std.parseInt(boyfriendGroup.members[selectedBF].jsonData.healthColor));

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(barColor,barColor2);
		// healthBar
		add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreTxt = new FlxText(0, healthBar.y + 24, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("PhantomMuff.ttf"), 24, FlxColor.WHITE, CENTER);
		scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		scoreTxt.antialiasing = true;
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

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
			case 'senpai':
				schoolIntro(doof);
			case 'roses':
				FlxG.sound.play(Paths.sound('ANGRY'));
				schoolIntro(doof);
			case 'thorns':
				schoolIntro(doof);
			default:
				if (FileSystem.exists(Paths.video(SONG.introVideo)))
					playCutscene(Paths.video(SONG.introVideo));
				else if (FileSystem.exists(Modding.getFilePath(SONG.introVideo + '.mp4', "videos/"))){
					playCutscene(Modding.getFilePath(SONG.introVideo + '.mp4', "videos/"));
				}
				else{
					if (dialogue != null){
						add(doof);
					}
					else
						startCountdown();
				}
				if (FileSystem.exists(Modding.getFilePath(SONG.song.toLowerCase() + '.hx', "scripts/cutscenes/"))){
					script.loadScript("cutscenes/" + SONG.song.toLowerCase(), true);
				}
				if (Assets.exists(Paths.hx("scripts/cutscenes/" + SONG.song.toLowerCase()))){
					script.loadScript("scripts/cutscenes/" + SONG.song.toLowerCase(), false);
				}
		}

		var events:Array<Events> = [];

		if (Modding.modLoaded){
			if (FileSystem.exists(Modding.getFilePath('startupEvents.json', 'data/charts/' + SONG.song.toLowerCase()))){
				var json = Json.parse(Modding.retrieveContent('startupEvents.json', 'data/charts/' + SONG.song.toLowerCase()));
				events = json.events;
			}
		}
		else{
			if (FileSystem.exists(Paths.json('charts/' + SONG.song.toLowerCase() +  'startupEvents.json'))){
				var json = Json.parse(Paths.json('charts/' + SONG.song.toLowerCase() +  'startupEvents.json'));
				events = json.events;
			}
		}

		for (event in events){
			if (event != null)
				performEvent(event);
		}

		super.create();

		script.call("createPost");
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
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
							{
								swagTimer.reset();
							}
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
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;

	function startCountdown():Void
	{
		inCutscene = false;

		if (!engine.OptionsData.middleScroll)
			generateStaticArrows(0);

		generateStaticArrows(1);

		// middle scroll offset
		if (engine.OptionsData.middleScroll){
			for (strumArrow in playerStrums){
				if (strumArrow != null)
					strumArrow.x += midScrollOffset;
			}
		}

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

        script.call('startCountdown');

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dadGroup.members[selectedDad].dance();
			gfGroup.members[selectedGF].dance();
			boyfriendGroup.members[selectedBF].dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

        script.call('startSong');

		if (!paused){
			FlxG.sound.playMusic(inst, 1, false);
		}

		FlxG.sound.music.onComplete = forceEndSong;
		vocals.play();
		vocals2.play();
	}

	private function forceEndSong():Void{
		endSong();
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(vocals2);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var singer:Int = -1;

				if (songNotes[3] != null)
					singer = songNotes[3];

				var typelol:String = "";

				if (songNotes[4] != null)
					typelol = songNotes[4];

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, singer, typelol);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var noteOffset:Int = 0;

				if (engine.OptionsData.middleScroll)
					noteOffset = midScrollOffset;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					

					if (sustainNote.mustPress)
					{
						sustainNote.x += (FlxG.width / 2) + noteOffset; // general offset
					}
					else {
						sustainNote.x += (98) + noteOffset;

						if (engine.OptionsData.middleScroll)
							sustainNote.alpha = 0;
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += (FlxG.width / 2) + noteOffset; // general offset
				}
				else {
					swagNote.x += (98) + noteOffset;

					if (engine.OptionsData.middleScroll)
						swagNote.alpha = 0;
				}
			}
			daBeats += 1;
		}

		// Engine.debugPrint(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					dadStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (player == 0)
				babyArrow.x += 98;

			dadStrums.forEach(function(spr:FlxSprite)
			{					
				spr.centerOffsets(); //CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);

			script.call('generateStaticArrows', [player]);
			script.interp.variables.set("babyArrow",babyArrow);
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
				vocals2.pause();
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
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();
		vocals2.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;

		vocals.time = Conductor.songPosition;
		vocals2.time = Conductor.songPosition;

		vocals.play();
		vocals2.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		script.call("update", [elapsed]);

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}
		
		// Event Runner
		if (songEvents != null){
			for (event in songEvents){
				if (event != null){
					if (!paused && !inCutscene && generatedMusic && FlxG.sound.music.playing && Conductor.songPosition >= event.ms){
						performEvent(event);
		
						songEvents.remove(event);

						Engine.debugPrint('' + event + ' has been Played');
					}
				}
				else{
					Engine.debugPrint('' + event + ' is Null!');
				}
			}
		}

		super.update(elapsed);
		
		var textSpacer:String = '•';

		#if (windows||linux)
		textSpacer = '•';
		#else
		textSpacer = '-';
		#end

		scoreTxt.text = 'Score: $songScore $textSpacer Accuracy: ' + calculateRatingPercent() + ' $textSpacer Misses: $songMisses $textSpacer Combo: $combo';

		#if desktop
		var newText:String = 'Score: $songScore - Accuracy: ' + calculateRatingPercent() + ' - Misses: $songMisses - Combo: $combo';

		if (daDRPCText != newText){
			DiscordClient.changePresence("Playing " + SONG.song.toUpperCase() + '  |  ' + newText, null);
			daDRPCText = newText;
		}
		#end

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
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
				openSubState(new PauseSubState(boyfriendGroup.members[selectedBF].getScreenPosition().x, boyfriendGroup.members[selectedBF].getScreenPosition().y));
		}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

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
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

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

		// dad cam follow shit
		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// Engine.debugPrint(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dadGroup.members[selectedDad].getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dadGroup.members[selectedDad].getMidpoint().x + 150, dadGroup.members[selectedDad].getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);
				
				if (!dadGroup.members[selectedDad].isModded){
					switch (dadGroup.members[selectedDad].curCharacter)
					{
						case 'mom':
							camFollow.y = dadGroup.members[selectedDad].getMidpoint().y;
						case 'senpai':
							camFollow.y = dadGroup.members[selectedDad].getMidpoint().y - 430;
							camFollow.x = dadGroup.members[selectedDad].getMidpoint().x - 100;
						case 'senpai-angry':
							camFollow.y = dadGroup.members[selectedDad].getMidpoint().y - 430;
							camFollow.x = dadGroup.members[selectedDad].getMidpoint().x - 100;
					}
				}
				else if(dadGroup.members[selectedDad].jsonData.cameraPosition != null){
					camFollow.x += dadGroup.members[selectedDad].jsonData.cameraPosition[0];
					camFollow.y += dadGroup.members[selectedDad].jsonData.cameraPosition[1];
				}

				/*if (dadGroup.members[selectedDad].curCharacter == 'mom')
					vocals.volume = 1;*/

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriendGroup.members[selectedBF].getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriendGroup.members[selectedBF].getMidpoint().x - 100, boyfriendGroup.members[selectedBF].getMidpoint().y - 100);

				if (!boyfriendGroup.members[selectedBF].isModded){
					switch (SONG.player1)
					{
						case 'bf-car':
							camFollow.x = boyfriendGroup.members[selectedBF].getMidpoint().x - 300;
						case 'bf-christmas':
							camFollow.y = boyfriendGroup.members[selectedBF].getMidpoint().y - 200;
						case 'bf-pixel':
							camFollow.x = boyfriendGroup.members[selectedBF].getMidpoint().x - 200;
							camFollow.y = boyfriendGroup.members[selectedBF].getMidpoint().y - 200;
					}
				}
				else if(boyfriendGroup.members[selectedBF].jsonData.cameraPosition != null){
					camFollow.x = boyfriendGroup.members[selectedBF].jsonData.cameraPosition[0];
					camFollow.y = boyfriendGroup.members[selectedBF].jsonData.cameraPosition[1];
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
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
					vocals2.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		if (health <= 0)
		{
			triggerGameOver();
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				// note interpolation
				if (engine.OptionsData.downScroll == false)
					daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * songScrollSpeed));
				else
					daNote.y = (strumLine.y + (songTime - daNote.strumTime) * (0.45 * songScrollSpeed));

				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!engine.OptionsData.downScroll)
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(songScrollSpeed, 2)));
				else
					daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(songScrollSpeed, 2)));

				var mustPress = daNote.mustPress;

				if (mustPress == true && perfectMode)
					mustPress = false;

				// i am so fucking sorry for this if condition
				if (engine.OptionsData.downScroll == false ? daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))) : daNote.isSustainNote
					&& daNote.y - daNote.offset.y >= strumLine.y - Note.swagWidth / 2
					&& (!mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (engine.OptionsData.downScroll == false ? !daNote.mustPress && daNote.y <= strumLine.y : !daNote.mustPress && daNote.y >= strumLine.y)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var selection:Int = selectedDad;

					if (daNote.charSinger > -1){
						selection = getProperCharacterID(daNote.charSinger, 'dad');
					}
					
					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					if (daNote.noteJson != null && !daNote.isSustainNote && daNote.noteJson.onDadHit != null)
						performActions(daNote.noteJson.onDadHit, daNote.noteData, selection, "dad", altAnim);

					else if (daNote.noteJson != null && daNote.isSustainNote && daNote.noteJson.onDadSustain != null)
						performActions(daNote.noteJson.onDadSustain, daNote.noteData, selection, "dad", altAnim);

					if (daNote.noteJson == null || daNote.noteJson != null && !daNote.isSustainNote && daNote.noteJson.onDadHit == null
						|| daNote.noteJson != null && daNote.isSustainNote && daNote.noteJson.onDadSustain == null){	
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								dadGroup.members[selection].singAnimPlay('singLEFT' + altAnim, true);
							case 1:
								dadGroup.members[selection].singAnimPlay('singDOWN' + altAnim, true);
							case 2:
								dadGroup.members[selection].singAnimPlay('singUP' + altAnim, true);
							case 3:
								dadGroup.members[selection].singAnimPlay('singRIGHT' + altAnim, true);
						}

						if (SONG.needsVoices){
							if (SONG.seperatedVocalTracks)
								vocals2.volume = 1;
							else{
								vocals.volume = 1;
							}
						}
					}

					// funni week 7 events
					if (SONG.song.toLowerCase() == 'ugh'){
						switch(curStep){
							case 60:
								dadGroup.members[selectedDad].playAnim('tankUgh', true);
							case 444:
								dadGroup.members[selectedDad].playAnim('tankUgh', true);
							case 524:
								dadGroup.members[selectedDad].playAnim('tankUgh', true);
							case 828:
								dadGroup.members[selectedDad].playAnim('tankUgh', true);
						}
					}
					else if(SONG.song.toLowerCase() == 'stress' && curStep == 736)
						dadGroup.members[selectedDad].playAnim('tankTalk', true);

					dadStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
						if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
						{
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						}
						else
							spr.centerOffsets();
					});

					dadGroup.members[selectedDad].holdTimer = 0;

					script.call('dadNoteHit', []);

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				
				// note misses
				if (engine.OptionsData.downScroll == false ?  daNote.y < -daNote.height : daNote.y > FlxG.height + daNote.height){
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						var selection:Int = selectedBF;

						if (daNote.charSinger > -1){
							selection = getProperCharacterID(daNote.charSinger, 'bf');
						}

						if (daNote.noteJson != null && daNote.noteJson.onMiss != null)
							performActions(daNote.noteJson.onMiss, daNote.noteData, selection, "bf", "miss");
						else if (!perfectMode){
							if (!daNote.isSustainNote)
								health -= 0.15;
							else
								health -= 0.05;
							combo = 0;
	
							songMisses++;
	
							vocals.volume = 0;
	
							// misses++;
							FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
	
							switch (Math.abs(daNote.noteData)){
								case 0:
									boyfriendGroup.members[selection].playAnim('singLEFTmiss', true);
								case 1:
									boyfriendGroup.members[selection].playAnim('singDOWNmiss', true);
								case 2:
									boyfriendGroup.members[selection].playAnim('singUPmiss', true);
								case 3:
									boyfriendGroup.members[selection].playAnim('singRIGHTmiss', true);
							}
						}
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		dadStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		if (!inCutscene && !perfectMode){
			keyShit();
		}
		else if (!inCutscene && perfectMode){
			botKeyShit();
		}

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong(true);
		#end
	}

	function endSong(?dontPlayCutscene:Bool = false):Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals2.volume = 0;

		if (dontPlayCutscene == false){
			if (FileSystem.exists(Paths.video(SONG.outroVideo))){
				playCutscene(Paths.video(SONG.outroVideo), true);

				return;
			}

			else if (FileSystem.exists(Modding.getFilePath(SONG.outroVideo + '.mp4', "videos/"))){
				playCutscene(Modding.getFilePath(SONG.outroVideo + '.mp4', "videos/"), true);

				return;
			}
		}

		//trace(Modding.getFilePath("endingCutscene.mp4", "assets/data/charts/" + SONG.song.toLowerCase()));

		if (!perfectMode)
			Highscore.saveScore(SONG.song, songScore);

		Engine.debugPrint("old playlist: " + songPlaylist);
		songPlaylist.remove(songPlaylist[0]);
		Engine.debugPrint("new playlist: " + songPlaylist);

        script.call('endSong');

		Stages.reset();

		if (songPlaylist != null && songPlaylist[0] != null && songPlaylist[0].week != null && songPlaylist != [])
			storyWeek = songPlaylist[0].week;

		Engine.debugPrint('Week:$storyWeek');

		if (songPlaylist.length <= 0){
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.sound.music.fadeIn(0.5, 0, 1);
			Conductor.changeBPM(102);

			songPlaylist = []; // reset the playlist lol

			FlxG.switchState(new FreeplayState());
		}
		else{
			Engine.debugPrint('LOADING NEXT SONG');

			var random:FlxRandom = new FlxRandom();
			var randomInt:Int = random.int(0, songPlaylist.length - 1);

			if (SONG.song.toLowerCase() == 'eggnog')
			{
				var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
					-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				blackShit.scrollFactor.set();
				add(blackShit);
				camHUD.visible = false;

				FlxG.sound.play(Paths.sound('Lights_Shut_off'));
			}

			Engine.debugPrint(songPlaylist[0].songName.toLowerCase());

			if (songPlaylist[0].modID == null)
				PlayState.SONG = Song.loadFromJson(songPlaylist[0].songName.toLowerCase(), songPlaylist[0].songName);
			else if (Modding.modPreloaded != songPlaylist[0].modID){
				Modding.preloadData(songPlaylist[0].modID);
				Modding.curLoaded = songPlaylist[0].modID;
				Modding.modLoaded = true;
				PlayState.SONG = Song.loadModChart(songPlaylist[0].songName.toLowerCase(), songPlaylist[0].songName);
			}
			else{
				Modding.curLoaded = songPlaylist[0].modID;
				Modding.modLoaded = true;
				PlayState.SONG = Song.loadModChart(songPlaylist[0].songName.toLowerCase(), songPlaylist[0].songName);
			}
			
			FlxG.sound.music.stop();

			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			prevCamFollow = camFollow;

			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(daNote:Note):Void
	{
		var strumtime:Float = daNote.strumTime;

		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);

		vocals.volume = 1;

        script.call('popUpScore', [strumtime]);

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 0;

		var daRating:String = "sick";

		var json:NoteJson = null;

		if (daNote.noteJson != null)
			json = daNote.noteJson;

		if (noteDiff > Conductor.safeZoneOffset * 0.45)
		{
			daRating = 'shit';

			if (json != null && json.scoreOnShit != null)
				score = json.scoreOnShit;
			else
				score = 50;

			shits++;

			// don't give any health
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.35)
		{
			daRating = 'bad';
			bads++;

			if (json != null && json.scoreOnBad == null || json == null)
				score = 100;
			else
				score = json.scoreOnBad;
				

			if (json != null && json.onHit != null && json.onHit.health == null || json == null)
				health += 0.05;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.25)
		{
			daRating = 'good';
			goods++;

			if (json != null && json.scoreOnGood == null || json == null)
				score = 200;
			else
				score = json.scoreOnGood;

			if (json != null && json.onHit != null && json.onHit.health == null || json == null)
				health += 0.1;
		}
		else{
			sicks++;

			if (json != null && json.scoreOnSick == null || json == null)
				score = 350;
			else
				score = json.scoreOnSick;

			if (json != null && json.onHit != null && json.onHit.health == null || json == null)
				health += 0.15;
		}

		songScore += score;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.cameras = [camHUD];
		rating.antialiasing = false;

		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
		}

		rating.updateHitbox();
		rating.screenCenter();

		var daLoop:Int = 0;
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.35, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy(); // idk what this is

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function botKeyShit():Void{
		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit){
				if (engine.OptionsData.downScroll == false ? daNote.y <= strumLine.y : daNote.y >= strumLine.y){
					if (daNote.noteJson != null && daNote.noteJson.onHit != null){
						if ((daNote.noteJson.onHit.instaKill == false ||daNote.noteJson.onHit.instaKill == null) && daNote.noteJson.onHit.health > 0){
							if ((daNote.noteJson.onMiss != null && daNote.noteJson.onMiss.instaKill == false && daNote.noteJson.onMiss.health > 0) || daNote.noteJson.onMiss == null){
								goodNoteHit(daNote);
							}
						}
					}
					else{
						goodNoteHit(daNote);
					}
				}
			}
		});

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && !boyfriendGroup.members[selectedBF].stunned && generatedMusic)
		{
			var previousCombo = combo;

			boyfriendGroup.members[selectedBF].holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList)
									badNoteCheck();
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							noteCheck(controlArray[coolNote.noteData], coolNote);
						}
					}
				}
				else // regular notes?
				{
					noteCheck(controlArray[daNote.noteData], daNote);
				}
			}
			else
			{
				// badNoteCheck();
			}
		}

		if ((up || right || down || left) && !boyfriendGroup.members[selectedBF].stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 0:
							if (left)
								goodNoteHit(daNote);
						case 1:
							if (down)
								goodNoteHit(daNote);
						case 2:
							if (up)
								goodNoteHit(daNote);
						case 3:
							if (right)
								goodNoteHit(daNote);
					}
				}
			});
		}

		for (bf in boyfriendGroup.members){
			if (bf != null){
				if (bf.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left){
					if (bf.animation.curAnim.name.startsWith('sing') && !bf.animation.curAnim.name.endsWith('miss'))
					{
						bf.playAnim('idle');
					}
				}
			}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 0:
					if (leftP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (leftR)
						spr.animation.play('static');
				case 1:
					if (downP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (downR)
						spr.animation.play('static');
				case 2:
					if (upP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (upR)
						spr.animation.play('static');
				case 3:
					if (rightP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (rightR)
						spr.animation.play('static');
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});

		// miss check
		if (!engine.OptionsData.disableGhostTap && (leftP || downP || upP || rightP) && isNoteConfirmed() == false)
			badNoteCheck();
	}

	function noteMiss(direction:Int = 1):Void
	{
		health -= 0.15;
		if (combo > 5 && gfGroup.members[selectedGF].animOffsets.exists('sad') && storyWeek == 1 /**Locked at week 1 cuz fuk u**/)
		{
			gfGroup.members[selectedGF].playAnim('sad');
		}
		combo = 0;

		songScore -= 10;
		songMisses++;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
		// FlxG.log.add('played imss note');

		boyfriendGroup.members[selectedBF].stunned = true;

		// get stunned for 5 seconds
		new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
		{
			boyfriendGroup.members[selectedBF].stunned = false;
		});

		switch (direction)
		{
			case 0:
				boyfriendGroup.members[selectedBF].playAnim('singLEFTmiss', true);
			case 1:
				boyfriendGroup.members[selectedBF].playAnim('singDOWNmiss', true);
			case 2:
				boyfriendGroup.members[selectedBF].playAnim('singUPmiss', true);
			case 3:
				boyfriendGroup.members[selectedBF].playAnim('singRIGHTmiss', true);
		}

        script.call('noteMiss', [direction]);
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
	}

	function performActions(action:NoteActions, noteData:Int, ?selection:Int, ?char:String = 'bf', ?prefix:String = ''){
		if (action.health != null)
			health += action.health;

		if (action.instaKill != null)
			triggerGameOver();

		if (action.playAnimationBF != null)
			boyfriendGroup.members[getProperCharacterID(selectedBF, "bf")].playAnim(action.playAnimationBF, true);
		else if (char.toLowerCase() == 'bf'){
			switch (noteData)
			{
				case 0:
					boyfriendGroup.members[selection].singAnimPlay('singLEFT' + prefix, true);
				case 1:
					boyfriendGroup.members[selection].singAnimPlay('singDOWN' + prefix, true);
				case 2:
					boyfriendGroup.members[selection].singAnimPlay('singUP' + prefix, true);
				case 3:
					boyfriendGroup.members[selection].singAnimPlay('singRIGHT' + prefix, true);
			}
		}

		if (action.playAnimationDAD != null)
			dadGroup.members[getProperCharacterID(selectedDad, "dad")].playAnim(action.playAnimationDAD, true);
		else if (char.toLowerCase() == 'dad'){
			switch (noteData)
			{
				case 0:
					dadGroup.members[selection].singAnimPlay('singLEFT' + prefix, true);
				case 1:
					dadGroup.members[selection].singAnimPlay('singDOWN' + prefix, true);
				case 2:
					dadGroup.members[selection].singAnimPlay('singUP' + prefix, true);
				case 3:
					dadGroup.members[selection].singAnimPlay('singRIGHT' + prefix, true);
			}
		}
	}

	function goodNoteHit(note:Note):Void
	{
		var selection:Int = selectedBF;
		
		if (note.charSinger > -1){
			selection = getProperCharacterID(note.charSinger, 'bf');
		}

		if (!note.wasGoodHit){	
			if (note.noteJson != null){
				var json:NoteJson = note.noteJson;
	
				if (note.isSustainNote == false && json.onHit != null)
					performActions(json.onHit, note.noteData, selection);
				else if (note.isSustainNote == true && json.onSustain != null)
					performActions(json.onSustain, note.noteData, selection);

				if (json.allowScoring == true)
				{
					popUpScore(note);
					combo += 1;
					songHits++;
				}

				playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
					});

				note.wasGoodHit = true;
	
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
			}
		}

		if (note.noteJson == null || note.isSustainNote && note.noteJson.onSustain == null){
			if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						popUpScore(note);
						combo += 1;
						songHits++;
					}
		
					switch (note.noteData)
					{
						case 0:
							boyfriendGroup.members[selection].singAnimPlay('singLEFT', true);
						case 1:
							boyfriendGroup.members[selection].singAnimPlay('singDOWN', true);
						case 2:
							boyfriendGroup.members[selection].singAnimPlay('singUP', true);
						case 3:
							boyfriendGroup.members[selection].singAnimPlay('singRIGHT', true);
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

		script.call('goodNoteHit', [note]);
	}

	function isNoteConfirmed(){
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var noteConfirmed:Bool = false;
		
		// "The most dumbest solutions, can be the best solutions." -Probably someone idk.
		playerStrums.forEach(function(spr:FlxSprite)
			{
				switch (spr.ID)
				{
					case 0:
						if (leftP && spr.animation.curAnim.name != 'confirm')
							noteConfirmed = false;
						else if (leftP && spr.animation.curAnim.name == 'confirm')
							noteConfirmed = true;
					case 1:
						if (downP && spr.animation.curAnim.name != 'confirm')
							noteConfirmed = false;
						else if (downP && spr.animation.curAnim.name == 'confirm')
							noteConfirmed = true;
					case 2:
						if (upP && spr.animation.curAnim.name != 'confirm')
							noteConfirmed = false;
						else if (upP && spr.animation.curAnim.name == 'confirm')
							noteConfirmed = true;
					case 3:
						if (rightP && spr.animation.curAnim.name != 'confirm')
							noteConfirmed = false;
						else if (rightP && spr.animation.curAnim.name == 'confirm')
							noteConfirmed = true;
				}
			});
		
		return noteConfirmed;
	}

	var fastCarCanDrive:Bool = true;

	function playCutscene(path:String, atEndOfSong:Bool = false)
	{
		inCutscene = true;
		FlxG.sound.music.stop();
		
		#if (hxCodec <= "2.5.1")
		var video:vlc.MP4Handler = new vlc.MP4Handler();
		#else
		var video:VideoHandler = new VideoHandler();
		#end

		video.finishCallback = function()
		{
			if (atEndOfSong)
			{
				if (songPlaylist.length <= 0)
					FlxG.switchState(new FreeplayState());
				else
				{
					endSong(true);
				}
			}
			else{
				if (dialogue != null)
					add(doof);
				else
					startCountdown();
			}
		}

		video.playVideo(path);
	}

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gfGroup.members[selectedGF].playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gfGroup.members[selectedGF].playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriendGroup.members[selectedBF].playAnim('scared', true);
		gfGroup.members[selectedGF].playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();

		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		script.call("stepHit", [curStep]);

		for (stageOBJ in layer0){
			if (stageOBJ != null && stageOBJ.stageObject.isAnimated && stageOBJ.stageObject.playOn.toLowerCase() == 'step')
				if (OptionsData.distractions == true || OptionsData.distractions == false && stageOBJ.stageObject.isDistraction == false)
					stageOBJ.animation.play(stageOBJ.stageObject.name, true);
		}

		for (stageOBJ in layer1){
			if (stageOBJ != null && stageOBJ.stageObject.isAnimated && stageOBJ.stageObject.playOn.toLowerCase() == 'step')
				if (OptionsData.distractions == true || OptionsData.distractions == false && stageOBJ.stageObject.isDistraction == false)
					stageOBJ.animation.play(stageOBJ.stageObject.name, true);
		}
		
		for (stageOBJ in layer2){
			if (stageOBJ != null && stageOBJ.stageObject.isAnimated && stageOBJ.stageObject.playOn.toLowerCase() == 'step')
				if (OptionsData.distractions == true || OptionsData.distractions == false && stageOBJ.stageObject.isDistraction == false)
					stageOBJ.animation.play(stageOBJ.stageObject.name, true);
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		script.call("beatHit", [curBeat]);

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			/*if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dadGroup.members[selectedDad].dance();*/
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
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

		if (curBeat % gfSpeed == 0 && gfGroup.members[selectedGF].animation.curAnim.name.startsWith("dance") || !gfGroup.members[selectedGF].animation.curAnim.name.startsWith("dance") &&
			!gfGroup.members[selectedGF].animation.curAnim.name.startsWith("sing") && gfGroup.members[selectedGF].animation.curAnim.finished || gfGroup.members[selectedGF].animation.curAnim.name.startsWith('scared') && curBeat % gfSpeed == 0)
		{
			gfGroup.members[selectedGF].dance();
		}

		for (boyfriend in boyfriendGroup.members){
			if (boyfriend != null){
				if (boyfriend.animation.curAnim.name.startsWith("idle") || !boyfriend.animation.curAnim.name.startsWith("idle") && 
					!boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.animation.curAnim.finished 
					|| boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.animation.curAnim.finished)
				{
					boyfriend.dance();
				}
			}
		}

		for (dad in dadGroup.members){
			if (dad != null){
				if (dad.animation.curAnim.name.startsWith("idle") || !dad.animation.curAnim.name.startsWith("idle") &&
					!dad.animation.curAnim.name.startsWith("sing") && dad.animation.curAnim.finished)
				{
					dad.dance();
				}	
			}
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriendGroup.members[selectedBF].playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dadGroup.members[selectedDad].curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriendGroup.members[selectedBF].playAnim('hey', true);
			dadGroup.members[selectedDad].playAnim('cheer', true);
		}

		for (stageOBJ in layer0){
			if (stageOBJ != null && stageOBJ.stageObject.isAnimated && stageOBJ.stageObject.playOn.toLowerCase() == 'beat')
				if (OptionsData.distractions == true || OptionsData.distractions == false && stageOBJ.stageObject.isDistraction == false)
					stageOBJ.animation.play(stageOBJ.stageObject.name, true);
		}

		for (stageOBJ in layer1){
			if (stageOBJ != null && stageOBJ.stageObject.isAnimated && stageOBJ.stageObject.playOn.toLowerCase() == 'beat')
				if (OptionsData.distractions == true || OptionsData.distractions == false && stageOBJ.stageObject.isDistraction == false)
					stageOBJ.animation.play(stageOBJ.stageObject.name, true);
		}
		
		for (stageOBJ in layer2){
			if (stageOBJ != null && stageOBJ.stageObject.isAnimated && stageOBJ.stageObject.playOn.toLowerCase() == 'beat')
				if (OptionsData.distractions == true || OptionsData.distractions == false && stageOBJ.stageObject.isDistraction == false)
					stageOBJ.animation.play(stageOBJ.stageObject.name, true);
		}

		if (OptionsData.distractions){
			switch (curStage)
			{
				case 'school':
					bgGirls.dance();
	
				case 'mall':
					upperBoppers.animation.play('bop', true);
					bottomBoppers.animation.play('bop', true);
					santa.animation.play('idle', true);
	
				case 'limo':
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
	
					if (FlxG.random.bool(10) && fastCarCanDrive)
						fastCarDrive();
				case "philly":
					if (!trainMoving)
						trainCooldown += 1;
	
					if (curBeat % 4 == 0)
					{
						phillyCityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});
	
						curLight = FlxG.random.int(0, phillyCityLights.length - 1);
	
						phillyCityLights.members[curLight].visible = true;
						// phillyCityLights.members[curLight].alpha = 1;
					}
	
					if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
					{
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
			}
	
			if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
			{
				lightningStrikeShit();
			}
		}
	}

	function triggerGameOver(){
		boyfriendGroup.members[selectedBF].stunned = true;

		persistentUpdate = false;
		persistentDraw = false;
		paused = true;

		vocals.stop();
		vocals2.stop();
		FlxG.sound.music.stop();

		DiscordClient.changePresence("GAME OVER!!!  |  " + daDRPCText, null);

		openSubState(new GameOverSubstate(boyfriendGroup.members[selectedBF].getScreenPosition().x, boyfriendGroup.members[selectedBF].getScreenPosition().y));
	}

	function calculateRatingPercent():String{
		var ratingPercent = songScore / ((songHits + songMisses) * 350);

		if(!Math.isNaN(ratingPercent) && ratingPercent < 0)
			ratingPercent = 0;

		//FlxG.log.add('Rating Percent: ' + ratingPercent);
		var rPercent:Float = FlxMath.roundDecimal(ratingPercent * 100, 2);

		if (FlxG.keys.anyJustPressed([X]))
			Engine.debugPrint('' + ratingPercent);

		if (Math.isNaN(ratingPercent))
			return '???%';
		else
			return '$rPercent%';
	}

	function performEvent(event:Events){
		switch (event.name){
			case 'deleteCharacter':
				if (event.var1.toLowerCase() == 'dad'){
					for (dad in dadGroup){
						if (dad.ID == Std.parseInt(event.var2)){
							dadGroup.remove(dad);
							dad.kill();

							break;
							return;
						}
					}
				}
				else if (event.var1.toLowerCase() == 'bf' || event.var1.toLowerCase() == 'boyfriend'){
					for (bf in boyfriendGroup){
						if (bf.ID == Std.parseInt(event.var2)){
							boyfriendGroup.remove(bf);
							bf.kill();

							break;
							return;
						}
					}
				}
			case 'addCharacter':
				if (event.var4 == null || event.var4 == '')
					event.var4 = '0';
				if (event.var5 == null || event.var5 == '')
					event.var5 = '0';

				if (event.var1.toLowerCase() == 'dad'){
					var newDad:Character = new Character(Std.parseFloat(event.var4), Std.parseFloat(event.var5), event.var2, false);
					newDad.ID = Std.parseInt(event.var3);

					selectedDad = Std.parseInt(event.var3);

					if (newDad.jsonCharacter == true && newDad.jsonData.position != null){
						newDad.x += newDad.jsonData.position[0];
						newDad.y += newDad.jsonData.position[1];
					}

					dadGroup.add(newDad);
				}
				else if (event.var1.toLowerCase() == 'bf' || event.var1.toLowerCase() == 'boyfriend'){
					var newBF:Boyfriend = new Boyfriend(Std.parseFloat(event.var4), Std.parseFloat(event.var5), event.var2);
					newBF.ID = Std.parseInt(event.var3);

					selectedBF = Std.parseInt(event.var3);

					if (newBF.jsonCharacter == true && newBF.jsonData.position != null){
						newBF.x += newBF.jsonData.position[0];
						newBF.y += newBF.jsonData.position[1];
					}

					boyfriendGroup.add(newBF);
				}
			case 'singAsCharacter':
				if (event.var1.toLowerCase() == 'dad'){
					selectedDad = getProperCharacterID(Std.parseInt(event.var2), event.var1.toLowerCase());
				}
				else if (event.var1.toLowerCase() == 'bf' || event.var1.toLowerCase() == 'boyfriend'){
					selectedBF = getProperCharacterID(Std.parseInt(event.var2), event.var1.toLowerCase());
				}
			case 'replaceGF':
				if (event.var1 != null){
					if (event.var2 == null || event.var2 == '')
						event.var2 = '0';
					if (event.var3 == null || event.var3 == '')
						event.var3 = '0';

					var newGF:Character = new Character(400 + Std.parseFloat(event.var2), 130 + Std.parseFloat(event.var3), event.var1);
					newGF.scrollFactor.set(0.95, 0.95);

					gfGroup.members[0].kill();
					gfGroup.remove(gfGroup.members[0]);

					newGF.ID = 0;
					gfGroup.add(newGF);
				}
			case 'Zoom':
				if (event.var2.toLowerCase() == 'game'){
					defaultCamZoom = FlxG.camera.zoom + Std.parseFloat(event.var3);

					if (event.var1.toLowerCase() == 'true'){
						camZooming = true;
					}
					else{
						camZooming = false;
						FlxG.camera.zoom = FlxG.camera.zoom + Std.parseFloat(event.var3);
					}
				}
				else if (event.var2.toLowerCase() == 'hud'){
					defaultHudZoom = camHUD.zoom + Std.parseFloat(event.var3);
					
					if (event.var1.toLowerCase() == 'true'){
						camZooming = true;
					}
					else{
						camZooming = false;
						camHUD.zoom = camHUD.zoom + Std.parseFloat(event.var3);
					}
				}

			case 'playAnimation':
				if (event.var1.toLowerCase() == 'dad'){
					dadGroup.members[getProperCharacterID(Std.parseInt(event.var2), event.var1)].playAnim(event.var3, true);
				}
				else if (event.var1.toLowerCase() == 'bf' || event.var1.toLowerCase() == 'boyfriend'){
					boyfriendGroup.members[getProperCharacterID(Std.parseInt(event.var2), event.var1)].playAnim(event.var3, true);
				}
				else if (event.var1.toLowerCase() == 'gf' || event.var1.toLowerCase() == 'girlfriend'){
					gfGroup.members[getProperCharacterID(Std.parseInt(event.var2), event.var1)].playAnim(event.var3, true);
				}
			default:
				// Engine.debugPrint('Event at ' + event.ms + ' has been ran at ' + Conductor.songPosition + ' With the name of ' + event.name);
		}

		if (FileSystem.exists(Modding.getFilePath(event.name + '.hx', "scripts/events/"))){
			script.loadScript("events/" + event.name, true);
		}

		if (Assets.exists(Paths.hx("scripts/events/" + event.name))){
			script.loadScript("scripts/events/" + event.name, false);
		}

		script.call("event", [event]);
	}

	private function getProperCharacterID(ID:Int, type:String):Int{
		type = type.toLowerCase();

		if (ID == -1)
			switch(type){
				case 'dad':
					return selectedDad;
				case 'gf':
					return selectedGF;
				case 'bf' | 'boyfriend':
					return selectedBF;
			}

		if (type == 'dad'){
			for (dad in dadGroup){
				if (dad != null && dad.ID == ID){
					return dadGroup.members.indexOf(dad);
					break;
				}
			}
		}
		else if (type == 'bf' || type == 'boyfriend'){
			for (bf in boyfriendGroup){
				if (bf != null && bf.ID == ID){
					return boyfriendGroup.members.indexOf(bf);
					break;
				}
			}
		}
		else if (type == 'gf'){
			for (gf in gfGroup){
				if (gf != null && gf.ID == ID){
					return gfGroup.members.indexOf(gf);
					break;
				}
			}
		}

		return 0;
	}

	var curLight:Int = 0;
}

typedef SongData = {
	var songName:String;
	var ?week:Int;
	var ?modID:String;
}
