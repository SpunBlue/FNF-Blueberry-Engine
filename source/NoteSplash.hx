package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite {

    public function new(x:Float = 0, y:Float = 0, noteData:Int) {
        super(x, y);
        frames = Paths.getSparrowAtlas('noteSplashes');
        loadAnims();
        setup(x, y, noteData);
        scrollFactor.set();
        antialiasing = true;
    }
    
    public function setup(x:Float = 0, y:Float = 0, noteData:Int) {
        setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
        offset.set(10, 10);


        animation.play('note' + noteData + '-' + FlxG.random.int(1,2), true);

        if (animation.curAnim != null) {
            animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
        }
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if (animation.curAnim.finished && animation.curAnim != null) {
            this.kill();
        }
    }

    function loadAnims() {
        for (i in 1...3) {
            animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
        }
    }
}