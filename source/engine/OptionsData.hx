package engine;

import flixel.FlxG;

class OptionsData
{
    public static var disableGhostTap = true;
    public static var downScroll = false;
    public static var middleScroll = false;
    public static var botplay = false;
    public static var debugMode = false;

    public static var noDistractions = false;
    public static var disableOutdatedScreen = false;

    public static function dumpData()
    {
        FlxG.save.data.disableGhostTap = disableGhostTap;
        FlxG.save.data.downScroll = downScroll;
        FlxG.save.data.middleScroll = middleScroll;
        FlxG.save.data.botplay = botplay;

        FlxG.save.data.noDistractions = noDistractions;
        FlxG.save.data.disableOutdatedScreen = disableOutdatedScreen;
    }


    public static function loadData()
    {
        if (FlxG.save.data.disableGhostTap != null)
        {
            disableGhostTap = FlxG.save.data.disableGhostTap;
        }
        if (FlxG.save.data.downScroll != null)
        {
            downScroll = FlxG.save.data.downScroll;
        }
        if (FlxG.save.data.middleScroll != null)
        {
            middleScroll = FlxG.save.data.middleScroll;
        }
        if (FlxG.save.data.botplay != null)
        {
            botplay = FlxG.save.data.botplay;
        }
        if (FlxG.save.data.noDistractions != null)
        {
            noDistractions = FlxG.save.data.noDistractions;
        }
        if (FlxG.save.data.disableOutdatedScreen != null)
        {
            disableOutdatedScreen = FlxG.save.data.disableOutdatedScreen;
        }
        if (FlxG.save.data.debugMode != null){
            debugMode = FlxG.save.data.debugMode;
        }
    }
}