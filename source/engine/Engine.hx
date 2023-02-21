package engine;

import util.ui.PreferencesMenu;

class Engine{
    /**
     * Only logs if PreferencesMenu.getPred('debuglog') = true.
     * @param v 
     * @deprecated the `trace` functions is now modified to do this automatically.
     */
    @:deprecated
    public static function debugPrint(v:Dynamic){
        if (PreferencesMenu.getPref('debuglog')){
            trace(v);
        }
    }
}