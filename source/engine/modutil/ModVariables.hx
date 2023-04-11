package engine.modutil;

import engine.modding.SpunModLib.Mod;
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

typedef MData = {
    var mod:Mod;
    var string:String;
}

class ModVariables{
    public static var characters:Map<MData, CharJson> = new Map();

    public static var characterList:Array<MData>;
    public static var stageList:Array<MData>;

    public static var validEvents:Array<EventListData> = [
        {eventName: "setZoom", var1Hint: "Which Camera? ('game' or 'hud').", var2Hint: "New Zoom Amount.", var3Hint: "Immediate Zoom? ('true', 'false', or blank)."},
        {eventName: "beatZoom", var1Hint: "Which Camera? ('game' or 'hud').", var2Hint: "How much zoom to add."},
        {eventName: "playAnimation", var1Hint: "Which Character? ('dad' or 'bf).", var2Hint: 'Animation to play.'},
        {eventName: "swapCharacter", var1Hint: "'dad' or 'bf'", var2Hint: "Character Name.", info: "Swaps the main dad/bf with a new Character."},
        {eventName: "addCharacter", var1Hint: "Character Name.", var2Hint: "Which type? ('dad' or 'bf').", var3Hint: "Character ID.", var4Hint: "X Offset", var5Hint: "Y Offset"},
        {eventName: "deleteCharacter", var1Hint: "Character ID.", var2Hint: "Which type? ('dad' or 'bf')."},
        {eventName: "selectCharacter", var1Hint: "Character ID.", var2Hint: "Which type? ('dad' or 'bf').", info: "Select a Character from a specified ID to sing."},
        {eventName: "playAnimCharID", var1Hint: "Character ID.", var2Hint: "Which type? ('dad' or 'bf').", var3Hint: "Animation Name.",info: "Play Animation on a specific Character from ID."},
        {eventName: "runScript", var1Hint: "Script Path. (Ex: 'data/event.hx').", var2Hint: "Mod ID, leave blank for default."}
    ];

    public static function reset(){
        // n/a
    }

    /**
     * Not modifying SpunModLib for this lol
     */
    public static function loadMod(){
        updateCharacterList();
        updateStageList();
    }

    public static function updateCharacterList(){
        if (characterList == null)
            characterList = [];

        for (mod in ModLib.mods){
            readDirectory(ModAssets.getPath('data/characters/', mod, null, null, false), characterList, mod);
        }
    }

    public static function updateStageList(){
        if (stageList == null)
            stageList = [];
        
        for (mod in ModLib.mods){
            readDirectory(ModAssets.getPath('data/stages/', mod, null, null, false), stageList, mod, 'hx');    
        }
    }

    private static function readDirectory(path:String, array:Array<MData>, mod:Mod, ext:String = 'json'){
        var paths:Array<String> = [];
        
        if (path != null && path.length > 0 && FileSystem.exists(path))
            paths = FileSystem.readDirectory(path);
        else
        {
            trace('Bruh "$path" is empty/null');

            return;
        }
        
        if (paths != null && paths.length > 0){
            for(file in paths){
                if (file != null){
                    if (Path.extension(file).toLowerCase() == ext.toLowerCase()){
                        array.push({string: Path.withoutExtension(Path.withoutDirectory(file)), mod: mod});
                    }
                    else if (FileSystem.isDirectory(Path.normalize('$path/$file'))){
                        readDirectory(Path.normalize('$path/$file'), array, mod);
                    }
                    else{
                        trace('Failed at $path. Result: $file.');
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