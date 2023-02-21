package engine.modutil;

import haxe.io.Path;
import sys.FileSystem;
import engine.modding.SpunModLib.ModLib;
import engine.modding.SpunModLib.ModAssets;
import Character.CharJson;

class ModVariables{
    public static var characters:Map<String, CharJson> = new Map();

    public static var characterList:Array<String>;
    public static var stageList:Array<String>;

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