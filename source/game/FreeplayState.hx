package game;

import util.ui.PreferencesMenu.CheckboxThingie;
import game.PlayState.SongData;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.ui.FlxButton.FlxTypedButton;
import sys.io.File;
import haxe.Json;
import sys.FileSystem;
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
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.util.FlxArrayUtil;

using StringTools;

class FreeplayState extends MusicBeatState
{  
    var menuItems:FlxTypedGroup<MenuItem> = new FlxTypedGroup();
    var playIcons:FlxTypedGroup<HealthIcon> = new FlxTypedGroup();

    static var generatedWeeksMenu:Array<MItemInf> = null;
	public static var loopList:Array<SongData> = [];

    var uiItems:FlxGroup = new FlxGroup();

	var loopCheck:Checkbox;

    var itemsLength:Int = 0;

    var curSelected:Int = 1;
    var lastSelected:Int = 0;

    var selectedWeek:WeekData;
    var selectedModID:String;

    var inSongMenu:Bool = false;

    var camFollow:FlxSprite;
    var scoreText:FlxText;

    var bg:FlxSprite;

    override function create(){
        allowCamBeat = true;

        super.create();

        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.scrollFactor.set(0, 0);
        bg.color = FlxColor.fromRGB(79, 134, 247);
		add(bg);

        camFollow = new FlxSprite().makeGraphic(32, 32, FlxColor.WHITE);
        camFollow.screenCenter();

        FlxG.camera.follow(camFollow, null, CoolUtil.camLerpShit(0.06));

        generateMenu(getMenu('weeks'));

        add(menuItems);
        add(playIcons);

        // too lazy to rename this correctly
        var leftBar = new FlxSprite(FlxG.width - 256, 0).makeGraphic(256, FlxG.height, FlxColor.BLACK);
        leftBar.alpha = 0.75;
        leftBar.scrollFactor.set(0, 0);
        uiItems.add(leftBar);

        scoreText = new FlxText(FlxG.width - 256, 5, leftBar.width, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);
        scoreText.scrollFactor.set(0, 0);
        uiItems.add(scoreText);

		loopCheck = new Checkbox(0, 0, PlayState.inLoopMode);
		loopCheck.setPosition(FlxG.width - loopCheck.width, FlxG.height - loopCheck.height);
		uiItems.add(loopCheck);

		var loopText:FlxText = new FlxText(0, 0, "Loop", 32);
		loopText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);
		loopText.scrollFactor.set(0, 0);
		loopText.setPosition(loopCheck.x - loopText.width, (loopCheck.y + (loopText.height / 2) + 38));
		uiItems.add(loopText);

        add(uiItems);

		if (PlayState.songPlaylist != [])
			PlayState.songPlaylist = [];
    }

    override function update(elapsed:Float){
        Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);

		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(loopCheck)){
			loopCheck.value = !loopCheck.value;

			PlayState.inLoopMode = loopCheck.value;
		}

        if (PlayState.songPlaylist != [])
            PlayState.songPlaylist = [];

        if (Conductor.bpm != 102)
            Conductor.changeBPM(102);

        if (curSelected >= 1 && controls.UI_DOWN_P){
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

            curSelected++;
        }
        else if(curSelected <= itemsLength && controls.UI_UP_P){
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

            curSelected--;
        }

        if (curSelected <= 0)
            curSelected = itemsLength;
        else if (curSelected > itemsLength)
            curSelected = 1;

        /*if (controls.UI_UP_P)
            Engine.debugPrint(curSelected + ' ' + itemsLength);*/

        for (item in menuItems){
            if (item != null && curSelected == item.ID + 1){
                if (bg.color != item.targetColor)
                    bg.color = FlxColor.interpolate(bg.color, item.targetColor, 0.045);
            }

            if (item != null && curSelected == item.ID + 1 && lastSelected != curSelected){
                camFollow.y = item.y + 32;

                if (item.type.toLowerCase() == 'week')
                    scoreText.text = 'SCORE: ' + Highscore.getWeekScore(item.weekData.songs);
                else if (item.type.toLowerCase() == 'song')
                    scoreText.text = 'SCORE: ' + Highscore.getScore(item.text);
                else
                    scoreText.text = 'SCORE: N/A';

                if (item.modID != null){
                    //scoreText.text += '\nMOD: ' + Modding.retrieveModName(item.modID);
                }

                if (item.weekData != null && item.weekData.songs != null){
                    var i:Int = 0;
                    var suffix:String = '';
                    for (song in item.weekData.songs){
                        if (i >= 16){
                            scoreText.text += '\nAnd ' + Std.string(item.weekData.songs.length - i) + ' more...';
                            break;
                        }
                        else if (i == 0)
                            suffix = '\nSONGS\n'
                        else
                            suffix = '';

                        scoreText.text += '\n' + suffix + '$song';
                        i++;
                    }
                }

                lastSelected = curSelected;
            }

            if (item != null && curSelected == item.ID + 1 && controls.ACCEPT){
                if (item.type.toLowerCase() == 'week'){
                    selectedWeek = item.weekData;
                    selectedModID = item.modID;

                    generateMenu(getMenu('songs'));

                    curSelected = 1;
                }

                if (item.type.toLowerCase() == 'playall' || item.type.toLowerCase() == 'shuffle'){
                    var mod:String = selectedModID;

                    if (inSongMenu){
                        for (item in menuItems.members){
                            if (item != null && item.type.toLowerCase() == 'song'){
                                PlayState.songPlaylist.push({songName: item.text.toLowerCase(), modID: mod, week:selectedWeek.week});
                                //Engine.debugPrint(item.text);
                            }
                        }
                    }
                    else{
                        for (item in menuItems.members){
                            if (item != null && item.type.toLowerCase() == 'week'){
                                for (i in 0...item.weekData.songs.length){
                                    PlayState.songPlaylist.push({songName: item.weekData.songs[i], modID: item.modID, week:item.weekData.week});
                                    //Engine.debugPrint(item.text);
                                }
                            }
                        }
                    }

                    if (item.type.toLowerCase() == 'shuffle')
                        PlayState.songPlaylist = randomizeSongs(PlayState.songPlaylist);

					loopList = [];

					for (song in PlayState.songPlaylist){
						loopList.push(song);
					}

					PlayState.SONG = Song.loadFromJson(PlayState.songPlaylist[0].songName, PlayState.songPlaylist[0].songName);

                    if (PlayState.songPlaylist[0].week != null)
                        PlayState.storyWeek = PlayState.songPlaylist[0].week;
                    
                   // Engine.debugPrint('CUR WEEK' + PlayState.storyWeek);
                   // Engine.debugPrint('PLAYLIST: ' + PlayState.songPlaylist);
        
                    LoadingState.loadAndSwitchState(new PlayState());
                }
                else if (item.type.toLowerCase() == 'song'){
                    var poop:String = item.text.toLowerCase();
        
					PlayState.SONG = Song.loadFromJson(poop, poop);
                    
                    PlayState.songPlaylist.push({songName: item.text.toLowerCase(), modID: selectedModID, week:selectedWeek.week});

					loopList = [];

					for (song in PlayState.songPlaylist){
						loopList.push(song);
					}

                    PlayState.storyWeek = selectedWeek.week;

                    LoadingState.loadAndSwitchState(new PlayState());
                }
            }

            if (curSelected == item.ID + 1)
                item.alpha = 1;
            else
                item.alpha = 0.75;
        }

        if (FlxG.keys.justPressed.ESCAPE == true){
            if (inSongMenu){
                generateMenu(getMenu('weeks'));
            }
            else
                FlxG.switchState(new MainMenuState());
        }

    }

    function getMenu(type:String, willLoadMenu:Bool = true){
        var thismenu:Array<MItemInf> = [];

        switch (type.toLowerCase()){
            case 'weeks':
                if (generatedWeeksMenu == null || generatedWeeksMenu == []){
                    generatedWeeksMenu = [];
                    generatedWeeksMenu.push({type:'playall', string: 'Play All'});
                    generatedWeeksMenu.push({type:'shuffle', string: 'Shuffle'});
        
                    var vanillaweeks:WeekJson = Json.parse(File.getContent(Paths.json('weeks', 'preload')));
                
                    for (week in vanillaweeks.weeks){
                        generatedWeeksMenu.push({type:'week', weekData: week, string: week.name});
                    }
                
                    /*for (mod in Modding.loadedMods){
                        if (FileSystem.isDirectory('mods/$mod/weeks') == true){
                            for (weekJson in FileSystem.readDirectory('mods/$mod/weeks/')){
                                if (weekJson != null && weekJson.contains('.json')){
                                    var finalWeeks:WeekJson = Json.parse(File.getContent('mods/$mod/weeks/' + weekJson));
                
                                    for (week in finalWeeks.weeks){
                                        generatedWeeksMenu.push({type:'week', weekData: week, string: week.name, modID: mod});
                                    }
                                }
                            }
                        }
                    }*/
                }

                thismenu = generatedWeeksMenu;
        
                if (willLoadMenu)
                    inSongMenu = false;
            case 'songs':
                thismenu.push({type:'playall', string: 'Play All'});
                thismenu.push({type:'shuffle', string: 'Shuffle'});
        
                for (song in selectedWeek.songs){
                    thismenu.push({type: 'song', string: song, modID: selectedModID});
                }
        
                if (willLoadMenu)
                    inSongMenu = true;
        }

        return thismenu;
    }      

    function generateMenu(items:Array<MItemInf>){
        menuItems.clear();
        playIcons.clear();
        var v:Int = 0;
    
        for (item in items){
            var newItem = new MenuItem(32, (72 * v) + 32, item.string, item.type, item.weekData, item.modID);
            menuItems.add(newItem);
            newItem.ID = v;
            v++;
    
            if (item.type == 'week' && item.weekData != null){
                /*if (item.modID != null && item.modID != '')
                    Modding.curLoaded = item.modID;*/
    
                if (item.weekData.color != null)
                    newItem.targetColor = Std.parseInt(item.weekData.color);
    
                var icon = new HealthIcon(item.weekData.icon, false, 0, 24);

                icon.sprTracker = newItem;
                icon.scrollFactor.set(1, 1);
                icon.setGraphicSize(Std.int(icon.width * 0.6));
                icon.updateHitbox();

                playIcons.add(icon);

                /*if (Modding.curLoaded != null || Modding.curLoaded != '')
                    Modding.curLoaded = null;*/
            }
        }

        itemsLength = v;
    }
    

    public function randomizeSongs(arr:Array<SongData>) {
        var randomizedArray = arr;
        var currentIndex = randomizedArray.length;
        var temporaryValue:Dynamic;
        var randomIndex:Int;
    
        // While there remain elements to shuffle...
        while (currentIndex > 0) {
            // Pick a remaining element...
            randomIndex = Std.random(currentIndex);
            currentIndex--;
    
            // And swap it with the current element.
            temporaryValue = randomizedArray[currentIndex];
            randomizedArray[currentIndex] = randomizedArray[randomIndex];
            randomizedArray[randomIndex] = temporaryValue;
        }
    
        return randomizedArray;
    }
    
}

class Checkbox extends FlxSprite
{
	public var value:Bool = false;
	private var lastValue:Bool = false;

	public function new(x:Float, y:Float, daValue:Bool = false)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('checkboxThingie');
		animation.addByPrefix('static', 'Check Box unselected', 24, false);
		animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);

		antialiasing = true;

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		scrollFactor.set(0, 0);

		this.value = daValue;

		switch (value){
			case true:
				animation.play('checked', true);
				offset.set(17, 70);
			default:
				animation.play('static', true);
				offset.set(0, 0);
		}
	}

	override function update(elapsed:Float)
	{
		if (value != lastValue){
			switch (value)
			{
				case false:
					animation.play('checked', true, true);
				case true:
					animation.play('checked', true);
					offset.set(17, 70);
			}

			lastValue = value;
		}

		if (animation.curAnim.curFrame == 0 && animation.curAnim.reversed){
			animation.play('static', true);
			offset.set();
		}

		super.update(elapsed);
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
    var iconIsJson:Bool;
	var ?isMod:Bool;
    var ?color:String;
    var ?disablePreload:Bool;
}

typedef MItemInf ={
    var type:String;
    var ?string:String;
    var ?weekData:WeekData;
    var ?modID:String;
}

class MenuItem extends FlxText{
    public var weekData:WeekData;
    public var type:String;
    public var modID:String;
    public var targetColor:FlxColor = FlxColor.fromRGB(79, 134, 247); 

    public function new(x:Float, y:Float, text:String, type:String, ?weekData:WeekData, ?modID:String, size:Int = 64, facing:FlxTextAlign = LEFT){
        super(x, y);
        this.text = text;
        this.type = type;
        this.setFormat(Paths.font("PhantomMuff.ttf"), size, FlxColor.WHITE, facing);
        setBorderStyle(OUTLINE, FlxColor.BLACK, 4, 2);

        if (weekData != null)
            this.weekData = weekData;
        if (modID != null)
            this.modID = modID;
    }
}