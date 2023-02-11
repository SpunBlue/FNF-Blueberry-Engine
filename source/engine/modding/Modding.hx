package engine.modding;

import engine.library.SpunAssetLib.Assets;
import engine.library.SpunAssetLib.AssetLibrary;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;

class Modding {
    public static var loadedMods:Array<String> = [];
    public static var assetLibrary:AssetLibrary = new AssetLibrary();

    public static var curLoaded:String = null;
    public static var modLoaded:Bool = false;

    public static function init(){
        Engine.debugPrint('Initializing');

        if (FileSystem.readDirectory('mods/') != null){
            var modFolders:Array<String> = FileSystem.readDirectory('mods/');

            for (i in 0...modFolders.length){
                if (FileSystem.exists('mods/' + modFolders[i] + '/mod.json')){
                    for (shit in modFolders[i].split('/')){
                        if (shit != null && shit != '/' && shit != loadedMods[i])
                            loadedMods.push(shit);
                    }

                    Engine.debugPrint('Added Mod to List: ' + modFolders[i]);
                }
            }
        }
        else{
            return;
        }

        // Put this at the top so Week 7 is always at the beginning of the list.
        if (loadedMods.contains('week7')){
            var temp:String = loadedMods[0];
            var temp2:Int = loadedMods.indexOf('week7');
            loadedMods[0] = loadedMods[temp2];
            loadedMods[temp2] = temp;
        }
    }

    // Only keeping these functions because I don't want to rewrite a bunch of stuff.
    public static function retrieveContent(asset:String, library:String):String{
        return assetLibrary.getAsset(getFilePath(asset, library));
    }
    
    public static function retrieveAudio(asset:String, library:String = 'songs'){
        return assetLibrary.getAsset(getFilePath(asset + '.ogg', library));        
    }
    
    public static function retrieveImage(asset:String, library:String = 'images'){
        return assetLibrary.getAsset(getFilePath(asset + '.png', library));
    }

    public static function getFilePath(asset:String, library:String){
        return 'mods/$curLoaded/$library/$asset';
    }

    /**
     * Reloads the mod ID passed in the argument `mod`.
     */
     @:deprecated("`reloadMods() loads all mods, this is not recommended for performance at all.`")
    public static function reloadMods() {
        assetLibrary = new AssetLibrary(engine.library.SpunAssetLib.Assets.compileLibrary("mods/"));
    }

    /**
     * Preloads the Mod ID in the `mod` Argument.
     * @param mod Any Mod ID (Mod Folder)
     * @param specified Specified Paths to Preload
     */
    public static function preloadMod(mod:String){
        if (OptionsData.preloadMods)
            assetLibrary = new AssetLibrary(engine.library.SpunAssetLib.Assets.compileLibrary('mods/$mod/'));
    }

    public static function retrieveModName(id:String){
        var json = Json.parse(File.getContent('mods/$id/mod.json'));

        return json.name;
    }
}

