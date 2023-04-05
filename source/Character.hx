package;

import engine.modding.SpunModLib.Mod;
import engine.modding.SpunModLib.ModLib;
import engine.modding.SpunModLib.ModAssets;
import haxe.Json;
import engine.Engine;
import game.PlayState;
import Section.SwagSection;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSort;
import haxe.io.Path;
import engine.modutil.ModVariables;

using StringTools;

// Only use for default characters
class CharVar{
	public static var defChars:Map<String, CharJson> = new Map();
}

class Character extends FlxSprite
{
	public var charJson:CharJson;

	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;
	var singHold:Float = 4;

	public var animationNotes:Array<Dynamic> = [];
	public var animOffsets:Map<String, Array<Dynamic>> = new Map();

	public var mod:Mod;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = true;

		// character generation shit here
		var addToDef:Bool = false;

		trace('Getting ready for loading of character $character');

		var chardata:Array<String> = character.split(':');

		if (chardata != null && chardata.length > 0){
			if (chardata[1] != null)
				mod = ModAssets.findMod(chardata[1]);
			else
				mod = ModLib.curMod;
		}
		else
			mod = ModLib.curMod;
		
		if (mod != null && ModVariables.characters.exists({string: '$character', mod: mod}))
			charJson = ModVariables.characters.get({string: '$character', mod: mod});
		else if (CharVar.defChars.exists('$character')){
			charJson = CharVar.defChars.get('$character');

			addToDef = true;
		}
		else{
			if (chardata != null && chardata.length > 0 && chardata[0] != null)
				character = chardata[0];

			charJson = Json.parse(ModAssets.getAsset('data/characters/$character.json', mod, null, 'shared'));

			if (mod == null || ModLib.getModID(ModLib.curMod) == null)
				addToDef = true;
		}

		if (charJson != null){
			if (charJson.isSpritesheet == null || charJson.isSpritesheet == false)
				frames = FlxAtlasFrames.fromSparrow(ModAssets.getAsset('images/' + charJson.imagePath, mod, null, 'shared'), ModAssets.getAsset('images/' + charJson.xmlPath, mod, null, 'shared'));
			else
				frames = FlxAtlasFrames.fromSpriteSheetPacker(ModAssets.getAsset('images/' + charJson.imagePath, mod, null, 'shared'), ModAssets.getAsset('images/' + charJson.xmlPath, mod, null, 'shared'));

			antialiasing = charJson.antialiasing;

			if (charJson.flipX != null)
				flipX = charJson.flipX;
			if (charJson.flipY != null)
				flipY = charJson.flipY;

			if (charJson.singHold != null)
				singHold = charJson.singHold;

			for (anim in charJson.animations){
				var animName:String = anim.name;
				var animPrefix:String = anim.prefix;
				var animFPS:Int = anim.fps;
				var animIndices:Array<Int> = anim.indices;
				var animOffsets:Array<Int> = anim.offsets;
				var loop:Bool = false;

				if (anim.loop != null)
					loop = anim.loop;

				if (animIndices != null && animIndices.length > 0)
					animation.addByIndices(animName, animPrefix, animIndices, "", animFPS, loop);
				else
					animation.addByPrefix(animName, animPrefix, animFPS, loop);

				if (animOffsets != null)
					addOffset(animName, animOffsets[0], animOffsets[1]);
			}

			if (charJson.size != null && charJson.size > 0)
				setGraphicSize(Std.int(width * charJson.size));

			if (!addToDef)
				ModVariables.characters.set({string: '$character', mod: mod}, charJson);
			else
				CharVar.defChars.set('$character', charJson);
		}
		else{
			trace('$character is equal to null, error in JSON!');
		}

		if (animation.exists('idle'))
			animation.play('idle');
		else if (animation.exists('danceRight'))
			animation.play('danceRight');

		// REPLACE LATER WITH "QUICKLOAD" SCRIPT!!! (HScript embeded in JSON)
		if (character.toLowerCase() == 'pico-speaker'){
			playAnim('shoot1');
			loadMappedAnims();
		}

		dance();
		animation.finish();

		if (isPlayer)
			flipX = !flipX;
	}

	public function loadMappedAnims()
	{
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

		trace(animationNotes);
		animationNotes.sort(sortAnims);
	}

	function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]);
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			try{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;
			}
			catch(e:Dynamic){
				trace('Error at Animation Hold Timer, $e');
			}

			try{
				if (holdTimer >= Conductor.stepCrochet * singHold * 0.001)
				{
					if (!debugMode)
						dance();
					holdTimer = 0;
				}
			}
			catch(e:Dynamic){
				trace('Error at detect when to Dance (Hold Timer), $e');
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
			case "pico-speaker":
				// for pico??
				if (animationNotes.length > 0)
				{
					if (Conductor.songPosition > animationNotes[0][0])
					{
						trace('played shoot anim' + animationNotes[0][1]);

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

		if (!debugMode && charJson.loopAfterIdle != null && charJson.loopAfterIdle != '')
		{
			if (!animation.curAnim.name.startsWith('sing') && animation.curAnim.finished)
				playAnim(charJson.loopAfterIdle);
		}
	}

	private var danced:Bool = false;

	public function isDancing(){
		return (animation.curAnim.name.startsWith('dance') || animation.curAnim.name == 'idle');
	}

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (animation.exists('danceLeft') && animation.exists('danceRight') && !animation.curAnim.name.startsWith('hair')){
			danced = !danced;

			if (danced)
				playAnim('danceRight', true);
			else
				playAnim('danceLeft', true);
		}
		else{
			switch (curCharacter.toLowerCase()){
				default:
					if (animation.exists('idle'))
						playAnim('idle');
				case 'pico-speaker':
					// do nothing
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		var animToPlay:String = AnimName;

		animation.play(animToPlay, Force, Reversed, Frame);

		var daOffset = animOffsets.get(animToPlay);
		if (animOffsets.exists(animToPlay))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (animToPlay == 'singLEFT')
			{
				danced = true;
			}
			else if (animToPlay == 'singRIGHT')
			{
				danced = false;
			}

			if (animToPlay == 'singUP' || animToPlay == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}

typedef CharJson = {
	var imagePath:String;
	var xmlPath:String;
	var Position:Array<Int>;
	var CamPosition:Array<Int>;
	var animations:Array<CharAnims>;
	var ?flipX:Bool;
	var ?flipY:Bool;
	var antialiasing:Bool;
	var ?singHold:Float;
	var ?size:Float;
	var ?isSpritesheet:Bool;
	var ?loopAfterIdle:String;
}

typedef CharAnims = {
	var prefix:String;
	var name:String;
	var fps:Int;
	var ?loop:Bool;
	var indices:Array<Int>;
	var ?offsets:Array<Int>;
}