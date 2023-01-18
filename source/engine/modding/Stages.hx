package engine.modding;

import haxe.Json;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

class Stages{
    public static var stageJson = null;
    public static var stageJsonArray:Array<StageObjects> = [];
    public static var stageName:String;

    static public function init(stageName:String){
        if (stageJson == null)
            stageJson = Json.parse(Modding.retrieveContent(stageName, 'data/stages'));

        stageName = stageJson.name;

        stageJsonArray = stageJson.objects;
    }
}

typedef StageObjects = {
    var image:String;
    var ?isAnimated:Bool;
    var ?playOnBeat:Bool;
    var ?animations:Array<StageObjectAnimations>;
    var ?layer:Int; // 0 = behind all, 1 = infront of GF, 2 = infront of dad & bf
}

typedef StageObjectAnimations = {
    var xmlanim:String;
    var name:String;
    var fps:Int;
    //var ?loop:Bool; not adding lol
}