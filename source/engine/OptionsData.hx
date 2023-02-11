package engine;

import engine.optionsMenu.OptionsMenu;
import flixel.FlxG;

class OptionsData
{
    public static var disableGhostTap:Bool = true;
    public static var downScroll:Bool = false;
    public static var middleScroll:Bool = false;
    public static var botplay:Bool = false;
    public static var debugMode = false;

    public static var distractions = true;
    public static var disableOutdatedScreen = false;

    public static var preloadMods:Bool = false; // Off by default, uses way too much memory.

    public static var gameplayOptions = engine.optionsMenu.OptionsMenu.gameplayOptions;
    public static var graphicsOptions = engine.optionsMenu.OptionsMenu.graphicsOptions;
    public static var moddingOptions = OptionsMenu.moddingOptions;

    public static function saveFromArray(array:Array<Dynamic>)
    {
        for (i in 0...array.length)
        {
            Reflect.setProperty(FlxG.save.data,array[i][2],Reflect.getProperty(engine.OptionsData,array[i][2]));
        }
    }

    public static function loadFromArray(array:Array<Dynamic>)
    {
        for (i in 0...array.length)
        {
            if (Reflect.getProperty(FlxG.save.data,array[i][2]) != null)
            {
                Reflect.setProperty(engine.OptionsData,array[i][2],Reflect.getProperty(FlxG.save.data,array[i][2]));
            }
        }
    }

    public static function dumpData()
    {
        #if android
        preloadMods = false;
        #end

        saveFromArray(gameplayOptions);
        saveFromArray(graphicsOptions);
        saveFromArray(moddingOptions);
    }

    public static function loadData()
    {
        #if android
        preloadMods = false;
        #end

        loadFromArray(gameplayOptions);
        loadFromArray(graphicsOptions);
        loadFromArray(moddingOptions);
    }
}
