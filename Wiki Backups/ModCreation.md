# How to create Mods!
A lot of the stuff is self-explanatory, like adding charts and adding songs. So I will not be explaining how to do this since you can easily look inside the "Test" mod preloaded in the "mods" Directory.

## The first step
You must create a JSON file that contains the Mods information.

Here is an example of the structure of the JSON file:

```
{
	"name":"Mod Name",
	"description":"Mod Description",
	"author":"Mod Creator",
	"version":"Mod Version"
}
```

* "name" is a string containing your Mod's name.
* "description" is a string containing your Mod's Description.
* "author" is a string containing your Mod's Creator.
* "version" is a string containing your Mod's version. 

Put this file in the Root Directory of your Mod.

## How to add Custom Weeks
To add a custom week, you will need to create a new JSON file that contains the information for the week.

Here is an example of the structure of the JSON file:

```
{
    "weeks": [
        {
            "name": "Week 1",
            "songs": [
                "Tutorial",
                "Bopeebo",
                "Fresh",
                "Dadbattle"
            ],
    
            "icon": "dad",
            "iconIsJson": false,
            "week": 1,
            "color": "0xff9271fd"
        },
    
        {
            "name": "Week 2",
            "songs": [
                "Spookeez",
                "South",
                "Monster"
            ],
    
            "icon": "spooky",
            "iconIsJson": false,
            "week": 2,
            "color": "0xff223344"
        },
    ]
}
```

* "weeks" is an array that contains all the weeks you want to add. Each object in the array should have the following properties:
	* "name" is the name of the week that will be displayed in the menu.
	* "songs" is an array of strings that contains the chart names of the songs that are in that week. These chart names should match the names of the chart files in the "charts" directory.
	* "week" is the number of the week. This can be any number greater than 6. However, the number isn't important and can just be made -1 if you so choose.
	* "icon" is the name of the character that will be used as the icon for the week. This should match the name of the character or the character's JSON file in the "characters" directory minus the JSON prefix.
	* "color" is the color that will be displayed on the Background.

Once you have created your JSON file, you will need to place it in the "weeks" directory. If you are creating a mod, this directory should be located in the "data/weeks" directory.

## How to add Custom Characters
To add custom characters to the game, create a new JSON file with the same name as the character you wish to create, and place it in the "data/characters" folder within the mod directory.

The file should have the following format:
```
{
	"image": "characterName",
	"animations": [
		{
			"xmlanim": "characterName_idle",
			"name": "idle",
			"offsets": [0, 0],
			"fps": 24,
			"loop": true
		},
		{
			"xmlanim": "characterName_sing",
			"name": "sing",
			"offsets": [0, 0],
			"fps": 24,
			"loop": false
		}
	],
	"singHold": true,
	"flipX": false,
	"antialiasing": true,
	"charScale": 1.0
}
```

* "image" is the name of the image file that contains the character's sprites. This file should be placed in the "images/characters" folder within the mod directory.
* "animations" is an array of animation objects that define the different animations that the character can perform. Each object in the array should have the following properties:
    * "xmlanim" is the name of the animation in the XML file that corresponds to the character's image file.
    * "name" is the name of the animation as it will be referred to in-game.
    * "offsets" is an array of integers that define the x and y offset for the animation.
    * "fps" is the frames per second at which the animation should play.
    * "loop" is a boolean value that indicates whether or not the animation should loop.
    * "singHold" is a boolean value that indicates whether or not the character should hold the last frame of the "sing" animation until the end of the song.
    * "indices" is an array of indices of the animation frames to play, this is only required if you want to play specific frames of the animation. Remove this property if you do not use it.
* "flipX" is a boolean value that indicates whether or not the character's sprites should be flipped horizontally.
* "antialiasing" is a boolean value that indicates whether or not the character's sprites should have antialiasing applied.
* "charScale" is a decimal value that defines the scale at which the character should be displayed.

Once the JSON file has been created and the corresponding image and XML files have been placed in the correct directories, the character can be selected in the charter and added to the game.

## How to add custom Dialogue
To add a custom dialogue box, you need to create a JSON file named "dialogue.json" in the same folder as the chart you want the dialogue box to appear in.

The file should have the following structure:

```
{
    "boxImage": "path/to/dialogue_box_image.png",
    "boxXML": "path/to/dialogue_box_xml.xml",
    "boxOpenAnimation": "open_animation",
    "boxIdleAnimation": "idle_animation",
    "boxXOffset": 0,
    "boxYOffset": 0,
    "portraitYOffset": 0,
    "leftPortraitXOffset": 0,
    "rightPortraitXOffset": 0,
    "fps": 30,
    "color": 0xff000000,
    "usePixelFont": false,
    "dialogues": [
        {
            "facing": "left",
            "image": "path/to/portrait_image.png",
            "speed": 0.04,
            "dialogue": "This is an example dialogue"
        },
        {
            "facing": "right",
            "image": "path/to/portrait_image.png",
            "speed": 0.04,
            "dialogue": "This is another example dialogue"
        }
    ]
}
```
The file contains the following properties:

* "boxImage" the path to the image file for the dialogue box.
* "boxXML" the path to the XML file that defines the animation for the dialogue box.
* "boxOpenAnimation" the name of the animation to play when the dialogue box opens.
* "boxIdleAnimation" the name of the animation to play when the dialogue box is idle.
* "boxXOffset" the X offset to apply to the dialogue box.
* "boxYOffset" the Y offset to apply to the dialogue box.
* "portraitYOffset" the Y offset to apply to all portrait images.
* "leftPortraitXOffset" the X offset to apply to the portrait image when the dialogue is from the left.
* "rightPortraitXOffset" the X offset to apply to the portrait image when the dialogue is from the right.
* "fps" the number of frames per second at which to play the animations.
* "color" the color of the text in the dialogue box.
* "usePixelFont" whether to use the pixel font or not.
* "dialogues" an array of objects representing the dialogues in the dialogue box. Each object should contain:
	* "facing" the side of the dialogue box from which the dialogue is coming from. Should be "left" or "right".
	* "image" the path to the image file for the portrait.
	* "speed" the speed at which to display the text in the dialogue box.
	* "dialogue" the actual text of the dialogue.

Note that not all of the properties are required, and you can leave out any that you don't need.

## How to add Cutscenes

To add custom cutscenes in your mod, you will need to follow these steps:

* Create a "videos" folder within your mod's directory.
* Place the desired video file(s) (in mp4 format) within the "videos" folder.
* Open the Charter and navigate to the "Songs" section you wish to add the cutscene to.
* In the "Intro Cutscene" or "Outro Cutscene" text box, type in the name of your cutscene file without the ".mp4" extension. (For example, if your file is named "intro_cutscene.mp4", you would only need to type "intro_cutscene" in the text box.)

It is important to note that the video file must be in mp4 format and placed in the correct directory for the game to recognize and play it correctly.

## How to add Custom Stages
First, create a new JSON file with the name of your stage in the "data/stages" folder in your mod directory.

The JSON file should be in the following format:

```
{
    "name": "Your Stage Name",
    "objects": [
        {
            "image": "path/to/image.png",
            "xmlPath": "path/to/image.xml",
            "position": [x, y],
            "scrollFactor": [x, y],
            "xmlanim": "animationName",
            "name": "objectName",
            "fps": 24,
            "loop": true,
            "indices": [1, 2, 3],
            "playOn": "eventName",
            "isAnimated": true,
            "layer": 0,
            "isDistraction": true,
            "scale": [x, y],
            "flipX": false,
            "flipY": false,
            "size": 1,
            "alpha": 1,
            "blend": "blendName",
            "antialiasing": true
        },
        {
            //Another object
        }
    ],
    "disableAntialiasing": false,
    "camZoom": 2.0,
    "bfPosition": [x, y],
    "gfPosition": [x, y],
    "dadPosition": [x, y]
}
```

* The "name" field is the name of your stage, it will be displayed in the game's stage selection menu.
* "objects" is an array of objects that make up the stage. Each object should contain:
	* "image" field is the path to the image file of the object.
	* "xmlPath" is a path to the XML file that contains animation data for the object.
	* "position" is an array of floats that sets the position of the object in the stage.
	* "scrollFactor" is an array of floats that sets the object's scrolling speed relative to the stage's camera.
	* "xmlanim" is the name of the animation defined in the xml file.
	* "name" is the name of the object, it will be used to reference the object in the game code.
	* "fps" is the frame rate of the animation.
	* "loop" is a boolean value that controls whether the animation loops or not.
	* "indices" is an array of integers that defines the frames of the animation to play.
	* "playOn" is a string value that specifies when the animation should start playing.
	* "isAnimated" is a boolean value that specifies whether the object is animated or not.
	* "layer" is an integer that sets the layer on which the object is displayed, 0 = behind all, 1 = infront of GF, 2 = infront of dad & bf.
	* "isDistraction" is a boolean value that specifies whether the object is a distraction or not.
	* "scale" is an array of floats that sets the scaling factor of the object.
	* "flipX" is a boolean value that controls whether the object is flipped horizontally or not.
	* "flipY" is a boolean value that controls whether the object is flipped vertically or not.
	* "size" is a float value that sets the size of the object.
	* "alpha" is the visbility of the object.
	* "blend" is a string value that sets the blending mode of the object.
	* "antialiasing" is a boolean value that enables or disables antialiasing for the object.
* "disableAntialiasing" is a boolean value that enables or disables antialiasing for the stage.
* "camZoom" is a float value that controls the zoom level of the camera for the stage.
* "bfPosition" is an array of integers that sets the position of the "bf" layer in the stage.
* "gfPosition" is an array of integers that sets the position of the "gf" layer in the stage.
* "dadPosition" is an array of integers that sets the position of the "dad" layer in the stage.

Once the JSON file has been created, the stage can be selected in the charter and added to the game.

## How to use Events
Custom Events in the engine can be used to perform specific actions at a specific time during the song. These events can be added through the charter, and can be further customized with the use of variables.

The following is a list of all the events currently in the engine and their corresponding variables:
* "None" - This event does not perform any action.
* "deleteCharacter" - This event deletes a specific character from the game. Variables:
	* "var1" - The group the character belongs to, either "bf" or "dad".
	* "var2" - The ID of the character to be deleted.
* "addCharacter" - This event adds a new character to the game. Variables:
	* "var1" - The group the character belongs to, either "bf" or "dad".
	* "var2" - The name of the new character to be added.
	* "var3" - The ID to be assigned to the new character.
	* "var4" - The X offset of the new character.
	* "var5" - The Y offset of the new character.
* "singAsCharacter" - This event sets the current character to a specific character. Variables:
	* "var1" - The group the character belongs to, either "bf" or "dad".
	* "var2" - The ID of the character to be set as the current character.
* "replaceGF" - This event replaces the current Girlfriend with a new one. Variables:
	* "var2" - The name of the new character to be added.
	* "var3" - The X offset of the new character.
	* "var4" - The Y offset of the new character.
* "playAnimation" - This event plays an Animation on the currently selected character. Variables:
	* "var1" - The group the character belongs to, either "bf", "dad" or "gf".
	* "var2" - The character ID.
	* "var3" - The name of the new animation to be played.
* "Zoom"
    * "var1" - Lerp the Value.
    * "var2" - The Camera to Zoom on.
    * "var3" - Zoom Amount.

In addition to the events added through the charter, you can also add a JSON file named "startupEvents.json" to add events that will automatically be executed before the song starts, You would put this file in "data/charts/[Song Name]/" in your mod directory. The format of this JSON file should be as follows:

```
{
    "events": [
        {
            "name": "eventName",
            "var1": "variable1",
            "var2": "variable2",
            "var3": "variable3",
            "var4": "variable4",
            "var5": "variable5",
        }
}
```

Keep in mind that all variables for the events are Strings.

## How to add Custom Notes
Custom notes can be added to the game by creating a new JSON file and placing it in the "scripts/notes" folder within the mod directory.

The JSON file should have the following format:

```
{
    "image": "noteName",
    "xml": "noteName",
    "animations": {
        "greenScroll": "noteName_green",
        "redScroll": "noteName_red",
        "blueScroll": "noteName_blue",
        "purpleScroll": "noteName_purple",
        "purpleholdend": "noteName_purpleholdend",
        "greenholdend": "noteName_greenholdend",
        "redholdend": "noteName_redholdend",
        "blueholdend": "noteName_blueholdend",
        "purplehold": "noteName_purplehold",
        "greenhold": "noteName_greenhold",
        "redhold": "noteName_redhold",
        "bluehold": "noteName_bluehold"
    },
    "scale": 0,
    "sustainAlpha": 1,
    "antialiasing": true,
    "onHit": {
        "health": 0.1,
        "playAnimationBF": "noteName_bf",
        "playAnimationDAD": "noteName_dad",
        "instaKill": false
    },
    "onSustain": {
        "health": 0.1,
        "playAnimationBF": "noteName_bf",
        "playAnimationDAD": "noteName_dad",
        "instaKill": false
    },
    "onDadHit": {
        "health": 0.1,
        "playAnimationBF": "noteName_bf",
        "playAnimationDAD": "noteName_dad",
        "instaKill": false
    },
    "onDadSustain": {
        "health": 0.1,
        "playAnimationBF": "noteName_bf",
        "playAnimationDAD": "noteName_dad",
        "instaKill": false
    },
    "onMiss": {
        "health": 0.1,
        "playAnimationBF": "noteName_bf",
        "playAnimationDAD": "noteName_dad",
        "instaKill": false
    },
    "allowScoring": true,
    "scoreOnSick": 350,
    "scoreOnGood": 200,
    "scoreOnBad": 150,
    "scoreOnShit": 0
}
```

* "image" is the name of the image file that contains the note's sprites. This file should be placed in the "images" folder within the mod directory. (Don't inclue for default)
* "xml" is the name of the xml file that contains the note's animations. This file should be placed in the "images" folder within the mod directory. (Don't inclue for default)
* "animations" is an object that defines the different animations that the note can perform. Each property in the object:
	* "greenScroll" is the name of the green scroll animation.
	* "redScroll" is the name of the red scroll animation.
	* "blueScroll" is the name of the blue scroll animation.
	* "purpleScroll" is the name of the purple scroll animation.
	* "purpleholdend" is the name of the purple hold animation end.
	* "greenholdend" is the name of the green hold animation end.
	* "redholdend" is the name of the red hold animation end.
	* "blueholdend" is the name of the blue hold animation end.
	* "purplehold" is the name of the purple hold animation.
    * "greenholdend" is the name of the green hold animation.
    * "redholdend" is the name of the red hold animation.
    * "blueholdend" is the name of the blue hold animation.
* "scale" is the Scale of the Note.
* "sustainAlpha" is the visbility of the note.
* "antialiasing" antialiase the note.
* "onHit", "onSustain", "onMiss", and the Dad Variants, all have the same properties. Each property in the object:
    * "health" Add or Subtract the amount of health the note gives you.
    * "playAnimationBF" play an Animation on the currently selected Boyfriend.
    * "playAnimationDAD" play an Animation on the currently selected Boyfriend.
    * "instaKill" Kills the player instantly.
* "allowScoring" Allows scoring of the note.
* "allowBotHit" Allows hitting on Bot Mode.
* "scoreOnSick" Score for the note when you get a Sick. (Don't inclue for default)
* "scoreOnGood" Score for the note when you get a Good. (Don't inclue for default)
* "scoreOnBad" Score for the note when you get a Bad. (Don't inclue for default)
* "scoreOnShit" Score for the note when you get a Shit. (Don't inclue for default)

## Hscript
HaxeLib Hscript is a scripting engine that runs scripts in-game. Scripts are loaded by making a Script file in "mods/[User's Mod Name]/scripts/[Song Name].hx".

The script should be in the following format:
```
var testText:FlxText;

function createPost()
{
    testText = new FlxText(64, 24, 0, "TEST MOD - EXAMPLE SCRIPT", 24);
    testText.cameras = [camHUD];
    testText.scrollFactor.set();
    FlxG.state.add(testText);
}
```

### Variables Available for Scripts
* Int - An integer data type.
* String - A string data type.
* Float - A floating-point data type.
* Array - An array data type.
* Bool - A boolean data type.
* Dynamic - A dynamic data type.
* Math - A class for mathematical functions.
* Main - A reference to the main class.
* FlxMath - A class for mathematical functions in the Flixel engine.
* Std - A class for standard Haxe functions.
* StringTools - A class for string manipulation functions.
* FlxG - A class for accessing global game data in the Flixel engine.
* FlxSound - A class for playing sound in the Flixel engine.
* FlxSprite - A class for displaying 2D graphics in the Flixel engine.
* FlxText - A class for displaying text in the Flixel engine.
* FlxTween - A class for tweening in the Flixel engine.
* FlxCamera - A class for managing camera movement in the Flixel engine.
* File - A class for accessing the file system.
* Paths - A class for accessing the paths in the file system.
* CoolUtil - A class with utility functions.
* Assets - A class for accessing game assets.
* Modding - A class for modding functionality.
* FileSystem - A class for accessing the file system.
* PlayState - A reference to the play state.
* StageObject - A class for stage objects.

### Additional Variables for Scripts used in PlayState
* boyfriend - A reference to the boyfriend object.
* dad - A reference to the dad object.
* gf - A reference to the girlfriend object.
* boyfriendGroup - A reference to the group of boyfriend objects.
* dadGroup - A reference to the group of dad objects.
* gfGroup - A reference to the group of girlfriend objects.
* stageLayer0 - A reference to the first layer of the stage.
* stageLayer1 - A reference to the second layer of the stage.
* stageLayer2 - A reference to the third layer of the stage.
* camFollow - A reference to the camera following object.
* camHUD - A reference to the HUD camera.
* camGame - A reference to the game camera.
* inCutscene - A boolean indicating if a cutscene is playing.

### Valid Functions for Scripts
* create - Runs at the beginning of the create function.
* createPost - Runs after everything in the create function has been ran.
* update - Runs at the beginning of the Update function.
* updatePost - Runs after everything in the update function has been ran.

### Valid Functions for Scripts in PlayState
* startCountdown - Runs at song count down.
* startSong - Runs at the start of the song.
* generateStaticArrows - Runs at the generateStaticArrows function.
* dadNoteHit - Runs when the Dad hits a Note.
* endSong - Runs at the end of the Song
* popUpScore - If you see this, It's 6 AM and I'm fucking tired.
* noteMiss - Runs when the Player misses a Note.
* goodNoteHit - Runs when the Player hits a Note.
* stepHit - Runs on every Step.
* beatHit - Runs on every Beat.

### Notes

Information on everything supported is not currently available, for more information read the Source Code.
You can access Variables within the Variable as long as they are Public Variables and or Public Static Variables.

## Bonus Information!

1. In the Charter, on the notes tab, you can select a custom Character ID for the notes to be sung by, rather than the default or selected character in the song. This allows you to use characters other than the default or selected character for singing specific notes in a song.
2. Swapping Section (And maybe also copying sections) does not copy all information about the note.