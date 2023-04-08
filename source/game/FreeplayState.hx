package game;

import flixel.math.FlxPoint;
import flixel.FlxObject;
import engine.modding.SpunModLib.ModAssets;
import engine.modding.SpunModLib.ModLib;
import engine.modding.SpunModLib.Mod;
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
    var menuItems:FlxGroup = new FlxGroup();
    var menuSelects:FlxTypedGroup<MenuItem> = new FlxTypedGroup();
    var menuIcons:FlxTypedGroup<HealthIcon> = new FlxTypedGroup();

    var allowSelections:Bool = true;
    var inSongMenu:Bool = false;

    var curSelected:Int = 0;
    var lastSelected:Int = 0; // Repersentive of the last item in menuSelects player selected.
    var lastUpdated:Int = -1; // Repersentive of the last item that updated UI elements.

    var weekJsons:Array<WeekList> = [];

    // Objects
    var bg:FlxSprite;
    var camFollow:FlxObject;

    var highestWidth:Float = 0;

    // UI Elements
    var scoreText:FlxText;
    var loopCheck:Checkbox;

    // Public Variables
    public static var loopList:Array<SongData> = [];

    override function create(){
        camFollow = new FlxObject(0, 0, 32, 32);
        camFollow.screenCenter(X);
        add(camFollow);

        FlxG.camera.follow(camFollow, null, CoolUtil.camLerpShit(0.06));

        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.scrollFactor.set(0, 0);
        bg.color = FlxColor.fromRGB(79, 134, 247);
		add(bg);

        var rightBar = new FlxSprite(FlxG.width - 256, 0).makeGraphic(256, FlxG.height, FlxColor.BLACK);
        rightBar.alpha = 0.75;
        rightBar.scrollFactor.set(0, 0);
        menuItems.add(rightBar);

        scoreText = new FlxText(FlxG.width - 256, 5, rightBar.width, "Score: N/A", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);
        scoreText.scrollFactor.set(0, 0);
        menuItems.add(scoreText);

		loopCheck = new Checkbox(0, 0, PlayState.inLoopMode);
		loopCheck.setPosition(FlxG.width - loopCheck.width, FlxG.height - loopCheck.height);
		menuItems.add(loopCheck);

		var loopText:FlxText = new FlxText(0, 0, "Loop", 32);
		loopText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);
		loopText.scrollFactor.set(0, 0);
		loopText.setPosition(loopCheck.x - loopText.width, (loopCheck.y + (loopText.height / 2) + 38));
		menuItems.add(loopText);

        // Valid Weeks
        weekJsons.push({json: Json.parse(File.getContent(Paths.json("weeks", "preload")))});
        for (mod in ModLib.mods){
            if (ModAssets.assetExists('data/weeks.json', mod, null, null, false)){
                weekJsons.push({json: Json.parse(ModAssets.getContent('data/weeks.json', mod, null, null, false)), mod: mod});
            }
        }

        generateWeeksMenu(weekJsons);

        add(menuSelects);
        add(menuIcons);
        add(menuItems);

        super.create();

        if (!FlxG.sound.music.playing || FlxG.sound.music == null){
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            FlxG.sound.music.fadeIn(0.5, 0, 1);
            Conductor.changeBPM(102);
        }
    }

    override function update(elapsed:Float){
        Conductor.songPosition = FlxG.sound.music.time;

        if (Conductor.bpm != 102)
            Conductor.changeBPM(102);

        super.update(elapsed);

        if (controls.UI_UP_P && allowSelections){
            --curSelected;

            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        }
        else if (controls.UI_DOWN_P && allowSelections){
            ++curSelected;

            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        }

        if (controls.BACK){
            if (!inSongMenu)
                FlxG.switchState(new MainMenuState());
            else{
                allowSelections = false;

                FlxTween.tween(camFollow, {x: camFollow.x + 32 + (highestWidth + Std.int(150 * 0.6))}, 0.25, {ease: FlxEase.linear, onComplete: function(v:Dynamic) {
                    generateWeeksMenu(weekJsons);
                    curSelected = lastSelected;
                    lastUpdated = -1;
                    
                    camFollow.screenCenter(X);
                    for (item in menuSelects){
                        if (item.ID == curSelected){
                            camFollow.y = item.y + 32;
                            break;
                        }
                    }
                    FlxG.camera.focusOn(camFollow.getPosition());
                    allowSelections = true;
                }});
            }
        }

        if (FlxG.keys.justPressed.L || FlxG.mouse.overlaps(loopCheck) && FlxG.mouse.justPressed){
            loopCheck.value = !loopCheck.value;
            PlayState.inLoopMode = loopCheck.value;
        }

        if (curSelected < 0)
            curSelected = menuSelects.members.length - 1;
        else if (curSelected > menuSelects.members.length - 1)
            curSelected = 0;

        for (item in menuSelects){
            if (item != null && item.ID == curSelected){
                bg.color = FlxColor.interpolate(bg.color, item.targetColor, 0.045);

                if (curSelected != lastUpdated && allowSelections){
                    camFollow.y = item.y + 32;
                    item.alpha = 1;

                    FlxTween.tween(item, {x: 32}, 0.25, {ease: FlxEase.circOut});

                    lastUpdated = curSelected;
                }

                if (controls.ACCEPT && allowSelections){
                    runItemTask(item);
                }
            }
            else if (item != null && item.ID != curSelected && item.alpha != 0.75 && allowSelections){
                item.alpha = 0.75;

                FlxTween.tween(item, {x: 0}, 0.25, {ease: FlxEase.circOut});
            }
        }
    }

    function triggerCamTransition(?func:Void -> Void){
        FlxTween.tween(camFollow, {x: camFollow.x + 32 + (highestWidth + Std.int(150 * 0.6))}, 0.25, {ease: FlxEase.linear, onComplete: function(v:Dynamic) {
            lastSelected = curSelected;
            if (func != null)
                func();
            curSelected = 0;
            lastUpdated = -1;

            camFollow.y = 32;
            FlxG.camera.focusOn(camFollow.getPosition());
            camFollow.screenCenter(X);
            allowSelections = true;
        }});
    }

    function runItemTask(item:MenuItem){
        PlayState.songPlaylist = []; // Reset

        if (item.itemType == STORY_ITEM){
            allowSelections = false;

            triggerCamTransition(function(){
                generateSongsMenu(item.weekData, item.mod);
            });
        }
        else if (item.itemType == SONG_ITEM){
            var poop:String = item.song.toLowerCase();

            PlayState.songPlaylist.push({songName: item.song, mod: item.mod, week: item.weekData.week});

            if (PlayState.songPlaylist[0].mod != null)
                ModLib.setMod(PlayState.songPlaylist[0].mod.id);

            PlayState.SONG = Song.loadFromJson(poop, poop);

            if (loopCheck.value == true){
                loopList = [];

                for (song in PlayState.songPlaylist){
                    loopList.push(song);
                }
            }

            if (PlayState.songPlaylist[0].week != null)
                PlayState.storyWeek = PlayState.songPlaylist[0].week;

            LoadingState.loadAndSwitchState(new PlayState());
        }
        else if (item.itemType == GENERAL_ITEM){
            if (item.text.toLowerCase().startsWith("shuffle") || item.text.toLowerCase().startsWith("play")){ // play = play all
                for (item in menuSelects.members){
                    if (item != null && item.itemType == SONG_ITEM && inSongMenu){
                        PlayState.songPlaylist.push({songName: item.song, mod: item.mod, week: item.weekData.week});
                    }
                    else if (item != null && item.itemType == STORY_ITEM && !inSongMenu){
                        for (i in 0...item.weekData.songs.length){
                            PlayState.songPlaylist.push({songName: item.weekData.songs[i], mod: item.mod, week:item.weekData.week});
                        }
                    }
                }

                if (loopCheck.value == true){
                    loopList = [];

                    for (song in PlayState.songPlaylist){
                        loopList.push(song);
                    }
                }

                if (item.text.toLowerCase().startsWith("shuffle"))
                    PlayState.songPlaylist = randomizeSongs(PlayState.songPlaylist);

                if (PlayState.songPlaylist[0].mod != null){
                    ModLib.setMod(PlayState.songPlaylist[0].mod.id);
                }

                PlayState.SONG = Song.loadFromJson(PlayState.songPlaylist[0].songName, PlayState.songPlaylist[0].songName);

                if (PlayState.songPlaylist[0].week != null)
                    PlayState.storyWeek = PlayState.songPlaylist[0].week;
    
                LoadingState.loadAndSwitchState(new PlayState());
            }
        }
        else{
            trace('If you see this, something went confusingly wrong.');
        }
    }

    function generateSongsMenu(weekdata:WeekData, ?mod:Mod){
        for (item in menuSelects){
            item.kill();
            item.destroy();
        }

        menuSelects.clear();

        for (item in menuIcons){
            item.kill();
            item.destroy();
        }

        menuIcons.clear();

        inSongMenu = true;

        var y:Float = 0;
        var ID:Int = 0;

        var playall:MenuItem = new MenuItem(0, y + 72, "Play All", GENERAL_ITEM);
        playall.ID = 0;
        if (weekdata.rgb != null && weekdata.rgb != [])
            playall.targetColor = FlxColor.fromRGB(weekdata.rgb[0], weekdata.rgb[1], weekdata.rgb[2]);
        menuSelects.add(playall);

        var shuffle:MenuItem = new MenuItem(0, y + (72 * 2), "Shuffle All", GENERAL_ITEM);
        shuffle.ID = 1;
        if (weekdata.rgb != null && weekdata.rgb != [])
            shuffle.targetColor = FlxColor.fromRGB(weekdata.rgb[0], weekdata.rgb[1], weekdata.rgb[2]);
        menuSelects.add(shuffle);

        y = (72 * 2);
        ID = 2;

        for (song in weekdata.songs){
            var week:MenuItem = new MenuItem(0, y + 72, song, SONG_ITEM, {weekData: weekdata, song: song, mod: mod});
    
            if (weekdata.rgb != null && weekdata.rgb != [])
                week.targetColor = FlxColor.fromRGB(weekdata.rgb[0], weekdata.rgb[1], weekdata.rgb[2]);

            week.ID = ID;
            week.x = week.width * -1;

            if (week.width > highestWidth)
                highestWidth = week.width;

            ++ID;
            y += 72;

            menuSelects.add(week);
            FlxTween.tween(week, {x: 0}, 0.25, {ease: FlxEase.circOut});
        }
    }

    function generateWeeksMenu(weeks:Array<WeekList>){
        for (item in menuSelects){
            item.kill();
            item.destroy();
        }

        menuSelects.clear();

        for (item in menuIcons){
            item.kill();
            item.destroy();
        }

        menuIcons.clear();

        inSongMenu = false;

        var y:Float = 0;
        var ID:Int = 0;

        var playall:MenuItem = new MenuItem(0, y + 72, "Play All", GENERAL_ITEM);
        playall.ID = 0;
        playall.x = -playall.width;
        menuSelects.add(playall);

        var shuffle:MenuItem = new MenuItem(0, y + (72 * 2), "Shuffle All", GENERAL_ITEM);
        shuffle.ID = 1;
        shuffle.x = -shuffle.width;
        menuSelects.add(shuffle);

        ID = 2;
        y += (72 * 2);

        for (junk in weeks){
            for (daWeek in junk.json.weeks){
                var week:MenuItem = new MenuItem(0, y + 72, daWeek.name, STORY_ITEM, {weekData: daWeek, mod: junk.mod});
    
                if (daWeek.rgb != null && daWeek.rgb != [])
                    week.targetColor = FlxColor.fromRGB(daWeek.rgb[0], daWeek.rgb[1], daWeek.rgb[2]);
    
                week.ID = ID;

                if (junk.mod != null){
                    ModLib.setMod(junk.mod.id); // Just for the icons lol
                }
    
                var icon:HealthIcon = new HealthIcon(daWeek.icon, false, 0, 24);
                icon.sprTracker = week;
                icon.scrollFactor.set(1, 1);
                icon.setGraphicSize(Std.int(icon.width * 0.6));
                icon.updateHitbox();
                icon.alpha = 0;
    
                week.x = -(week.width + icon.width);

                if (week.width > highestWidth)
                    highestWidth = week.width;
    
                menuSelects.add(week);
                menuIcons.add(icon);

                FlxTween.tween(icon, {alpha: 1}, 0.25, {ease: FlxEase.circOut});
    
                ++ID;
                y += 72;
            }
        }

        ModLib.setMod();
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

enum MenuItemType {
    STORY_ITEM;
    SONG_ITEM;
    GENERAL_ITEM;
}

typedef MenuItemData = {
    var ?song:String;
    var ?weekData:WeekData;
    var ?mod:Mod;
}

class MenuItem extends FlxText {
    // Data
    public var itemType:MenuItemType;

    public var song:String;

    public var weekData:WeekData;
    public var mod:Mod;

    // Target Color for Background (If any)
    public var targetColor:FlxColor = FlxColor.fromRGB(79, 134, 247); 

    public function new(x:Float, y:Float, text:String, itemType:MenuItemType, ?data:MenuItemData, ?size:Int = 64, ?facing:FlxTextAlign = LEFT) {
        super(x, y);

        this.text = text;
        this.itemType = itemType;

        setFormat(Paths.font("PhantomMuff.ttf"), size, FlxColor.WHITE, facing);
        setBorderStyle(OUTLINE, FlxColor.BLACK, 4, 2);

        switch (itemType) {
            case STORY_ITEM:
                this.weekData = data.weekData;
                this.mod = data.mod;
            case SONG_ITEM:
                this.song = data.song;
                this.weekData = data.weekData;
                this.mod = data.mod;
            case GENERAL_ITEM:
                // No additional data for general item
        }
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

typedef WeekList = {
    var json:WeekJson;
    var ?mod:Mod;
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
    var ?rgb:Array<Int>;
    var ?disablePreload:Bool;
}