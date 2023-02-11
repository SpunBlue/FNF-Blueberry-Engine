package engine.modding;

import game.PlayState;
import haxe.Json;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

class Stages{
    public static var stageJson:StageObjectJson = null;
    public static var stageArray:Array<StageObj> = [];
    public static var stageName:String;

    static public function init(stage:String){
        if (stageJson == null)
            stageJson = Json.parse(Modding.retrieveContent(stage + '.json', 'data/stages'));

        if (stageJson.stageName != null)
            stageName = stageJson.stageName;
        else
            stageName = stage;

        stageArray = stageJson.objects;
    }

    static public function reset(){
        stageJson = null;
        stageArray = [];
        stageName = null;

        PlayState.curStage = '';
    }
}

class StageObject extends FlxSprite{
    public var stageObject:StageObj;

    public function new(X:Float, Y:Float, stageObject:StageObj){
        super(X, Y);

        this.stageObject = stageObject;
    }
}

typedef StageObjectJson = {
    var ?stageName:String;
    var objects:Array<StageObj>;
    var ?disableAntialiasing:Bool;
    var ?camZoom:Float;
    var ?bfPosition:Array<Int>;
    var ?gfPosition:Array<Int>;
    var ?dadPosition:Array<Int>;
}

typedef StageObj = {
    var name:String;
    var image:String;
    var ?xmlPath:String;
    var ?position:Array<Float>;
    var ?scrollFactor:Array<Float>;
    var xmlanim:String;
    var animName:String;
    var fps:Int;
    var ?loop:Bool;
    var ?indices:Array<Int>;
    var ?playOn:String;
    var ?isAnimated:Bool;
    var ?layer:Int; // 0 = behind all, 1 = infront of GF, 2 = infront of dad & bf
    var ?isDistraction:Bool;
	var ?scale:Array<Float>;
	var ?flipX:Bool;
	var ?flipY:Bool;
	var ?size:Float;
	var ?blend:String;
	var ?alpha:Float;
    var ?antialiasing:Bool;
}