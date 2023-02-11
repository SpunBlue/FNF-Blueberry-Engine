package;

import engine.Engine;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import engine.modding.Modding;
import game.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSort;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var animationsArray:Array<AnimArray> = [];

	public var holdTimer:Float = 0;

	public var isModded:Bool;
	public var jsonCharacter:Bool;

	public var jsonData:Dynamic;

	var singHold:Float = 4;

	public var animationNotes:Array<Dynamic> = [];

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		if (FileSystem.exists(Modding.getFilePath('$curCharacter.json', 'data/characters'))){
			loadCustomCharacter(true);
		}
		else if (FileSystem.exists('assets/characters/$curCharacter.json')){
			loadCustomCharacter(false);
		}
		else{
			isModded = false;
			jsonCharacter = false;

			switch (curCharacter)
			{
				case 'gf':
					// GIRLFRIEND CODE
					tex = Paths.getSparrowAtlas('GF_assets', 'shared');
					frames = tex;
					animation.addByPrefix('cheer', 'GF Cheer', 24, false);
					animation.addByPrefix('singLEFT', 'GF left note', 24, false);
					animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
					animation.addByPrefix('singUP', 'GF Up Note', 24, false);
					animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
					animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
					animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
					animation.addByPrefix('scared', 'GF FEAR', 24);

					addOffset('cheer');
					addOffset('sad', -2, -2);
					addOffset('danceLeft', 0, -9);
					addOffset('danceRight', 0, -9);

					addOffset("singUP", 0, 4);
					addOffset("singRIGHT", 0, -20);
					addOffset("singLEFT", 0, -19);
					addOffset("singDOWN", 0, -20);
					addOffset('hairBlow', 45, -8);
					addOffset('hairFall', 0, -9);

					addOffset('scared', -2, -17);

					playAnim('danceRight');

				case 'gf-christmas':
					tex = Paths.getSparrowAtlas('christmas/gfChristmas', 'week5');
					frames = tex;
					animation.addByPrefix('cheer', 'GF Cheer', 24, false);
					animation.addByPrefix('singLEFT', 'GF left note', 24, false);
					animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
					animation.addByPrefix('singUP', 'GF Up Note', 24, false);
					animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
					animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
					animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
					animation.addByPrefix('scared', 'GF FEAR', 24);

					addOffset('cheer');
					addOffset('sad', -2, -2);
					addOffset('danceLeft', 0, -9);
					addOffset('danceRight', 0, -9);

					addOffset("singUP", 0, 4);
					addOffset("singRIGHT", 0, -20);
					addOffset("singLEFT", 0, -19);
					addOffset("singDOWN", 0, -20);
					addOffset('hairBlow', 45, -8);
					addOffset('hairFall', 0, -9);

					addOffset('scared', -2, -17);

					playAnim('danceRight');

				case 'gf-car':
					tex = Paths.getSparrowAtlas('gfCar', 'week4');
					frames = tex;
					animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
						false);

					addOffset('danceLeft', 0);
					addOffset('danceRight', 0);

					playAnim('danceRight');

				case 'gf-pixel':
					tex = Paths.getSparrowAtlas('weeb/gfPixel', 'week6');
					frames = tex;
					animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
					animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

					addOffset('danceLeft', 0);
					addOffset('danceRight', 0);

					playAnim('danceRight');

					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
					antialiasing = false;

				case 'gf-tankmen':

					frames = Paths.getSparrowAtlas('characters/gfTankmen', 'week7');
					animation.addByIndices('sad', 'GF Crying at Gunpoint', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, true);
					animation.addByIndices('danceLeft', 'GF Dancing at Gunpoint', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing at Gunpoint', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

					addOffset('cheer');
					addOffset('sad', -2, -2);
					addOffset('danceLeft', 0, -9);
					addOffset('danceRight', 0, -9);

					addOffset("singUP", 0, 4);
					addOffset("singRIGHT", 0, -20);
					addOffset("singLEFT", 0, -19);
					addOffset("singDOWN", 0, -20);
					addOffset('hairBlow', 45, -8);
					addOffset('hairFall', 0, -9);

					addOffset('scared', -2, -17);
					
					playAnim('danceRight');

				case 'bf-holding-gf':
					frames = Paths.getSparrowAtlas('characters/bfAndGF', 'week7');
					animation.addByPrefix('idle', 'BF idle dance', 24);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24);

					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24);
					animation.addByPrefix('bfCatch', 'BF catches GF', 24);

					animation.addByPrefix('firstDeath', 'BF Dies with GF', 24);
					animation.addByPrefix('deathLoop', 'BF Dead with GF Loop', 24, true);
					animation.addByPrefix('deathConfirm', 'RETRY confirm holding gf', 24);

					addOffset('idle', 0, 0);
					addOffset('singUP', -29, 10);
					addOffset('singRIGHT', -41, 23);
					addOffset('singLEFT', 12, 7);
					addOffset('singDOWN', -10, -10);
					addOffset('singUPmiss', -29, 10);
					addOffset('singRIGHTmiss', -41, 23);
					addOffset('singLEFTmiss', 12, 7);
					addOffset('singDOWNmiss', -10, -10);
					addOffset('bfCatch', 0, 0);
					addOffset('firstDeath', 37, 14);
					addOffset('deathLoop', 37, -3);
					addOffset('deathConfirm', 37, 28);

					playAnim('idle');

					flipX = true;

				case 'pico-speaker':
					frames = Paths.getSparrowAtlas('characters/picoSpeaker', 'week7');
		
					animation.addByPrefix('shoot1', "Pico shoot 1", 24);
					animation.addByPrefix('shoot2', "Pico shoot 2", 24);
					animation.addByPrefix('shoot3', "Pico shoot 3", 24);
					animation.addByPrefix('shoot4', "Pico shoot 4", 24);

					addOffset('shoot1', 0, 0);
					addOffset('shoot2', -1, -128);
					addOffset('shoot3', 412, -64);
					addOffset('shoot4', 439, -19);

					loadMappedAnims();

					playAnim('shoot1', false, false, animation.getByName('shoot1').frames.length - 3);
				case 'dad':
					// DAD ANIMATION LOADING CODE
					tex = Paths.getSparrowAtlas('DADDY_DEAREST', 'shared');
					frames = tex;
					animation.addByPrefix('idle', 'Dad idle dance', 24);
					animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
					animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
					animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
					animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

					addOffset('idle');
					addOffset("singUP", -6, 50);
					addOffset("singRIGHT", 0, 27);
					addOffset("singLEFT", -10, 10);
					addOffset("singDOWN", 0, -30);

					playAnim('idle');
				case 'spooky':
					tex = Paths.getSparrowAtlas('spooky_kids_assets', 'week2');
					frames = tex;
					animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
					animation.addByPrefix('singLEFT', 'note sing left', 24, false);
					animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
					animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
					animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

					addOffset('danceLeft');
					addOffset('danceRight');

					addOffset("singUP", -20, 26);
					addOffset("singRIGHT", -130, -14);
					addOffset("singLEFT", 130, -10);
					addOffset("singDOWN", -50, -130);

					playAnim('danceRight');
				case 'mom':
					tex = Paths.getSparrowAtlas('Mom_Assets', 'week4');
					frames = tex;

					animation.addByPrefix('idle', "Mom Idle", 24, false);
					animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
					animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
					animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
					// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
					// CUZ DAVE IS DUMB!
					animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

					addOffset('idle');
					addOffset("singUP", 14, 71);
					addOffset("singRIGHT", 10, -60);
					addOffset("singLEFT", 250, -23);
					addOffset("singDOWN", 20, -160);

					playAnim('idle');

				case 'mom-car':
					tex = Paths.getSparrowAtlas('momCar', 'week4');
					frames = tex;

					animation.addByPrefix('idle', "Mom Idle", 24, false);
					animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
					animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
					animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
					// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
					// CUZ DAVE IS DUMB!
					animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

					addOffset('idle');
					addOffset("singUP", 14, 71);
					addOffset("singRIGHT", 10, -60);
					addOffset("singLEFT", 250, -23);
					addOffset("singDOWN", 20, -160);

					playAnim('idle');
			case 'monster':
					tex = Paths.getSparrowAtlas('Monster_Assets', 'week2');
					frames = tex;
					animation.addByPrefix('idle', 'monster idle', 24, false);
					animation.addByPrefix('singUP', 'monster up note', 24, false);
					animation.addByPrefix('singDOWN', 'monster down', 24, false);
					animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
					animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

					addOffset('idle', 0, 10);
					addOffset("singUP", -20, 100);
					addOffset("singRIGHT", -30, 20);
					addOffset("singLEFT", -51, 30);
					addOffset("singDOWN", -40, -74);
					playAnim('idle');
			case 'monster-christmas':
					tex = Paths.getSparrowAtlas('christmas/monsterChristmas', 'week5');
					frames = tex;
					animation.addByPrefix('idle', 'monster idle', 24, false);
					animation.addByPrefix('singUP', 'monster up note', 24, false);
					animation.addByPrefix('singDOWN', 'monster down', 24, false);
					animation.addByPrefix('singLEFT', 'Monster Right note', 24, false);
					animation.addByPrefix('singRIGHT', 'Monster left note', 24, false);

					addOffset('idle');
					addOffset("singUP", -20, 50);
					addOffset("singRIGHT", -30);
					addOffset("singLEFT", -51);
					addOffset("singDOWN", -40, -94);
					playAnim('idle');
				case 'pico':
					tex = Paths.getSparrowAtlas('Pico_FNF_assetss', 'week3');
					frames = tex;
					animation.addByPrefix('idle', "Pico Idle Dance", 24);
					animation.addByPrefix('singUP', 'pico Up note0', 24, false);
					animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
					animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

					addOffset('idle');
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", 65, 9);
					addOffset("singLEFT", -68, -7);
					addOffset("singDOWN", 200, -70);
					addOffset("singUPmiss", -19, 67);
					addOffset("singRIGHTmiss", 62, 64);
					addOffset("singLEFTmiss", -60, 41);
					addOffset("singDOWNmiss", 210, -28);

					playAnim('idle');

					flipX = true;

				/*case 'bf':
					var tex = Paths.getSparrowAtlas('BOYFRIEND', 'shared');
					frames = tex;
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);

					animation.addByPrefix('firstDeath', "BF dies", 24, false);
					animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
					animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

					animation.addByPrefix('scared', 'BF idle shaking', 24);

					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);
					addOffset('firstDeath', 37, 11);
					addOffset('deathLoop', 37, 5);
					addOffset('deathConfirm', 37, 69);
					addOffset('scared', -4);

					playAnim('idle');

					flipX = true;
				*/

				case 'bf-christmas':
					var tex = Paths.getSparrowAtlas('christmas/bfChristmas', 'week5');
					frames = tex;
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);

					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);

					playAnim('idle');

					flipX = true;
				case 'bf-car':
					var tex = Paths.getSparrowAtlas('bfCar', 'week4');
					frames = tex;
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					playAnim('idle');

					flipX = true;
				case 'bf-pixel':
					frames = Paths.getSparrowAtlas('weeb/bfPixel', 'week6');
					animation.addByPrefix('idle', 'BF IDLE', 24, false);
					animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
					animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
					animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
					animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

					addOffset('idle');
					addOffset("singUP");
					addOffset("singRIGHT");
					addOffset("singLEFT");
					addOffset("singDOWN");
					addOffset("singUPmiss");
					addOffset("singRIGHTmiss");
					addOffset("singLEFTmiss");
					addOffset("singDOWNmiss");

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					playAnim('idle');

					width -= 100;
					height -= 100;

					antialiasing = false;

					flipX = true;
				case 'bf-pixel-dead':
					frames = Paths.getSparrowAtlas('weeb/bfPixelsDEAD', 'week6');
					animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
					animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
					animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
					animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
					animation.play('firstDeath');

					addOffset('firstDeath');
					addOffset('deathLoop', -37);
					addOffset('deathConfirm', -37);
					playAnim('firstDeath');
					// pixel bullshit
					setGraphicSize(Std.int(width * 6));
					updateHitbox();
					antialiasing = false;
					flipX = true;

				case 'senpai':
					frames = Paths.getSparrowAtlas('weeb/senpai', 'week6');
					animation.addByPrefix('idle', 'Senpai Idle', 24, false);
					animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
					animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
					animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

					addOffset('idle');
					addOffset("singUP", 5, 37);
					addOffset("singRIGHT");
					addOffset("singLEFT", 40);
					addOffset("singDOWN", 14);

					playAnim('idle');

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					antialiasing = false;
				case 'senpai-angry':
					frames = Paths.getSparrowAtlas('weeb/senpai', 'week6');
					animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
					animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
					animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
					animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

					addOffset('idle');
					addOffset("singUP", 5, 37);
					addOffset("singRIGHT");
					addOffset("singLEFT", 40);
					addOffset("singDOWN", 14);
					playAnim('idle');

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					antialiasing = false;

				case 'spirit':
					frames = Paths.getPackerAtlas('weeb/spirit', 'week6');
					animation.addByPrefix('idle', "idle spirit_", 24, false);
					animation.addByPrefix('singUP', "up_", 24, false);
					animation.addByPrefix('singRIGHT', "right_", 24, false);
					animation.addByPrefix('singLEFT', "left_", 24, false);
					animation.addByPrefix('singDOWN', "spirit down_", 24, false);

					addOffset('idle', -220, -280);
					addOffset('singUP', -220, -240);
					addOffset("singRIGHT", -220, -280);
					addOffset("singLEFT", -200, -280);
					addOffset("singDOWN", 170, 110);

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					playAnim('idle');

					antialiasing = false;

				case 'parents-christmas':
					frames = Paths.getSparrowAtlas('christmas/mom_dad_christmas_assets', 'week5');
					animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
					animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
					animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
					animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
					animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

					animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

					animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
					animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);	
					animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

					addOffset('idle');
					addOffset("singUP", -47, 24);
					addOffset("singRIGHT", -1, -23);
					addOffset("singLEFT", -30, 16);
					addOffset("singDOWN", -31, -29);
					addOffset("singUP-alt", -47, 24);
					addOffset("singRIGHT-alt", -1, -24);
					addOffset("singLEFT-alt", -30, 15);
					addOffset("singDOWN-alt", -30, -27);

					playAnim('idle');
				case 'tankman':
					tex = Paths.getSparrowAtlas('characters/tankmanCaptain', 'week7');
					frames = tex;
					animation.addByPrefix('idle', 'Tankman Idle Dance', 24);
					animation.addByPrefix('singUP', 'Tankman UP note 1', 24);
					animation.addByPrefix('singRIGHT', 'Tankman Right Note 1', 24);
					animation.addByPrefix('singDOWN', 'Tankman DOWN note 1', 24);
					animation.addByPrefix('singLEFT', 'Tankman Note Left 1', 24);

					animation.addByPrefix('tankUgh', 'TANKMAN UGH', 24);
					animation.addByPrefix('tankTalk', 'PRETTY GOOD tankman', 24, true);

					flipX = true;

					addOffset('idle', 0, 0);
					addOffset('singUP', 24, 56);
					addOffset('singLEFT', -1, -7);
					addOffset('singRIGHT', 100, -14);
					addOffset('singDOWN', 98, -90);
					addOffset('singUPmiss', 53, 84);
					addOffset('singRIGHTmiss', -1, -3);
					addOffset('singLEFTmiss', -30, 16);
					addOffset('singDOWNmiss', 69, -99);

					addOffset('tankUgh', 24, 56);
					addOffset('tankTalk', 98, -90);

					playAnim('idle');
			}
		}

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer && curCharacter.toLowerCase() != 'pico-speaker')
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			switch(curCharacter){
				default:
					singHold = 4;
				case 'dad':
					singHold = 6.1;
			}

			if (holdTimer >= Conductor.stepCrochet * singHold * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		if (animation.exists('danceLeft') && animation.exists('danceRight') && animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
			playAnim('danceRight');

		switch (curCharacter.toLowerCase()){
			case 'pico-speaker':
				if (animationNotes.length > 0)
				{
					if (Conductor.songPosition > animationNotes[0][0])
					{
						Engine.debugPrint('played shoot anim' + animationNotes[0][1]);

						var shootAnim:Int = 1;

						if (animationNotes[0][1] >= 2)
							shootAnim = 3;
	
						shootAnim += FlxG.random.int(0, 1);
	
						playAnim('shoot' + shootAnim, true);
						animationNotes.shift();
					}
				}
	
				if (animation.curAnim.finished)
				{
					playAnim(animation.curAnim.name, false, false, animation.curAnim.numFrames - 3);
				}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			if (animation.exists('danceLeft') && animation.exists('danceRight') && !animation.curAnim.name.startsWith('hair')){
				danced = !danced;

				var forcelol:Bool = false;

				if (curCharacter.toLowerCase().startsWith('gf'))
					forcelol = true; // idk if this will help with anything but i do it anyway lol

				if (danced)
					playAnim('danceRight', forcelol);
				else
					playAnim('danceLeft', forcelol);
			}
			else{
				switch (curCharacter.toLowerCase()){
					default:
						playAnim('idle');
					case 'pico-speaker':
						// do nothing
				}
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function loadMappedAnims()
	{
		switch (curCharacter.toLowerCase()){
			case 'pico-speaker':
				var swagshit = Song.loadFromJson('picospeaker', 'stress');

				var notes = swagshit.notes;
		
				for (section in notes)
				{
					for (idk in section.sectionNotes)
					{
						animationNotes.push(idk);
					}
				}
		
				TankmenBG.animationNotes = animationNotes;
		
				Engine.debugPrint('' + animationNotes);
				animationNotes.sort(sortAnims);
		}
	}

	function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]);
	}

	public function singAnimPlay(animationName:String, force:Bool){ // smart way of fixing the improper singing animations on flipped assets
		switch (animationName){
			default:
				playAnim(animationName, force);
			case 'singLEFT':
				if (flipX)
					playAnim('singRIGHT', force);
				else
					playAnim(animationName, force);
			case 'singRIGHT':
				if (flipX)
					playAnim('singLEFT', force);
				else
					playAnim(animationName, force);
			case 'singLEFT-alt':
				if (flipX)
					playAnim('singRIGHT-alt', force);
				else
					playAnim(animationName, force);
			case 'singRIGHT-alt':
				if (flipX)
					playAnim('singLEFT-alt', force);
				else
					playAnim(animationName, force);
		}
	}

	private function loadCustomCharacter(isMod:Bool = true){
		var charJson;

		if (isMod == true){
			charJson = Json.parse(Modding.retrieveContent('$curCharacter.json', 'data/characters'));

			frames = FlxAtlasFrames.fromSparrow(Modding.retrieveImage(charJson.image, 'images/characters'),
			Modding.retrieveContent(charJson.image + '.xml', 'images/characters'));
		}
		else{
			charJson = Json.parse(File.getContent('assets/characters/$curCharacter.json'));

			var imagelol:String = charJson.image;

			frames = Paths.getSparrowAtlas('characters/$imagelol', 'shared');
		}

		animationsArray = charJson.animations;
		if (animationsArray != null){
			for (anim in animationsArray){
				var xmlAnim:String = '' + anim.xmlanim;
				var animName:String = '' + anim.name;
				var animFPS:Int = anim.fps;
				var loopAnimation:Bool = anim.loop;
				var indiceslol:Array<Int> = anim.indices;

				if (animFPS <= 0)
					animFPS = 24;
				
				if (anim.indices == null || anim.indices != null && anim.indices == [])
					animation.addByPrefix(animName, xmlAnim, animFPS, loopAnimation);
				else
					animation.addByIndices(animName, xmlAnim, indiceslol, "", animFPS, loopAnimation);

				if (anim.offsets != null)
					addOffset(animName, anim.offsets[0], anim.offsets[1]);
			}
		}

		if (isMod){
			Engine.debugPrint('$curCharacter Loaded as Json (Mod)');
			isModded = true;
			jsonCharacter = true;
		}
		else{
			Engine.debugPrint('$curCharacter Loaded as Json (Non-Mod)');
			jsonCharacter = true;
		}

		singHold = charJson.singHold;

		flipX = charJson.flipX;
		
		updateHitbox();

		if (charJson.charScale > 0){
			var scale:Float = charJson.charScale;
			setGraphicSize(Std.int(width * scale));
			updateHitbox();
		}

		antialiasing = charJson.antialiasing;

		jsonData = charJson;
	}
}

typedef AnimArray = {
	var xmlanim:String;
	var name:String;
	var offsets:Array<Int>;
	var ?fps:Int;
	var ?indices:Array<Int>;
	var ?loop:Bool;
}