var limo:FlxSprite;
var grpLimoDancers:FlxTypedGroup<BackgroundDancer> = new FlxTypedGroup();
var fastCar:FlxSprite;

function onCreate(){
    setDefaultZoom(0.90);

    var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
    skyBG.scrollFactor.set(0.1, 0.1);
    add(skyBG);

    var bgLimo:FlxSprite = new FlxSprite(-200, 480);
    bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
    bgLimo.animation.addByPrefix('drive', "background limo pink", 'week4', 24);
    bgLimo.animation.play('drive');
    bgLimo.scrollFactor.set(0.4, 0.4);
    add(bgLimo);

    for (i in 0...5)
    {
        var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 385, 'week4');
        dancer.scrollFactor.set(0.4, 0.4);
        grpLimoDancers.add(dancer);
    }

    var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
    overlayShit.alpha = 0.5;
    // add(overlayShit);
    // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);
    // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);
    // overlayShit.shader = shaderBullshit;

    limo = new FlxSprite(-120, 550);
    limo.frames = Paths.getSparrowAtlas('limo/limoDrive', 'week4');
    limo.animation.addByPrefix('drive', "Limo stage", 24);
    limo.animation.play('drive');
    limo.antialiasing = true;

    fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));

    resetFastCar();

    stageLayer0.add(fastCar);
    stageLayer0.add(grpLimoDancers);
    stageLayer1.add(limo);
}

function createPost(){
    boyfriend.y -= 220;
    boyfriend.x += 260;
}

function update(elapsed){

}

function updatePost(elapsed){

}

function stepHit(curStep){

}

function beatHit(curBeat){
    grpLimoDancers.forEach(function(dancer:BackgroundDancer)
    {
        dancer.dance();
    });

    if (FlxG.random.bool(10) && fastCarCanDrive)
        fastCarDrive();

    if (PreferencesMenu.getPref('camera-zoom'))
	{
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
	}
}

var fastCarCanDrive:Bool = true;

function resetFastCar():Void
{
    fastCar.x = -12600;
    fastCar.y = FlxG.random.int(140, 250);
    fastCar.velocity.x = 0;
    fastCarCanDrive = true;
}

function fastCarDrive()
{
    FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

    fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
    fastCarCanDrive = false;
    new FlxTimer().start(2, function(tmr:FlxTimer)
    {
        resetFastCar();
    });
}