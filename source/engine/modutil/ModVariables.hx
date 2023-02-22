package engine.modutil;

import haxe.io.Path;
import sys.FileSystem;
import engine.modding.SpunModLib.ModLib;
import engine.modding.SpunModLib.ModAssets;
import Character.CharJson;

typedef EventListData = {
    var eventName:String;
    var ?var1Hint:String;
    var ?var2Hint:String;
    var ?var3Hint:String;
    var ?var4Hint:String;
    var ?var5Hint:String;
    var ?info:String;
}

class ModVariables{
    public static var characters:Map<String, CharJson> = new Map();

    public static var characterList:Array<String>;
    public static var stageList:Array<String>;

    public static var validEvents:Array<EventListData> = [
        {eventName: "setZoom", var1Hint: "Which Camera? ('game' or 'hud').", var2Hint: "New Zoom Amount.", var3Hint: "Immediate Zoom? ('true', 'false', or blank)."},
        {eventName: "beatZoom", var1Hint: "Which Camera? ('game' or 'hud').", var2Hint: "How much zoom to add."},
        {eventName: "playAnimation", var1Hint: "Which Character? ('dad' or 'bf).", var2Hint: 'Animation to play.'},
        /*
        {eventName: "addCharacter", var1Hint: "Character Name.", var2Hint: "Which type? ('dad' or 'bf').", var3Hint: "Character ID."},
        {eventName: "deleteCharacter", var1Hint: "Character ID.", var2Hint: "Which type? ('dad' or 'bf')."},
        {eventName: "swapCharacter", var1Hint: "'dad' or 'bf'", var2Hint: "Character Name.", info: "Swaps the main dad/bf with a new Character."}
        */
        {eventName: "runScript", var1Hint: "Script Path. (Ex: 'data/event.hx')."}
    ];

    public static function reset(){
        characters.clear();
        characterList = null;
        stageList = null;
    }

    public static function updateCharacterList(){
        characterList = [];
        readDirectory(ModAssets.getPath('data/characters/', ModLib.curMod, null, null, false), characterList);
    }

    public static function updateStageList(){
        stageList = [];
        readDirectory(ModAssets.getPath('data/characters/', ModLib.curMod, null, null, false), stageList);
    }

    private static function readDirectory(path:String, array:Array<String>){
        var paths:Array<String> = [];
        
        if (path != null && path.length > 0)
            paths = FileSystem.readDirectory(path);
        else
        {
            trace('Bruh "$path" is empty/null');

            return;
        }
        
        if (paths != null && paths.length > 0){
            for(file in paths){
                if (file != null){
                    if (Path.extension(file).toLowerCase() == 'json'){
                        array.push(Path.withoutExtension(Path.withoutDirectory(file)));
                    }
                    else if (FileSystem.isDirectory(Path.normalize('$path/$file'))){
                        readDirectory(Path.normalize('$path/$file'), array);
                    }
                    else{
                        trace('Failed to read character in $path. Result: $file.');
                    }
                }
            }
        }
        else
            return;
    }
}

typedef ModDevSettings = {
    var dependencies:Array<String>; // Mod ID's
    var credits:Array<Credit>; // Credits
}

typedef Credit = {
    var name:String; // Name of person
    var ?link:String; // Link to person
    var workedOn:String; // What that person did
}