var limo:FlxSprite;
var fastCar:FlxSprite;
var fastCarCanDrive:Bool = true;
var grpLimoDancers:FlxTypedGroup<BackgroundDancer> = new FlxTypedGroup();

function onCreate()
{
    var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
    skyBG.scrollFactor.set(0.1, 0.1);
    add(skyBG);

    var bgLimo:FlxSprite = new FlxSprite(-200, 480);
    bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
    bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
    bgLimo.animation.play('drive');
    bgLimo.scrollFactor.set(0.4, 0.4);
    add(bgLimo);

    add(grpLimoDancers);

    for (i in 0...5)
    {
        var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
        dancer.scrollFactor.set(0.4, 0.4);
        grpLimoDancers.add(dancer);
    }

    var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
    overlayShit.alpha = 0.5;

    var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

    limo = new FlxSprite(-120, 550);
    limo.frames = limoTex;
    limo.animation.addByPrefix('drive', "Limo stage", 24);
    limo.animation.play('drive');
    limo.antialiasing = true;

    fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));

    resetFastCar();
    add(fastCar);

    layer2.add(limo);
}

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

function beatHit(curBeat)
{
    grpLimoDancers.forEach(function(dancer:BackgroundDancer)
    {
        dancer.dance();
    });

    if (FlxG.random.bool(10) && fastCarCanDrive)
        fastCarDrive();
}