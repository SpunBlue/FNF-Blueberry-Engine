# Welcome to Blueberry Engine!
goo goo ga ga, baby documentation, goo goo ga ga, not ready, goo goo ga ga.

## How to use Hscript Support.
A script is a collection of functions that are called at various points during gameplay. The engine provides several hooks that modders can use to insert custom behavior into the game. The following hooks are currently available:

Avaliable on all:
- `onCreate()`: Called when the gameplay state is created.
- `createPost()`: Called after the gameplay state is created.
- `update(elapsed:Float)`: Called every frame before the gameplay state is updated.
- `updatePost(elapsed:Float)`: Called every frame after the gameplay state is updated.
Avaliable on some:
- `beatHit()`: Called when a beat is hit.
- `stepHit()`: Called when a step is hit.
Avaliable in PlayState:
- `goodNoteHit(note:Note)`: Called when a note is hit correctly.
- `noteTooLate(daNote:Note)`: Called when a note is missed because it was hit too late.
- `noteMiss(direction:Int)`: Called when a note is missed because it was not hit.

To add custom behavior to the game, modders can write their own functions and add them to the script. For example:
```cs
var sprite:FlxSprite;

function onCreate(){
    trace("State created.");

    sprite = new FlxSprite(0, 0);
    sprite.loadGraphic(ModAssets.getGraphic("images/test.png", curMod)); // or you can do `ModAssets.getGraphic("images/test.png", null, "ModIDHere");` to get a graphic within another Mod.
    add(sprite);
}

function update(elapsed){
    // Custom update behavior.
}

function updatePost(elapsed){
    // Custom post update behavior.
}
```

If a function doesn't need any parameters, it needs to be defined without any.

### Accessing Haxe and Flixel Classes and Functions.
The engine provides access to various classes, and functions, through global variables. Modders can use these variables in all states. Keep in mind that this list isn't detailed. Here is a list of avaliable global variables:

Classes:
- `Int`
- `String`
- `Float`
- `Array`
- `Bool`
- `Dynamic`
- `Math`
- `FlxMath`
- `Std`
- `StringTools`
- `FlxG`
- `FlxSound`
- `FlxSprite`
- `FlxText`
- `FlxGraphic`
- `FlxTween`
- `FlxCamera`
- `File`
- `FileSystem`
- `Assets`
- `FlxGroup`
- `FlxTypedGroup`
- `Paths`
- `Path`
- `Json`
- `FlxAngle`
- `FlxAtlasFrames`
- `FlxAtlas`
- `Character`
- `Boyfriend`: Not related to the `Boyfriend` character in PlayState, this is the class used for that object.
- `PreferencesMenu`
- `Song`: Not related to the `SONG` variable in PlayState, this is the class used for that object.
- `Conductor`
- `Section`
- `Note`

Functions:
- `getModID()`: Returns the current Mod ID.
- `trace(value:Dynamic)`: Logs anything to the console.
- `createThread(func:Void -> Void)`: Creates a thread and runs the given function, if threads are not supported it will run anyways.

### Accesssing PlayState Game Objects.
The engine provides access to various objects, classes, and functions, through global variables. Modders can use these variables to modify the PlayState or get information. Here is a list of available global variables:

Classes:
- `ModAssets`: The modding assets class.
- `ModLib`: The modding class.
- `StrumNotes`: StrumNotes class.
- `BackgroundDancer`: Background dancer class.
- `BackgroundGirls`: Background girls class.
- `WiggleEffect`: Wiggle effect class.
- `FlxWaveEffect`: Wave effect class.
- `TankmenBG`: Tankmen background class.
- `BGSprite`: Background sprite class.
- `FlxWaveMode`: Wave mode class.

Functions:
- `add(value:FlxObject)`: Adds a FlxObject to the scene.
- `setDefaultZoom(value:Float)`: Sets the default camera zoom.
- `setGF(value:String)`: Sets the current Girlfriend.
- `curGF()`: Returns the current Girlfriend.
- `createTrail(char:FlxObject, graphic:FlxGraphic, length:Int, delay:Float, alpha:Float, diff:Float, ?addInGroup:Bool, ?group:FlxGroup)`: Creates a trail effect.
- `replaceStrum(style:String, ?skipTransition:Bool, ?dontGenCPU:Bool)`: Replace all strumlines with given data, Generates with no Preferences attatched.

Objects:
- `camHUD`: The HUD Camera.
- `camGame`: The Game Camera.
- `playerStrums`: Player Strums.
- `cpuStrums`: CPU Strums.

Groups:
- `strumLines`: All Strums.
- `stageLayer0`: Layer 0 of the stage - Behind all.
- `stageLayer1`: Layer 1 of the stage - Above GF.
- `stageLayer2`: Layer 2 of the stage - Above All.
- `boyfriendGroup`: The group of BF's.
- `dadGroup`: The group of Dad's.
- `gfGroup`: The group of GF's.

Characters:
- `boyfriend`: The `Boyfriend` character.
- `dad`: The `Dad` character.
- `gf`: The `GF` character.

Shaders:
- `BuildingShaders`: Building shader class.
- `ColorSwap`: Color swap shader class.

Misc:
- `curMod`: The current mod ID loaded.
- `SONG`: The current song data.
- `curSong`: The current song name.
- `curStage`: The current stage name.
- `gfVersion`: The current Girlfriend.
- `inCutscene`: Whether or not the game is in a cutscene.
- `curBeat`: The current beat number.
- `curStep`: The current step number.

### What it's used for, and Advice.
Currently, Hscript is used for making Stages and for any purpose you have in-song. You put scripts in `data/stages` or in `data/charts/SONG_NAME`.

For stages you have to name your script `script.hx` or it will not be detected, all scripts within your songs folder will be detected automatically.

I would recommend reading the code in `source/game/PlayState.hx`, `source/engine/modutil/Hscript.hx`, `source/engine/modding/SpunModLib.hx`, and the code for the variables you have access to for more information.
