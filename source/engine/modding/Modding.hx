package engine.modding;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import sys.io.FileInput;
import openfl.media.Sound;
import lime.graphics.Image;
import openfl.display.BitmapData;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;

class Modding {
    public var isInit:Bool = false;

    public static var loadedMods:Array<String> = [];
    public static var curLoaded:String;
    
    public static var modLoaded:Bool = false;

    public static var preloadedData:Array<FileData> = [];
    public static var modPreloaded:String;

    public static function init(){
        trace('Initializing');

        if (FileSystem.readDirectory('mods/') != null){
            var modFolders:Array<String> = FileSystem.readDirectory('mods/');

            for (i in 0...modFolders.length){
                if (FileSystem.exists('mods/' + modFolders[i] + '/mod.json')){
                    loadedMods.push(modFolders[i]);

                    if (File.getContent('mods/'+ modFolders[i] +'/mod.json') == ''){
                        File.saveContent('mods/'+ modFolders[i] +'/mod.json', Json.stringify({
                            "name": modFolders[i],
                            "description": "",
                            "author": "",
                            "version": "1.0"
                        }));
                    }

                    trace('Succesfully imported mod: ' + modFolders[i]);
                }
            }
        }
        else{
            return;
        }
    }

    public static function retrieveImage(assetid:String, library:String = 'images'){
        var asset = assetid.toLowerCase() + '.IMAGEASSET';
        var data:Dynamic = null;

        for (file in preloadedData){
            if (file != null && file.id == asset){
                trace("found preloaded data of type: " + asset);
                
                if (file.data != null){
                    data = file.data;
                }
                else{
                    trace('data is null wtf???');
                }
            }
        }

        if (data != null){
            var returnData:FlxGraphic = data;

            return returnData;
        }
        else{
            trace("couldn't find preloaded data of type: " + asset);
            return FlxGraphic.fromBitmapData(BitmapData.fromFile('mods/$curLoaded/$library/$assetid.png'), false);
        }
    }
    
    public static function retrieveAudio(assetid:String, library:String = 'songs'){
        var asset = assetid.toLowerCase();
        var data:Dynamic = null;

        for (file in preloadedData){
            if (file != null && file.id == asset){
                trace("found preloaded data of type: " + asset);
    
                if (file.data != null){
                    data = file.data;
                }
                else{
                    trace('data is null wtf???');
                }
            }
        }

        if (data != null){
            return data;
        }
        else{
            trace("couldn't find preloaded data of type: " + asset);
            return Sound.fromFile('mods/$curLoaded/$library/$asset.ogg');
        }
    }

    public static function retrieveTextArray(asset:String, library:String):Array<String>
    {
        var daList:Array<String> = File.getContent('mods/$curLoaded/$library/$asset').split('\n');
    
        return daList;
    }

    public static function retrieveContent(assetid:String, library:String):String{
        var asset = assetid.toLowerCase();
        var data:Dynamic = null;

        for (file in preloadedData){
            if (file != null && file.id == asset){
                trace("found preloaded data of type: " + asset);
    
                if (file.data != null){
                    data = file.data;
                }
                else{
                    trace('data is null wtf???');
                }
            }
        }

        if (data != null){
            return data;
        }
        else{
            trace("couldn't find preloaded data of type: " + asset);
            return File.getContent('mods/$curLoaded/$library/$assetid');
        }
    }

    public static function getFilePath(asset:String, library:String){
        return 'mods/$curLoaded/$library/$asset';
    }

    /*public static function modCharacterArray():Array<Dynamic>{ // not tested
        var charList:Array<String> = [];

        if (FileSystem.exists('mods/$curLoaded/data/characters/') && FileSystem.readDirectory('mods/$curLoaded/data/characters/') != null){
            for (char in FileSystem.readDirectory('mods/$curLoaded/data/characters/')){
                var temp:Array<String> = [];

                temp = char.split('.json');
                temp.remove('.json');

                charList.push(temp.toString());
            }

            return charList;
        }
        else
            return [];
    }*/

    public static function preloadData(mod:String = null){
        if (mod == null)
            mod = curLoaded;

        if (modPreloaded == mod){
            return;
        }
        else{
            // Preload images in folders "images/characters" and "images/icons".
            for (file in FileSystem.readDirectory('mods/$mod/images/characters/')){
                var fileArray:Array<String> = file.split('.'); // stupid but works

                if (fileArray[1].toLowerCase() == 'png'){
                    var fileName:String = fileArray[0].toLowerCase();

                    trace('preloading data of $fileName');

                    var funniAsset:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile('mods/$mod/images/characters/$file'), false, '$fileName');
                    funniAsset.persist = true;

                    preloadedData.push({id: '$fileName.IMAGEASSET', data: funniAsset});
                }
            }

            for (file in FileSystem.readDirectory('mods/$mod/images/icons/')){
                var fileArray:Array<String> = file.split('.'); // stupid but works

                if (fileArray[1].toLowerCase() == 'png'){
                    var fileName:String = fileArray[0].toLowerCase();

                    trace('preloading data of $fileName');

                    var funniAsset:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile('mods/$mod/images/icons/$file'), false, '$fileName');
                    funniAsset.persist = true;

                    preloadedData.push({id: '$fileName.IMAGEASSET', data: funniAsset});
                }
            }

            // Preload TXT's and XML's in "images/characters".
            for (file in FileSystem.readDirectory('mods/$mod/images/characters/')){
                var fileArray:Array<String> = file.split('.'); // stupid but works

                if (fileArray[1].toLowerCase() == 'xml' /*|| fileArray[1].toLowerCase() == 'txt'*/){
                    var fileName:String = fileArray[0].toLowerCase() + '.' + fileArray[1].toLowerCase();

                    trace('preloading data of $fileName');

                    preloadedData.push({id: '$fileName', data: File.getContent('mods/$mod/images/characters/$file')});
                }
            }

            // Preload JSON's (Not Charts though)
            for (file in FileSystem.readDirectory('mods/$mod/data/characters/')){
                var fileArray:Array<String> = file.split('.'); // stupid but works

                if (fileArray[1].toLowerCase() == 'json'){
                    var fileName:String = fileArray[0].toLowerCase() + '.' + fileArray[1].toLowerCase();

                    trace('preloading data of $fileName');

                    preloadedData.push({id: '$fileName', data: File.getContent('mods/$mod/data/characters/$file')});
                }
            }

            // Preload Songs (Probably won't do this)
            // newsflash: i didn't do it lol

            modPreloaded = mod;
        }
    }
}

typedef FileData = {
    var id:String;
	var data:Dynamic;
}