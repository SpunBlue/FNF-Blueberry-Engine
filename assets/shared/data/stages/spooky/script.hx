var halloweenBG:FlxSprite;

function onCreate(){
    var hallowTex:FlxAtlasFrames = Paths.getSparrowAtlas('halloween_bg', 'week2'); // broken... somehow?

    halloweenBG = new FlxSprite(-200, -100);
    halloweenBG.frames = hallowTex;
    halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
    halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 'week2', 24, false);
    halloweenBG.animation.play('idle');
    halloweenBG.antialiasing = true;
    add(halloweenBG);
}

function createPost(){

}

function update(elapsed){

}

function updatePost(elapsed){

}

function stepHit(curStep){

}

var lightningStrikeBeat:Int = 0;
var lightningOffset:Int = 8;

function beatHit(curBeat){
    if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
    {
        FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
        halloweenBG.animation.play('lightning', true);
    
        lightningStrikeBeat = curBeat;
        lightningOffset = FlxG.random.int(8, 24);
    
        boyfriend.playAnim('scared', true);
        gf.playAnim('scared', true);
    }
    else if (halloweenBG.animation.finished) // bandaid patch
        halloweenBG.animation.play('idle');
}