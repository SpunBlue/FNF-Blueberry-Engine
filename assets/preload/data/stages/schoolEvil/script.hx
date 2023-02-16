var posX = 400;
var posY = 200;

function onCreate()
{
    var bg:FlxSprite = new FlxSprite(posX, posY);
    bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
    bg.animation.addByPrefix('idle', 'background 2', 24);
    bg.animation.play('idle');
    bg.scrollFactor.set(0.8, 0.9);
    bg.scale.set(6, 6);
    add(bg);
}