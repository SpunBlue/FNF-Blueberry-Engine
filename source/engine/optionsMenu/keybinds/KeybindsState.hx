package engine.optionsMenu.keybinds;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxTimer;

class KeybindsState extends MusicBeatState
{
    var leftKey:FlxKey;
    var downKey:FlxKey;
    var upKey:FlxKey;
    var rightKey:FlxKey;

    var keyObjectGroup:FlxTypedGroup<KeyObject> = new FlxTypedGroup<KeyObject>();
    var mouseGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
    var playerStrums:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

    var settingKey:Bool = false;
    var ignoreInput:Bool = false;

    var selected:Int;

    var mouseCursor:FlxSprite;

    var textlol:FlxText;

    var curSelected:Int;

    override public function create()
    {
        badKeyCheck();
        updateKeyList();

        super.create();

        var background = new FlxSprite(0, 0, Paths.image('menuBGBlue'));
		background.scrollFactor.x = 0;
		background.scrollFactor.y = 0;
		background.updateHitbox();
		background.screenCenter();
		background.antialiasing = true;
		add(background);

        textlol = new FlxText(0, 664, FlxG.width, "Select a Key");
        textlol.setFormat("PhantomMuff 1.5", 32, FlxColor.WHITE, "center");
        textlol.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 2, 1);
        textlol.antialiasing = true;
        add(textlol);

        createKeys();
        add(keyObjectGroup);

        add(playerStrums);

        mouseCursor = new FlxSprite().loadGraphic(Paths.image('optionsmenu/cursor'));
		mouseGroup.add(mouseCursor);

        add(mouseGroup);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        mouseCursor.setPosition(FlxG.mouse.x, FlxG.mouse.y);

        if (settingKey != true){
            for (keysObj in keyObjectGroup.members){
                if (keysObj.justClicked() || controls.ACCEPT && curSelected == keysObj.keyID){
                    selected = keysObj.keyID;
                    settingKey = true;
                }

                if (curSelected == keysObj.keyID && !keysObj.isSelected){
                    keysObj.color = FlxColor.YELLOW;
                    keysObj.isSelected = true;
                }
                else if (curSelected != keysObj.keyID && keysObj.isSelected){
                    keysObj.color = FlxColor.WHITE;
                    keysObj.isSelected = false;
                }
            }

            if (controls.BACK)
                FlxG.switchState(new OptionsMenu());

            if (controls.LEFT_P)
                curSelected--;
            else if(controls.RIGHT_P)
                curSelected++;

            if (curSelected < 0)
                curSelected = 3;
            else if (curSelected > 3)
                curSelected = 0;
        }
        else{
            textlol.text = "Press any key on your Keyboard";

            if (FlxG.keys.justPressed.ANY && !ignoreInput){
                PlayerSettings.reset();

                trace(selected);
                FlxG.save.data.userControls[selected] = FlxG.keys.getIsDown()[0].ID;
                trace(FlxG.keys.getIsDown()[0].ID.toString());

                PlayerSettings.init();

                ignoreInput = true;

                new FlxTimer().start(0.1, function(tmr:FlxTimer)
                {
                    for (keysObj in keyObjectGroup){
                        keysObj.kill();
                        keyObjectGroup.members.remove(keysObj);
                    }

                    settingKey = false;
                    ignoreInput = false;

                    badKeyCheck();
                    updateKeyList();
                    updateKeys();

                    textlol.text = "Select a Key";
                });
            }
        }
    }

    function createKeys(){
        var keyArray:Array<FlxKey> = FlxG.save.data.userControls;
        var startingX:Float = 262;

        for (i in 0...keyArray.length){
            var keylol:KeyObject = new KeyObject(startingX + 126, (FlxG.height / 2) - 128, FlxG.save.data.userControls[i], i);
            keyObjectGroup.add(keylol);

            generateStaticArrow(i, startingX + 126, (FlxG.height / 2) - 256);

            startingX += 126;
        }
    }

    function updateKeys(){
        var keyArray:Array<FlxKey> = FlxG.save.data.userControls;
        var startingX:Float = 262;

        for (i in 0...keyArray.length){
            var keylol:KeyObject = new KeyObject(startingX + 126, (FlxG.height / 2) - 128, FlxG.save.data.userControls[i], i);
            keyObjectGroup.add(keylol);

            startingX += 126;
        }
    }

    function badKeyCheck(){
        var keyArray:Array<FlxKey> = FlxG.save.data.userControls;
        var badKeyArray:Array<FlxKey> = [
            F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12,
            INSERT, HOME, PAGEUP, PAGEDOWN, DELETE, END, 
            PRINTSCREEN, ENTER, ESCAPE, TAB, CAPSLOCK, 
            SHIFT, CONTROL, ALT, SHIFT
        ];

        for (badKey in badKeyArray){
            for (i in 0...keyArray.length){
                var setKey = keyArray[i];

                if (badKey == setKey){
                    switch (i){
                        case 0:
                            FlxG.save.data.userControls[i] = A;
                        case 1:
                            FlxG.save.data.userControls[i] = S;
                        case 2:
                            FlxG.save.data.userControls[i] = W;
                        case 3:
                            FlxG.save.data.userControls[i] = D;
                    }
                }
            }
        }
    }

    function updateKeyList(){
        var keyArray:Array<FlxKey> = FlxG.save.data.userControls;

        for (i in 0...keyArray.length){
            var newKey:FlxKey = FlxG.save.data.userControls[i];

            switch (i){
                case 0:
                    leftKey = newKey;
                case 1:
                    downKey = newKey;
                case 2:
                    upKey = newKey;
                case 3:
                    rightKey = newKey;
            }
        }
    }

    private function generateStaticArrow(i:Int = 0, x:Float, y:Float):Void
        {
            var babyArrow:FlxSprite = new FlxSprite();

            babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets', 'shared');
            babyArrow.antialiasing = true;

            switch (i)
            {
                case 0:
                    babyArrow.animation.addByPrefix('static', 'arrowLEFT');
                    babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
                case 1:
                    babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                    babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
                case 2:
                    babyArrow.animation.addByPrefix('static', 'arrowUP');
                    babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
                case 3:
                    babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
                    babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
            }

            babyArrow.setGraphicSize(126);
            babyArrow.updateHitbox();
            babyArrow.scrollFactor.set();

            babyArrow.setPosition(x, y);

            babyArrow.animation.play('static');

            playerStrums.add(babyArrow);
        }
}