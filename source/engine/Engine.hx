package engine;

import engine.library.SpunAssetLib.AssetLibrary;
import flixel.FlxSprite;
import engine.modding.Stages;
import game.PlayState;
import engine.modding.Modding;

class Engine{
    /**
     * A function that only calls `trace` if `OptionsData.debugMode` is equal to True.
     */
    public static function debugPrint(text:String){
        if (OptionsData.debugMode)
            trace(text);
    }

	/**
	 * Used for resetting all Modding Variables.
	 */
    public static function resetModding(?removePreloadedData:Bool = true){
        Stages.stageJson = null;
        Stages.stageArray = [];
        Stages.stageName = null;

        PlayState.curStage = '';

        if (removePreloadedData)
            Modding.assetLibrary = new AssetLibrary();
    }
}