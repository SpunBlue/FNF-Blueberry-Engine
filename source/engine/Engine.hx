package engine;

class Engine{
    public static function debugPrint(text:String){
        if (OptionsData.debugMode)
            trace(text);
    }
}