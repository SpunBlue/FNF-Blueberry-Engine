package engine.optionsMenu.misc;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class OptionTextButton extends FlxText
{
    public function new(x:Float, y:Float, text:String){
        super(x, y, 512, text, 32);

        setFormat("PhantomMuff 1.5", 72, FlxColor.WHITE, "center");
        setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 4, 2);
        setSize(width, height * 1.25);
        antialiasing = true;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    public function isClicked(){
        if (FlxG.mouse.overlaps(this) && FlxG.mouse.justPressed)
            return true;
        else
            return false;
    }
}