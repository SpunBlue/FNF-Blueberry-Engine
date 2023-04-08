var foregroundSprites:FlxTypedGroup<BGSprite> = new FlxTypedGroup();
var tankmanRun:FlxTypedGroup<TankmenBG> = new FlxTypedGroup();
var gfCutsceneLayer:FlxGroup;
var bfTankCutsceneLayer:FlxGroup;
var tankWatchtower:BGSprite;
var tankGround:BGSprite;

function onCreate(){
    setDefaultZoom(0.9);

    var bg:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0, 'week7');
    add(bg);

    var tankSky:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1, 'week7');
    tankSky.active = true;
    tankSky.velocity.x = FlxG.random.float(5, 15);
    add(tankSky);

    var tankMountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2, 'week7');
    tankMountains.setGraphicSize(Std.int(tankMountains.width * 1.2));
    tankMountains.updateHitbox();
    add(tankMountains);

    var tankBuildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.30, 0.30, 'week7');
    tankBuildings.setGraphicSize(Std.int(tankBuildings.width * 1.1));
    tankBuildings.updateHitbox();
    add(tankBuildings);

    var tankRuins:BGSprite = new BGSprite('tankRuins', -200, 0, 0.35, 0.35, 'week7');
    tankRuins.setGraphicSize(Std.int(tankRuins.width * 1.1));
    tankRuins.updateHitbox();
    add(tankRuins);

    var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, 'week7', ['SmokeBlurLeft'], true);
    add(smokeLeft);

    var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, 'week7', ['SmokeRight'], true);
    add(smokeRight);

    // tankGround.

    tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, 'week7', ['watchtower gradient color']);
    add(tankWatchtower);

    tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5, 'week7', ['BG tank w lighting'], true);
    add(tankGround);

    add(tankmanRun);

    var tankGround:BGSprite = new BGSprite('tankGround', -420, -150, 1, 1, 'week7');
    tankGround.setGraphicSize(Std.int(tankGround.width * 1.15));
    tankGround.updateHitbox();
    add(tankGround);

    moveTank();

    // smokeLeft.screenCenter();

    var fgTank0:BGSprite = new BGSprite('tank0', -500, 650, 1.7, 1.5, 'week7', ['fg']);
    foregroundSprites.add(fgTank0);

    var fgTank1:BGSprite = new BGSprite('tank1', -300, 750, 2, 0.2, 'week7', ['fg']);
    foregroundSprites.add(fgTank1);

    // just called 'foreground' just cuz small inconsistency no bbiggei
    var fgTank2:BGSprite = new BGSprite('tank2', 450, 940, 1.5, 1.5, 'week7', ['foreground']);
    foregroundSprites.add(fgTank2);

    var fgTank4:BGSprite = new BGSprite('tank4', 1300, 900, 1.5, 1.5, 'week7', ['fg']);
    foregroundSprites.add(fgTank4);

    var fgTank5:BGSprite = new BGSprite('tank5', 1620, 700, 1.5, 1.5, 'week7', ['fg']);
    foregroundSprites.add(fgTank5);

    var fgTank3:BGSprite = new BGSprite('tank3', 1300, 1200, 3.5, 2.5, 'week7', ['fg']);
    foregroundSprites.add(fgTank3);

    stageLayer2.add(foregroundSprites);

	if (curSong.toLowerCase() == 'stress')
		setGF('pico-speaker');
}

function createPost(){
    gf.y += 10;
    gf.x -= 30;
    boyfriend.x += 40;
    boyfriend.y += 0;
    dad.y += 60;
    dad.x -= 80;

    if (curGF().toLowerCase() != 'pico-speaker')
    {
        gf.x -= 170;
        gf.y -= 75;
    }
    else if (curGF().toLowerCase() == 'pico-speaker'){
        gf.x -= 50;
        //gf.y += 200;

        for (i in 0...TankmenBG.animationNotes.length)
        {
            if (FlxG.random.bool(16))
            {
                var tankman:TankmenBG = new TankmenBG(20, 500, true);
                tankman.strumTime = TankmenBG.animationNotes[i][0];
                tankman.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
                tankmanRun.add(tankman);
            }
        }
    }
}

function update(elapsed){

}

function updatePost(elapsed){

}

function stepHit(curStep){
    switch (curSong.toLowerCase()){
        case 'stress':
            if (curStep == 736 && dad.curCharacter == 'tankman')
                dad.playAnim('prettyGood', true);
    }
}

function beatHit(curBeat){
    foregroundSprites.forEach(function(spr:BGSprite)
    {
        spr.dance();
    });

    tankWatchtower.dance();
}

function moveTank():Void
{
    if (!inCutscene)
    {
        var daAngleOffset:Float = 1;
        tankAngle += FlxG.elapsed * tankSpeed;
        tankGround.angle = tankAngle - 90 + 15;

        tankGround.x = tankX + Math.cos(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1500;
        tankGround.y = 1300 + Math.sin(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1100;
    }
}

var tankResetShit:Bool = false;
var tankMoving:Bool = false;
var tankAngle:Float = FlxG.random.int(-90, 45);
var tankSpeed:Float = FlxG.random.float(5, 7);
var tankX:Float = 400;