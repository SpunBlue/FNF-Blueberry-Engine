package engine.library;

import sys.io.File;
import openfl.media.Sound;
import flixel.graphics.FlxGraphic;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import openfl.display.BitmapData;
import openfl.utils.ByteArray;
import haxe.io.Path;
import sys.FileSystem;

typedef Data = {
    var path:String;
    var ?name:String;
    var ?type:String;
    var ?data:Bytes;
}

/**
 * API for loading Assets outside of the compiled game
 */
class Assets{
    /**
     * Compile a Map of assets within a library.
     * set `path` to root folder of library.
     * @param path Root Folder of Library.
     */
    public static function compileLibrary(path:String/*, ?preloadSpecific:Array<String>*/){
        var dataMap:Array<Data> = [];

        readDirectory(Path.directory(path), dataMap/*, preloadSpecific*/);

        var assetMap:AssetMap = new AssetMap(dataMap);
        return assetMap;
    }

    private static function readDirectory(path:String, dataMap:Array<Data>/*, ?specified:Array<String>*/):Void{
        var dirs = FileSystem.readDirectory(path);

        /*if (specified == null){
            #if debug
            trace('Specified is NULL!!!');
            #end
        }*/

        for (dir in dirs){
            if (dir != null){
                var fullDir:String = Path.directory('$path/$dir/');
    
                if (FileSystem.isDirectory(fullDir))
                    readDirectory(fullDir, dataMap);
                else
                    addPreload(fullDir, dataMap);
            }
        }
    }

    private static function isInArray(path:String, inArray:Array<String>):Bool {
        path = path.toLowerCase();
    
        var filteredData = inArray.filter(function(string) { return string.toLowerCase() == path; });
    
        if (filteredData.length > 0) {
            inArray.remove(filteredData[0]);
            return true;
        }
    
        return false;
    }

    private static function addPreload(fullDir:String, dataMap:Array<Data>){
        var data:ByteArray = null;

        data = sys.io.File.getBytes(fullDir);

        var data:Data = {
            path: fullDir,
            name: Path.withoutExtension(Path.withoutDirectory(fullDir)),
            type: Path.extension(Path.withoutDirectory(fullDir)),
            data: data
        };
        dataMap.push(data);
    }
}

/**
 * Only supposed to be used by AssetLibrary and Assets.
 */
class AssetMap{
    public var assMap:Array<Data> = [];

    /**
     * Create an AssetMap from a StringMap of Data.
     * @param map 
     * @see `Assets.compileLibrary`
     */
    public function new(map:Array<Data>){
        assMap = map;
    }
}

class AssetLibrary{
    public var map:Array<Data> = [];

    /**
     * Load a Asset Library from a `AssetMap`
     * @param assetMap Map of Assets
     * @see `Assets.compileLibrary`
     */
    public function new(?assetMap:AssetMap) {
        if (assetMap != null){
            map = assetMap.assMap;
        }
    }

    /**
     * Change the current Asset Map
     * @param assetMap 
     * @see `Assets.compileLibrary`
     */
    public function changeLibrary(assetMap:AssetMap){
        map = assetMap.assMap;
    }

    /**
     * Retrieve a Byte Array from a Asset in the currently loaded Library.
     * @param path Path to File, Name of File, or Type of File (Not Recommended).
     */
    public function getBytes(path:String){
        var result:Data = getData(path);

        return result;
    }

    /**
     * Retrives an Asset by automatically converting a Byte Array.
     * @param path Path to File, Name of File, or Type of File (Not Recommended).
     */
    public function getAsset(path:String):Dynamic{
        var result:Data = getData(path);
        var data:Dynamic = null;

        if (result != null){
            switch(result.type.toLowerCase()){
                case 'png' | 'jpg' | 'jpeg':
                    var graphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromBytes(result.data), false);
                    graphic.persist = true;

                    data = graphic;
                case 'ogg' | 'wav' | 'mp3':
                    data = Sound.fromAudioBuffer(AudioBuffer.fromBytes(result.data));
                case 'json' | 'txt' | 'xml' | 'hx' | 'lua':
                    data = Std.string(result.data);
                default:
                    trace('unable to detect type '+ result.type);
                    data = result.data;
            }
        }
        else{
            // trace('Data is null, attempting to load manually.');

            var extension:String = Path.extension(Path.withoutDirectory(path.toLowerCase()));

            switch(extension.toLowerCase()){
                case 'png' | 'jpg' | 'jpeg':
                    var graphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(path.toLowerCase()), false);
                    graphic.persist = true;

                    data = graphic;
                case 'ogg' | 'wav' | 'mp3':
                    data = Sound.fromAudioBuffer(AudioBuffer.fromFile(path.toLowerCase()));
                case 'json' | 'txt' | 'xml' | 'hx' | 'lua':
                    data = File.getContent(path.toLowerCase());
                default:
                    trace('unable to detect type '+ result.type);
                    data = result.data;
            }
        }

        return data;
    }

    private function getData(search:String):Data {
        search = search.toLowerCase();
    
        var filteredData = map.filter(function(data) return data.path.toLowerCase() == search);
    
        if (filteredData.length > 0) {
            return filteredData[0];
        }
    
        return null;
    }
}