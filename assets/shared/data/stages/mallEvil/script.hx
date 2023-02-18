var upperBoppers:FlxSprite;
var bottomBoppers:FlxSprite;
var santa:FlxSprite;

function onCreate(){
    var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
    bg.antialiasing = true;
    bg.scrollFactor.set(0.2, 0.2);
    bg.active = false;
    bg.setGraphicSize(Std.int(bg.width * 0.8));
    bg.updateHitbox();
    add(bg);

    var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
    evilTree.antialiasing = true;
    evilTree.scrollFactor.set(0.2, 0.2);
    add(evilTree);

    var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
    evilSnow.antialiasing = true;
    add(evilSnow);
}

function createPost(){
    boyfriend.x += 320;
    dad.y -= 80;
    gf.alpha = 0;
}

function update(elapsed){

}

function updatePost(elapsed){

}

function stepHit(curStep){

}

function beatHit(curBeat){

}