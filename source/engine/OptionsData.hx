package engine;

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

    public static var gameplayOptions = engine.optionsMenu.OptionsMenu.gameplayOptions;
    public static var graphicsOptions = engine.optionsMenu.OptionsMenu.graphicsOptions;

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
        saveFromArray(gameplayOptions);
        saveFromArray(graphicsOptions);
    }

    public static function loadData()
    {
        loadFromArray(gameplayOptions);
        loadFromArray(graphicsOptions);
    }
}
