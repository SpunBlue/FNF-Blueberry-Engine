package game;

import sys.io.File;
import haxe.Json;
import sys.FileSystem;
import engine.modding.Modding;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var grpWeeks:FlxTypedGroup<Alphabet>;

	var bg:FlxSprite;

	var leaving:Bool = false;
	var tcolor:FlxColor;

	var weeks:Array<WeekData> = [];
	var isInWeeks:Bool = true;

	override function create()
	{
		allowCamBeat = true;

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (song in initSonglist)
		{
			var songShit = song.split(':');

			songs.push(new SongMetadata(songShit[0], Std.parseInt(songShit[2]), songShit[1], ""));
		}

		for (songMod in Modding.loadedMods){
			if (songMod != null)
				Modding.curLoaded = songMod;

			if (songMod != null && FileSystem.exists('mods/$songMod/data/songList.txt')){
				for (song in Modding.retrieveTextArray('songList.txt', 'data')){
					var songShit = song.split(':');

					songs.push(new SongMetadata(songShit[0], Std.parseInt(songShit[2]), songShit[1], songMod));
				}
			}
		}

		// do fnf week bullshit

		var fnfWeek:WeekJson = Json.parse(File.getContent(Paths.json('weeks', 'preload')));

		for (week in fnfWeek.weeks){
			if (week != null){
				trace(week);

				weeks.push(week);
			}
		}

		FlxG.sound.playMusic(Paths.music('freeplayMenu'));
		FlxG.sound.music.fadeIn(0.5, 0, 1);
		Conductor.changeBPM(110);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD WEEKS

		grpWeeks = new FlxTypedGroup<Alphabet>();

		for (i in 0...weeks.length){
			if (weeks[i] != null){
				var songText:Alphabet = new Alphabet(0, (70 * i) + 30, weeks[i].name, true, false);
				songText.isMenuItem = true;
				songText.targetY = i;
				grpWeeks.add(songText);
	
				var icon:HealthIcon = new HealthIcon(weeks[i].icon, false, false, false);
				icon.sprTracker = songText;
	
				iconArray.push(icon);
				add(icon);
			}
		}

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		add(grpWeeks);

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */


		updateColor();
		
		super.create();
	}

	public function addSong(songName:String, week:Int, songCharacter:String, mod:String = "")
	{
		songs.push(new SongMetadata(songName,week, songCharacter, mod));
	}

	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time;

		camera.zoom = FlxMath.lerp(camera.zoom, camera.initialZoom, 0.1);

		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		/*lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "HIGH:" + lerpScore;*/

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (!isInWeeks){
			if (upP)
			{
				changeSelection(-1);
	
				updateColor();
			}
			if (downP)
			{
				changeSelection(1);
	
				updateColor();
			}
	
			if (controls.LEFT_P)
				changeDiff(-1);
			if (controls.RIGHT_P)
				changeDiff(1);

			if (accepted)
				{
					var poop:String = "charts/" + Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
		
					trace(poop);
		
					if (songs[curSelected].mod != ""){
						Modding.curLoaded = songs[curSelected].mod;
						Modding.modLoaded = true;
		
						Modding.preloadData(Modding.curLoaded); //preloads mod data
						PlayState.SONG = Song.loadModChart(poop, songs[curSelected].songName.toLowerCase());
					}
					else{
						Modding.modLoaded = false;
						Modding.curLoaded = "";
		
						PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
					}
		
					PlayState.isValidWeek = false;
					PlayState.gameDifficulty = curDifficulty;
		
					PlayState.storyWeek = songs[curSelected].week;
					trace('CUR WEEK' + PlayState.storyWeek);
		
					LoadingState.loadAndSwitchState(new PlayState());
				}
		}

		if (controls.BACK && !leaving)
		{
			FlxG.sound.music.stop(); // for some odd reason fadeOut doesn't work.
			FlxG.switchState(new MainMenuState());

			leaving = true;
		}
	}

	function updateColor(){
		var healthColors:Array<String> = CoolUtil.coolTextFile(Paths.txt('healthColors'));

		if (songs[curSelected].mod == null || songs[curSelected].mod == ''){
			for (characters in healthColors){
				if (!characters.startsWith('#')) {
					var eugh = characters.split(':');
					
					for (bruh in healthColors) {
						if (!bruh.startsWith('#')) {
							var eugh = bruh.split(':');
			
							if (songs[curSelected].songCharacter.toLowerCase().startsWith(eugh[0])) {
								tcolor = new FlxColor(Std.parseInt(eugh[1]));
							}
						}
					}
				}
			}
		}
		else
			tcolor = FlxColor.fromRGB(146, 113, 253); /**
			I tried to get Json Characters healthColor's working but for some reason it would just spit out that there was an invalid character when in reality
			there wasn't??? So it's just gonna default this, eat my ass.

			Maybe I'll pull a Psych and make it so you have to set a custom color for the song/week idk...
		**/

		
		if (bg.color != tcolor){
			FlxTween.color(bg, 0.5, bg.color, tcolor, {ease: FlxEase.quadInOut, type: ONESHOT});
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "< EASY >";
			case 1:
				diffText.text = '< NORMAL >';
			case 2:
				diffText.text = "< HARD >";
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
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

	function createSongs(){
		for (i in 0...songs.length)
			{
				var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
				songText.isMenuItem = true;
				songText.targetY = i;
				grpSongs.add(songText);
	
				var charIsJson:Bool = false;
				var charIsMod:Bool = false;
	
				Modding.curLoaded = songs[i].mod;
	
				if (FileSystem.exists(Modding.getFilePath(songs[i].songCharacter + '.json', 'data/characters'))){
					charIsJson = true;
					charIsMod = true;
				}
				else if (FileSystem.exists('assets/characters/' + songs[i].songCharacter +'.json')){
					charIsJson = true;
				}
	
				var icon:HealthIcon = new HealthIcon(songs[i].songCharacter, false, charIsJson, charIsMod);
				icon.sprTracker = songText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
	
				// songText.x += 40;
				// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
				// songText.screenCenter(X);
			}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var mod:String = "";

	public function new(song:String, week:Int, songCharacter:String, mod:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.mod = mod;
	}
}

typedef WeekJson = {
	var weeks:Array<WeekData>;
}

typedef WeekData =
{
	var name:String;
	var songs:Array<String>;
	var week:Int;
	var icon:String;
	var ?isMod:Bool;
}