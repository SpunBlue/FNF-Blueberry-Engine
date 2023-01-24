package engine;

import engine.modding.Stages;
import game.PlayState;
import engine.modding.Modding;

class Engine{
    /*
    *   A function that only calls "trace();" if OptionsData.debugMode is equal to True.
    */
    public static function debugPrint(text:String){
        if (OptionsData.debugMode)
            trace(text);
    }

    /*
    *   Unloads all Mod Data/Variables.
    */
    public static function resetModding(?removePreloadedData:Bool = true){
        Stages.stageJson = null;
        Stages.stageArray = [];
        Stages.stageName = null;

        if (removePreloadedData){
            Modding.modPreloaded = null;
            Modding.preloadedData = [];
        }

        PlayState.curStage = '';
    }
}