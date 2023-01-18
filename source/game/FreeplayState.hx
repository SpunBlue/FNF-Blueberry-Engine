package game;

import game.PlayState.SongData;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.ui.FlxButton.FlxTypedButton;
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
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.util.FlxArrayUtil;

using StringTools;

class FreeplayState extends MusicBeatState
{  
    var menuItems:FlxTypedGroup<MenuItem> = new FlxTypedGroup();
    var playIcons:FlxTypedGroup<HealthIcon> = new FlxTypedGroup();

    var curSelected:Int = 0;
    var selectedWeek:WeekData;
    var selectedModID:String;

    override function create(){
        allowCamBeat = true;

        super.create();

        var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

        generateMenu(getMenu('weeks'));

        add(menuItems);
        add(playIcons);
    }

    override function update(elapsed:Float){
        Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);

        if (PlayState.songPlaylist != [])
            PlayState.songPlaylist = [];

        if (Conductor.bpm != 102)
            Conductor.changeBPM(102);

        if (curSelected >= 1 && controls.DOWN_P)
            curSelected++;
        else if(curSelected <= menuItems.members.length && controls.UP_P)
            curSelected--;

        if (curSelected <= 0)
            curSelected = 1;
        else if (curSelected > menuItems.members.length)
            curSelected = menuItems.members.length;

        if (controls.UP_P)
            trace(curSelected + ' ' + menuItems.members.length);

        for (item in menuItems){

            if (curSelected == item.ID + 1 && controls.ACCEPT){

                if (item.type.toLowerCase() == 'week'){
                    selectedWeek = item.weekData;
                    selectedModID = item.modID;

                    generateMenu(getMenu('songs'));

                    curSelected = 1;
                }

                if (item.type.toLowerCase() == 'playall' || item.type.toLowerCase() == 'shuffle'){
                    var mod:String = "";
                    mod = menuItems.members[2].modID;

                    for (item in menuItems.members){
                        if (item != null && item.type.toLowerCase() == 'song'){
                            PlayState.songPlaylist.push({songName: item.text.toLowerCase(), modID: item.modID});
                            trace(item.text);
                        }
                    }

                    if (item.type.toLowerCase() == 'shuffle'){
                        PlayState.inShuffleMode = true;

                        PlayState.songPlaylist = randomizeSongs(PlayState.songPlaylist);
                    }
                    else
                        PlayState.inShuffleMode = false;
        
                    if (mod == null){
                        Modding.modLoaded = false;
                        Modding.curLoaded = "";

                        PlayState.SONG = Song.loadFromJson(PlayState.songPlaylist[0].songName, PlayState.songPlaylist[0].songName);
                    }
                    else{
                        Modding.preloadData(item.modID);
                        Modding.modLoaded = true;
                        Modding.curLoaded = item.modID;

                        PlayState.SONG = Song.loadModChart(PlayState.songPlaylist[0].songName, PlayState.songPlaylist[0].songName);
                    }

                    PlayState.isValidWeek = true;
        
                    PlayState.storyWeek = selectedWeek.week;
                    trace('CUR WEEK' + PlayState.storyWeek);
                    trace('PLAYLIST: ' + PlayState.songPlaylist);
        
                    LoadingState.loadAndSwitchState(new PlayState());
                }
                else if (item.type.toLowerCase() == 'song'){
                    var poop:String = item.text.toLowerCase();
        
                    if (item.modID == null){
                        Modding.modLoaded = false;
                        Modding.curLoaded = "";

                        PlayState.SONG = Song.loadFromJson(poop, poop);
                    }
                    else{
                        Modding.preloadData(item.modID);
                        Modding.modLoaded = true;
                        Modding.curLoaded = item.modID;

                        PlayState.SONG = Song.loadModChart(poop, poop);
                    }
                    
                    PlayState.songPlaylist.push({songName: item.text.toLowerCase(), modID: item.modID});

                    LoadingState.loadAndSwitchState(new PlayState());
                }
            }

            if (curSelected == item.ID + 1)
                item.alpha = 1;
            else
                item.alpha = 0.75;
        }
    }

    function getMenu(type:String){
        var thismenu:Array<MItemInf> = [];

        switch (type.toLowerCase()){
            case 'weeks':
                var vanillaweeks:WeekJson = Json.parse(File.getContent(Paths.json('weeks', 'preload')));
        
                for (week in vanillaweeks.weeks){
                    thismenu.push({type:'week', weekData: week, string: week.name});
                }
        
                for (mod in Modding.loadedMods){
                    if (FileSystem.isDirectory('mods/$mod/weeks') == true){
                        for (weekJson in FileSystem.readDirectory('mods/$mod/weeks/')){
                            if (weekJson != null && weekJson.contains('.json')){
                                var finalWeeks:WeekJson = Json.parse(File.getContent('mods/$mod/weeks/' + weekJson));
        
                                for (week in finalWeeks.weeks){
                                    thismenu.push({type:'week', weekData: week, string: week.name, modID: mod});
                                }
                            }
                        }
                    }
                }
            case 'songs':
                thismenu.push({type:'playall', string: 'Play All'});
                thismenu.push({type:'shuffle', string: 'Shuffle'});

                for (song in selectedWeek.songs){
                    thismenu.push({type: 'song', string: song, modID: selectedModID});
                }
        }

        return thismenu;
    }

    function generateMenu(items:Array<MItemInf>){
        for (member in menuItems.members){
            if (member != null){
                menuItems.remove(member);
                member.kill();
            }
        }

        for (member in playIcons){
            if (member != null){
                playIcons.remove(member);
                member.kill();
            }
        }

        var v:Int = 0;

        for (item in items){
            var weekData = item.weekData;

            var newItem:MenuItem = new MenuItem(32, (72 * v) + 32, item.string, item.type, item.weekData, item.modID);
            menuItems.add(newItem);
            newItem.ID = v;
            v++;

            if (item.type == 'week' && item.weekData != null){
                var icon = new HealthIcon(weekData.icon, false, weekData.iconIsJson, weekData.isMod , 0, 24 );
                icon.sprTracker = newItem;
                icon.setGraphicSize(Std.int(icon.width * 0.6));
                icon.updateHitbox();
    
                playIcons.add(icon);
            }
        }
    }

    function randomizeSongs(arr:Array<SongData>) {
        var randomizedArray = arr;
        var currentIndex = randomizedArray.length;
        var temporaryValue:Dynamic;
        var randomIndex: Int;
    
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