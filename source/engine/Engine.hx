package engine;

import util.ui.PreferencesMenu;

class Engine{
    // todo: add mod support lol

    public static var mods:Array<String> = [];

    public static function initMods(){
        
    }

    public static function debugPrint(v:Dynamic){
        if (PreferencesMenu.getPref('debuglog')){
            trace(v);
        }
    }
}