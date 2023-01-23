package engine.optionsMenu.keybinds;

import lime.utils.Assets;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

class KeyObject extends FlxSprite
{
    public var keyID:Int = 0;
    public var isSelected:Bool = false; // is only used for keyboard inputs, not used as actual value to detect if selected in any other means.

    public function new(x:Float, y:Float, key:FlxKey, id:Int){
        super(x, y);

        keyID = id;

        var keyText:String = key.toString().toLowerCase();

        if (Assets.exists(Paths.image('optionsmenu/keys/$keyText', 'preload')))
            loadGraphic(Paths.image('optionsmenu/keys/$keyText', 'preload'));
        else
            loadGraphic(Paths.image('optionsmenu/keys/UNKNOWN', 'preload'));

        antialiasing = true; // why wouldn't i want this lmao
        setGraphicSize(126, 115);
        updateHitbox();
    }

    public function justClicked(){
        if (FlxG.mouse.overlaps(this) && FlxG.mouse.justPressed)
            return true;
        else
            return false;
    }

    /*override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }*/
}