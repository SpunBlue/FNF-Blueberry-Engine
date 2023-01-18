package game;

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

using StringTools;

class FreeplayState extends MusicBeatState
{  
    var menuItems:FlxTypedGroup<MenuItem> = new FlxTypedGroup();
    var playIcons:FlxGroup = new FlxGroup();

    var curSelected:Int = 0;

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

        if (Conductor.bpm != 102)
            Conductor.changeBPM(102);
    }

    function getMenu(type:String){
        var thismenu:Array<MItemInf> = [];

        switch (type.toLowerCase()){
            case 'weeks':
                thismenu.push({type:'playall', string: 'Play All'});
                thismenu.push({type:'shuffle', string: 'Shuffle'});

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
        }

        return thismenu;
    }

    function generateMenu(items:Array<MItemInf>){
        for (member in menuItems.members){
            if (member != null){
                member.kill();
                menuItems.remove(member);
            }
        }

        for (item in items){
            var weekData = item.weekData;

            var newItem:MenuItem = new MenuItem(32, (72 * menuItems.members.length) + 32, item.string, item.type, item.weekData, item.modID);
            menuItems.add(newItem);

            if (item.type == 'week' && item.weekData != null){
                var icon = new HealthIcon(weekData.icon, false, weekData.iconIsJson, weekData.isMod, -24);
                icon.setGraphicSize(Std.int(icon.width * 0.5));
                icon.sprTracker = newItem;
    
                playIcons.add(icon);
            }
        }
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