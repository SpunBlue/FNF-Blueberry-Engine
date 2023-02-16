package engine.modding;

import openfl.Assets;
import openfl.media.Sound;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;

class ModLib{
    public static var mods:Map<String, Mod> = new Map();

    /**
     * I recommend using `setMod()` but you can set this manually too if you want.
     * @see `setMod()`
     */
    public static var curMod:Mod = null;

    /**
     * Default callback after running the `setMod()` function.
     */
    public static var default_setMod_callback:Void -> Void;

    /**
     * Detect mods in Path
     * @param path Path to Mods Folder
     */
    public static function readMods(path:String){
        if (FileSystem.readDirectory(path) != null){
            var modFolders:Array<String> = FileSystem.readDirectory(path);
            var fullPath:String = '';

            for (i in 0...modFolders.length){
                fullPath = Path.normalize('$path/' + modFolders[i]);

                if (FileSystem.exists(fullPath + '/mod.json')){
                    try{
                        trace('Attempting to load \"$fullPath\", ' + modFolders[i]);
                        mods.set(modFolders[i], {id: modFolders[i], rootDir: fullPath});
                    }
                    catch(e:Dynamic){
                        trace('Error while loading Mod: $e');
                    }
                }
                else{
                    trace('Mod at $fullPath could not be found, or loaded.');
                }
            }
        }
        else{
            trace('Root of $path does not exist.');
            return;
        }
    }

    /**
     * Set the current Mod or reset.
     * @param modID The Mod ID, leave blank to reset all.
     * @param skipCallback Skip the callback, needed if you have a default callback.
     * @param callback The function to run after completing this function, Leave blank for none or to use default.
     * @see `default_setMod_callback`
     */
    public static function setMod(?modID:String, ?skipCallback:Bool = false, ?callback:Void -> Void):Void{
        if (modID != null && mods.exists(modID))
            curMod = mods.get(modID);
        else 
            curMod = null;

        if (!skipCallback){
            if (callback != null)
                callback();
            else if (callback == null && default_setMod_callback != null)
                default_setMod_callback();
        }
    }

    /**
     * Reset the current Mod loaded in the `curMod` Variable.
     * @param undetect Remove all of the detected mods from the `mods` Map.
     * @deprecated Just run `setMod`, It's used for setting and resetting, plus it has more flexibility.
     */
    @:deprecated
    public static function reset(?undetect:Bool = false){
        curMod = null;

        if (undetect)
            mods = new Map();
    }
}

class ModAssets{
    /**
     * Find a Mod by the ID.
     * @param id ID of Mod.
     */
    public static function findMod(id:String):Mod{
        // Find the mod with the specified ID
        var foundMod = ModLib.mods.get(id);

        #if debug
        trace('Mod Found: $foundMod');
        #end

        return foundMod;
    }

    /**
     * Returns an Asset (Bytes, String, FlxGraphic, Etc.) from a `Mod` unless both `mod` and `modID` variables are null,
     * If both are null or file could not be found, it will return an asset from the `assets` folder.
     * @param path Path (images/test.png). Don't include root directory.
     * @param mod Mod Data
     * @param modID Mod ID, leave `mod` as `null` to use.
     * @param additionalDirOnFail If the asset could not be located in the Mod's directory, Instead of using the regular `assets` path, it will add an additional string after the `assets/`. Example: `assets/shared` `shared` being the string added.
     */
    public static function getAsset(path:String, ?mod:Mod, ?modID:String, ?additionDirOnFail:String):Dynamic{
        if (additionDirOnFail == null)
            additionDirOnFail = '';

        var fullPath:String = path;
        
        if (mod != null)
            fullPath = mod.rootDir + '/$path';
        else if (modID != null){
            var goofyMod:Mod = findMod(modID);

            fullPath = goofyMod.rootDir + '/$path';
        }

        fullPath = Path.normalize(fullPath);

        if (!FileSystem.exists(fullPath) || mod == null && modID == null)
            fullPath = Path.normalize('assets/$additionDirOnFail/$path');

        #if debug
        trace('File to load: ' + fullPath);
        #end

        var ext:String = Path.extension(path).toLowerCase();

        switch (ext){
            default:
                if (FileSystem.exists(fullPath))
                    return File.getBytes(fullPath);
                else{
                    #if debug
                    trace('Returning Null');
                    #end

                    return null;
                }
            case 'png' | 'jpg' | 'jpeg':
                var temp:FlxGraphic;

                if (!Assets.cache.hasBitmapData(fullPath))
                    temp = FlxGraphic.fromBitmapData(BitmapData.fromFile(fullPath), false, fullPath, true)
                else
                    temp = FlxGraphic.fromBitmapData(Assets.cache.getBitmapData(fullPath), false, '', false);

                return temp;
            case 'txt' | 'json' | 'hx' | 'lua':
                return File.getContent(fullPath);
            case 'ogg' | 'wav' | 'mp3':
                return Sound.fromFile(fullPath);
        }
    }

    /**
     * Looks for an asset and returns `true` if found, looks in the `Mod` unless both `mod` and `modID` variables are null,
     * If both are null or file could not be found, it will return an asset from the `assets` folder.
     * @param path Path (images/test.png). Don't include root directory.
     * @param mod Mod Data
     * @param modID Mod ID, leave `mod` as `null` to use.
     * @param additionalDirOnFail If the asset could not be located in the Mod's directory, Instead of using the regular `assets` path, it will add an additional string after the `assets/`. Example: `assets/shared` `shared` being the string added.
     */
    public static function assetExists(path:String, ?mod:Mod, ?modID:String, ?additionDirOnFail:String):Bool{
        if (additionDirOnFail == null)
            additionDirOnFail = '';

        var fullPath:String = path;
        
        if (mod != null)
            fullPath = mod.rootDir + '/$path';
        else if (modID != null){
            var goofyMod:Mod = findMod(modID);

            fullPath = goofyMod.rootDir + '/$path';
        }

        fullPath = Path.normalize(fullPath);

        if (!FileSystem.exists(fullPath) || mod == null && modID == null)
            fullPath = Path.normalize('assets/$additionDirOnFail/$path');

        #if debug
        trace('Checking for file: ' + fullPath);
        #end

        if (FileSystem.exists(fullPath))
            return true;

        return false;
    }
}

typedef Mod = {
    var id:String;
    var rootDir:String;
}