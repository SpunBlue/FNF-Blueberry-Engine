package engine;

import util.ui.PreferencesMenu;

class Engine{
    public static function debugPrint(v:Dynamic){
        if (PreferencesMenu.getPref('debuglog')){
            trace(v);
        }
    }
}