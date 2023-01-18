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
    }

    override function update(elapsed:Float){
        Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);

        if (Conductor.bpm != 102)
            Conductor.changeBPM(102);
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

class MenuItem extends FlxText{
    public var weekData:WeekData;
    public var type:String;
    public var modID:String;


    public function new(x:Float, y:Float, text:String, type:Dynamic, ?weekData:WeekData, ?modID:String, size:Int = 64, facing:FlxTextAlign = LEFT){
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