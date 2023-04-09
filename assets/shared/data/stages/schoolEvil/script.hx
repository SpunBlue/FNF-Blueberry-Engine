var wiggleShit:WiggleEffect = new WiggleEffect();

function onCreate(){
    var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
    var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

    var posX = 400;
    var posY = 200;

    var bg:FlxSprite = new FlxSprite(posX, posY);
    bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
    bg.animation.addByPrefix('idle', 'background 2', 24);
    bg.animation.play('idle');
    bg.scrollFactor.set(0.8, 0.9);
    bg.scale.set(6, 6);
    bg.antialiasing = false;
    add(bg);
}

function createPost(){
    createTrail(dad, null, 4, 24, 0.3, 0.069, true, stageLayer1);
}

function update(elapsed){

}

function updatePost(elapsed){

}

function stepHit(curStep){

}

function beatHit(curBeat){
    wiggleShit.update(Conductor.crochet);
}