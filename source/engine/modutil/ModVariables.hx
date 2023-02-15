package engine.modutil;

import Character.CharJson;

class ModVariables{
    public static var characters:Map<String, CharJson> = new Map();

    public static function reset(){
        characters.clear();
    }
}