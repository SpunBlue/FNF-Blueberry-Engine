package;

import haxe.Json;
import lime.utils.Assets;
import sys.io.File;
import engine.modding.Modding;
import sys.FileSystem;
import game.PlayState;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	
	private var strumLengthOffset:Float = Conductor.safeZoneOffset * 0.75;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var charSinger:Int;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var noteJson:NoteJson; // Json Data

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?singer:Int = -1, ?specialType:String, ?sustainNote:Bool = false, ?noteType:String = '')
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		charSinger = singer;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		if (specialType != null){
			if (FileSystem.exists(Modding.getFilePath(specialType + '.json', "scripts/notes"))){
				noteJson = Json.parse(Modding.retrieveContent(specialType + '.json', "scripts/notes"));
			}
			else if (Assets.exists(Paths.json("notes/" + specialType))){
				noteJson = Json.parse(File.getContent(Paths.json("notes/" + specialType)));
			}
		}
		
		if (noteJson != null && noteJson.image != null && noteJson.xml != null){
			var spriteAntialiasing:Bool = true;
			var spriteScale:Float = 0;

			if (noteJson.antialiasing != null)
				spriteAntialiasing = noteJson.antialiasing;

			if (noteJson.scale != null)
				spriteScale = noteJson.scale;

			frames = FlxAtlasFrames.fromSparrow(Modding.retrieveImage(noteJson.image, 'images'),
			Modding.retrieveContent(noteJson.xml + '.xml', 'images'));
	
			animation.addByPrefix('greenScroll', noteJson.animations.greenScroll);
			animation.addByPrefix('redScroll', noteJson.animations.redScroll);
			animation.addByPrefix('blueScroll', noteJson.animations.blueScroll);
			animation.addByPrefix('purpleScroll', noteJson.animations.purpleScroll);

			animation.addByPrefix('purpleholdend', noteJson.animations.purpleholdend);
			animation.addByPrefix('greenholdend', noteJson.animations.greenholdend);
			animation.addByPrefix('redholdend', noteJson.animations.redholdend);
			animation.addByPrefix('blueholdend', noteJson.animations.blueholdend);

			animation.addByPrefix('purplehold', noteJson.animations.purplehold);
			animation.addByPrefix('greenhold', noteJson.animations.greenhold);
			animation.addByPrefix('redhold', noteJson.animations.redhold);
			animation.addByPrefix('bluehold', noteJson.animations.bluehold);

			setGraphicSize(Std.int(width * (0.7 + spriteScale)));
			updateHitbox();
			antialiasing = spriteAntialiasing;

			if (isSustainNote && noteJson.sustainAlpha != null)
				alpha = noteJson.sustainAlpha;
		}
		else{
			switch (daStage)
			{
				case 'school' | 'schoolEvil':
					loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
	
					animation.add('greenScroll', [6]);
					animation.add('redScroll', [7]);
					animation.add('blueScroll', [5]);
					animation.add('purpleScroll', [4]);
	
					if (isSustainNote)
					{
						loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);
	
						animation.add('purpleholdend', [4]);
						animation.add('greenholdend', [6]);
						animation.add('redholdend', [7]);
						animation.add('blueholdend', [5]);
	
						animation.add('purplehold', [0]);
						animation.add('greenhold', [2]);
						animation.add('redhold', [3]);
						animation.add('bluehold', [1]);
					}
	
					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
	
				default:
					frames = Paths.getSparrowAtlas('NOTE_assets');
	
					animation.addByPrefix('greenScroll', 'green0');
					animation.addByPrefix('redScroll', 'red0');
					animation.addByPrefix('blueScroll', 'blue0');
					animation.addByPrefix('purpleScroll', 'purple0');
	
					animation.addByPrefix('purpleholdend', 'pruple end hold');
					animation.addByPrefix('greenholdend', 'green hold end');
					animation.addByPrefix('redholdend', 'red hold end');
					animation.addByPrefix('blueholdend', 'blue hold end');
	
					animation.addByPrefix('purplehold', 'purple hold piece');
					animation.addByPrefix('greenhold', 'green hold piece');
					animation.addByPrefix('redhold', 'red hold piece');
					animation.addByPrefix('bluehold', 'blue hold piece');
	
					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();
					antialiasing = true;
			}
		}

		updateHitbox();

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		// Engine.debugPrint(prevNote);

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (strumTime > Conductor.songPosition - strumLengthOffset
				&& strumTime < Conductor.songPosition + strumLengthOffset)
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
// Json Path: "(Mod File Location)/scripts/notes/name.json"
// What this is: Custom Notes that can be selected to be used in the ChartingState in the Notes tab.
typedef NoteJson = {
	var ?image:String; // path to image (root at : "images/"") don't include extension. don't include for default.
	var ?xml:String; // path to xml (root at : "images/"") don't include extension. don't include for default.
	var ?animations:NoteAnimations; // required if image and xml doesn't equal nothing.
	var ?scale:Float; // 0.1 to inf
	var ?sustainAlpha:Float; // 0.1 to inf (Don't include for default)
	var ?antialiasing:Bool; // true or false
	var ?onHit:NoteActions; // don't include if you want to perform regular events.
	var ?onSustain:NoteActions; // don't include if you want to perform regular events.
	var ?onDadHit:NoteActions; // don't include if you want to perform regular events.
	var ?onDadSustain:NoteActions; // don't include if you want to perform regular events.
	var ?onMiss:NoteActions; // don't include if you want to perform regular events.
	var ?allowScoring:Bool;
	var ?scoreOnSick:Int;
	var ?scoreOnGood:Int;
	var ?scoreOnBad:Int;
	var ?scoreOnShit:Int;
}

typedef NoteActions = {
	var ?health:Float; // 0.1 to 1.0 how much health to give the player, (Can be negative).
	var ?playAnimationBF:String; // Animation Name
	var ?playAnimationDAD:String; // Animation Name
	var ?instaKill:Bool; // Kill player instantly
}

typedef NoteAnimations = {
	var greenScroll:String;
	var redScroll:String;
	var blueScroll:String;
	var purpleScroll:String;
	var purpleholdend:String;
	var greenholdend:String;
	var redholdend:String;
	var blueholdend:String;
	var purplehold:String;
	var greenhold:String;
	var redhold:String;
	var bluehold:String;	
}
