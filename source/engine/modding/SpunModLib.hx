package engine.modding;

import haxe.Json;
import sys.io.File;
import haxe.io.Path;
import openfl.Assets;
import sys.FileSystem;
import openfl.media.Sound;
import flixel.system.FlxSound;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

class ModLib{
    public static var mods:Map<String, Mod> = new Map();

    /**
     * I recommend using `setMod()` to set this variable, but you can set this manually too if you want.
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
                        trace('Attempting to load \"$fullPath\", ' + modFolders[i] + ' at: ' + Path.normalize(fullPath + '/mod.json'));

                        var json:ModJSON = Json.parse(File.getContent(Path.normalize(fullPath + '/mod.json')));
                        var thisID:String = null;

                        if (json != null && json.id != null)
                            thisID = json.id;

                        if (thisID != null && !mods.exists(thisID))
                            mods.set(thisID, {folder: modFolders[i], rootDir: fullPath, id: thisID});
                        else{
                            #if debug
                            if (mods.exists(thisID))
                                trace('HALT! Cannot save Mod when Mod using same ID exists, USING DEPRECATED METHOD OF SAVING MOD.');
                            else
                                trace('COULD NOT DETECT MOD ID!!! USING DEPRECATED METHOD OF SAVING MOD.');
                            #end

                            if (!mods.exists(modFolders[i])) // since you can save multiple mods to the map in different folders, user can have something with the same id as the folder name.
                                mods.set(modFolders[i], {folder: modFolders[i], rootDir: fullPath, id: modFolders[i]});
                            else{
                                trace('IMPORTANT: Cannot set mod. Mod with ID and Folder Name already exists, no other methods are avaliable.');
                            }
                        }
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
     * Reset the current Mods loaded in the `mods` Map Variable.
     */
    public static function reset(){
        curMod = null;
        mods = new Map();
    }

    /**
     * Self explanatory.
     * @deprecated Ended up being useless to me, but hey you might need it.
     */
     @:deprecated
    public static function getModFolder(mod:Mod){
        if (mod != null)
            return mod.folder;

        return null;
    }

    /**
     * @param mod
     * @deprecated Ended up being useless to me, but hey someone might need it.
     */
     @:deprecated
    public static function getModFolderByID(modID:String){
        if (mods.exists(modID))
            return mods.get(modID).folder;

        return null;
    }

    /**
     * @param mod 
     */
    public static function getModID(mod:Mod){
        if (mod != null)
            return mod.id;

        return null;
    }
}

class ModAssets{
    private static var supportExt:Array<String> = ['txt', 'json', 'hx', 'lua', 'xml', 'png', 'jpg', 'jpeg', 'mp3', 'ogg', 'wav'];

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
     * Retrieve the Path to a directory or asset.
     * @param path Path
     * @param mod Mod Data
     * @param modID Mod ID
     * @param addDir Additional Directory
     * @param onFailPullAssets If enabled, if failed to find directory/file in mod it will pull from the Assets Folder in the base-game.
     */
    public static function getPath(path:String, ?mod:Mod, ?modID:String, ?addDir:String, ?onFailPullAssets:Bool = true):String{
        if (addDir == null)
            addDir = '';

        var fullPath:String = path;
        
        if (mod != null)
            fullPath = mod.rootDir + '/$path';
        else if (modID != null){
            var goofyMod:Mod = findMod(modID);

            fullPath = goofyMod.rootDir + '/$path';
        }

        fullPath = Path.normalize(fullPath);

        trace(fullPath);

        if ((!FileSystem.exists(fullPath) || mod == null && modID == null) && onFailPullAssets){
            if (mod != null || modID != null)
                trace('Directory $fullPath does not exist.');

            fullPath = Path.normalize('assets/$addDir/$path');

            if (!FileSystem.exists(fullPath))
                return null;
        }

        return fullPath;
    }

    private static function isValidExt(ext:String){
        for (exten in supportExt){
            if (exten.toLowerCase() == ext.toLowerCase()){
                return true;
                break;
            }
        }

        return false;
    }

    /**
     * Returns an Asset (Bytes, String, FlxGraphic, Etc.) from a `Mod` unless both `mod` and `modID` variables are null,
     * If both are null or file could not be found, it will return an asset from the `assets` folder.
     * @param path Path (images/test.png). Don't include root directory.
     * @param mod Mod Data
     * @param modID Mod ID, leave `mod` as `null` to use.
     * @param additionalDirOnFail If the asset could not be located in the Mod's directory, Instead of using the regular `assets` path, it will add an additional string after the `assets/`. Example: `assets/shared` `shared` being the string added.
     * @param onFailPullAssets If enabled, if failed to find directory/file in mod it will pull from the Assets Folder in the base-game.
     */
    public static function getAsset(path:String, ?mod:Mod, ?modID:String, ?additionDirOnFail:String, ?onFailPullAssets:Bool = true):Dynamic{
        #if debug
        trace('File to load: ' + path + ' - path may not be accurate to final path.');
        #end

        var ext:String = Path.extension(path).toLowerCase();

        switch (ext){
            default:
                var fullPath:String = getPath(path, mod, modID, additionDirOnFail);

                #if debug
                trace('Attempting to return bytes');
                #end

                if (FileSystem.exists(fullPath))
                    return File.getBytes(fullPath);
                else{
                    #if debug
                    trace('Returning Null');
                    #end

                    return null;
                }
            case 'png' | 'jpg' | 'jpeg':
                return getGraphic(path, mod, modID, additionDirOnFail, onFailPullAssets);
            case 'txt' | 'json' | 'hx' | 'lua' | 'xml':
                return getContent(path, mod, modID, additionDirOnFail, onFailPullAssets);
            case 'ogg' | 'wav' | 'mp3':
                return getSound(path, mod, modID, additionDirOnFail, onFailPullAssets);
        }
    }

    /**
     * Only get content, you can also use the `getAsset` function which is universal.
     * @param path Path (data/text.json). Don't include root directory.
     * @param mod Mod Data
     * @param modID Mod ID, leave `mod` as `null` to use.
     * @param additionalDirOnFail If the asset could not be located in the Mod's directory, Instead of using the regular `assets` path, it will add an additional string after the `assets/`. Example: `assets/shared` `shared` being the string added.
     * @param onFailPullAssets If enabled, if failed to find directory/file in mod it will pull from the Assets Folder in the base-game.
     */
    public static function getContent(path:String, ?mod:Mod, ?modID:String, ?additionDirOnFail:String, ?onFailPullAssets:Bool = true){
        var path:String = getPath(path, mod, modID, additionDirOnFail, onFailPullAssets);
        trace(path);

        var ext:String = Path.extension(path).toLowerCase();

        if (isValidExt(ext)){
            if ((ext == 'txt' || ext == 'json' || ext == 'hx' || ext == 'lua' || ext == 'xml') && FileSystem.exists(path)){
                return File.getContent(path);
            }
        }

        #if debug
        trace('err');
        #end

        return null;
    }

    /**
     * Only get sound, you can also use the `getAsset` function which is universal.
     * @param path Path (sounds/test.ogg). Don't include root directory.
     * @param mod Mod Data
     * @param modID Mod ID, leave `mod` as `null` to use.
     * @param additionalDirOnFail If the asset could not be located in the Mod's directory, Instead of using the regular `assets` path, it will add an additional string after the `assets/`. Example: `assets/shared` `shared` being the string added.
     * @param onFailPullAssets If enabled, if failed to find directory/file in mod it will pull from the Assets Folder in the base-game.
     */
    public static function getSound(path:String, ?mod:Mod, ?modID:String, ?additionDirOnFail:String, ?onFailPullAssets:Bool = true){
        var path:String = getPath(path, mod, modID, additionDirOnFail, onFailPullAssets);
        trace(path);

        var ext:String = Path.extension(path).toLowerCase();

        if (isValidExt(ext)){
            if ((ext == 'ogg' || ext == 'wav' || ext == 'mp3') && FileSystem.exists(path)){
                return Sound.fromFile(path);
            }
        }

        #if debug
        trace('err');
        #end

        return null;
    }

    /**
     * Only get graphic, you can also use the `getAsset` function which is universal.
     * @param path Path (images/test.png). Don't include root directory.
     * @param mod Mod Data
     * @param modID Mod ID, leave `mod` as `null` to use.
     * @param additionalDirOnFail If the asset could not be located in the Mod's directory, Instead of using the regular `assets` path, it will add an additional string after the `assets/`. Example: `assets/shared` `shared` being the string added.
     * @param onFailPullAssets If enabled, if failed to find directory/file in mod it will pull from the Assets Folder in the base-game.
     */
    public static function getGraphic(path:String, ?mod:Mod, ?modID:String, ?additionDirOnFail:String, ?onFailPullAssets:Bool = true){
        var path:String = getPath(path, mod, modID, additionDirOnFail, onFailPullAssets);
        trace(path);

        var ext:String = Path.extension(path).toLowerCase();

        if (isValidExt(ext)){
            if ((ext == 'png' || ext == 'jpg' || ext == 'jpeg') && FileSystem.exists(path)){
                var temp:FlxGraphic;

                if (!Assets.cache.hasBitmapData(path))
                    temp = FlxGraphic.fromBitmapData(BitmapData.fromFile(path), false, path, true)
                else
                    temp = FlxGraphic.fromBitmapData(Assets.cache.getBitmapData(path), false, '', false);

                return temp;
            }
        }

        #if debug
        trace('err');
        #end

        return null;
    }

    /**
     * Only get sparrow atlas, you can also use the `getAsset` function which is universal.
     * @param path Path (images/test.png and images/test.xml). Don't include root directory.
     * @param mod Mod Data
     * @param modID Mod ID, leave `mod` as `null` to use.
     * @param additionalDirOnFail If the asset could not be located in the Mod's directory, Instead of using the regular `assets` path, it will add an additional string after the `assets/`. Example: `assets/shared` `shared` being the string added.
     * @param onFailPullAssets If enabled, if failed to find directory/file in mod it will pull from the Assets Folder in the base-game.
     */
	inline static public function getSparrowAtlas(path:String, ?mod:Mod, ?modID:String, ?additionDirOnFail:String, ?onFailPullAssets:Bool = true){
        return FlxAtlasFrames.fromSparrow(getGraphic('$path.png', mod, modID, additionDirOnFail, onFailPullAssets), getContent('$path.xml', mod, modID, additionDirOnFail, onFailPullAssets));
    }

    /**
     * Only get packer atlas, you can also use the `getAsset` function which is universal.
     * @param path Path (images/test.png and images/test.txt). Don't include root directory.
     * @param mod Mod Data
     * @param modID Mod ID, leave `mod` as `null` to use.
     * @param additionalDirOnFail If the asset could not be located in the Mod's directory, Instead of using the regular `assets` path, it will add an additional string after the `assets/`. Example: `assets/shared` `shared` being the string added.
     * @param onFailPullAssets If enabled, if failed to find directory/file in mod it will pull from the Assets Folder in the base-game.
     */
    inline static public function getPackerAtlas(path:String, ?mod:Mod, ?modID:String, ?additionDirOnFail:String, ?onFailPullAssets:Bool = true){
        return FlxAtlasFrames.fromSpriteSheetPacker(getGraphic('$path.png', mod, modID, additionDirOnFail, onFailPullAssets), getContent('$path.txt', mod, modID, additionDirOnFail, onFailPullAssets));
    }

    /**
     * Looks for an asset and returns `true` if found, looks in the `Mod` unless both `mod` and `modID` variables are null,
     * If both are null or file could not be found, it will return an asset from the `assets` folder.
     * @param path Path (images/test.png). Don't include root directory.
     * @param mod Mod Data
     * @param modID Mod ID, leave `mod` as `null` to use.
     * @param additionalDirOnFail If the asset could not be located in the Mod's directory, Instead of using the regular `assets` path, it will add an additional string after the `assets/`. Example: `assets/shared` `shared` being the string added.
     * @param onFailPullAssets If enabled, if failed to find directory/file in mod it will pull from the Assets Folder in the base-game.
     */
    public static function assetExists(path:String, ?mod:Mod, ?modID:String, ?additionDirOnFail:String, ?onFailPullAssets:Bool = true):Bool{
        var fullPath:String = getPath(path, mod, modID, additionDirOnFail, onFailPullAssets);

        #if debug
        trace('Checking for file: ' + fullPath);
        #end

        if (FileSystem.exists(fullPath))
            return true;

        return false;
    }
}

/**
 * Mod Typedef.
 * @param folder Folder of Mod
 * @param id ID System, used when getting mod folder.
 */
typedef Mod = {
    var folder:String;
    var ?id:String;
    var rootDir:String;
}

typedef ModJSON = {
    var name:String;
    var id:String; // Identification for this Mod.
    var description:String;
    var author:String;
    var ?version:String;
    var ?ModEngineVersion:String; // might not end up using this.
}

// if you're reading this, i assume you are interested in how my mod system works. hi there, lol!!!