package;

import haxe.Json;
import engine.modding.SpunModLib.Mod;
import engine.modding.SpunModLib.ModLib;
import engine.modding.SpunModLib.ModAssets;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import engine.Engine;
import game.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import shaderslmfao.ColorSwap;
import util.ui.PreferencesMenu;
import StrumNotes.StrumArrow;

using StringTools;

#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	private var willMiss:Bool = false;

	public var gfNote:Bool = false;
	public var altNote:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var colorSwap:ColorSwap;
	public var noteScore:Float = 1;

	public var missed:Bool = false;

	public var sustainParent:Note;
	public var sustainChildren:Array<Note> = [];

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public static var arrowColors:Array<Float> = [1, 1, 1, 1];

	public var strumTrack:StrumArrow;
	private var xOffset:Float;

	var defaultAlpha:Float = 1;

	public var style:String = '';

	var inChart:Bool = false;

	public var noteFuckingDying:Bool = false;
	public var hideBitch:Bool = false;

	/**
	 * Only used for the Charter.
	 */
	public var belongsToSection:Int = 0;

	public var sangByCharID:Int = 0;

	public var noteJson:NoteJson;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?tracker:StrumArrow, ?style:String = '', ?inCharter:Bool = true, ?specialType:String)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		this.style = style;

		inChart = inCharter;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		if (noteData != -1) {
			if (isSustainNote && !prevNote.isSustainNote) {
				sustainParent = prevNote;
				prevNote.sustainChildren.push(this);
			} else if (isSustainNote && prevNote.isSustainNote) {
				sustainParent = prevNote.sustainParent;
				sustainParent.sustainChildren.push(this);
			}
		}

		if (specialType != null){
		    if (ModAssets.assetExists('data/notes/' + specialType + '.json', null, ModLib.getModID(ModLib.curMod), 'shared')){
			    noteJson = Json.parse(ModAssets.getAsset('data/notes/' + specialType + '.json', null, ModLib.getModID(ModLib.curMod), 'shared'));
		    }
		    if (ModAssets.assetExists('data/notes/' + specialType + '.hx', null, ModLib.getModID(ModLib.curMod), 'shared')){
			    PlayState.script.loadScript('notes', specialType, ModLib.getModID(ModLib.curMod));
				PlayState.script.interp.variables.set("specialType", specialType);
		    }
		}

		strumTrack = tracker;

		updateStyle(style);
	}

	public function updateColors():Void
	{
		colorSwap.update(arrowColors[noteData]);
	}

	public function updateTracker(strumNote:StrumArrow){
		strumTrack = strumNote;
	}

	public function updateStyle(style:String){
		if (noteJson != null && noteJson.imagePath != null && noteJson.xmlPath != null){
			var spriteAntialiasing:Bool = true;
			var spriteScale:Float = 0;

			if (noteJson.antialiasing != null)
				spriteAntialiasing = noteJson.antialiasing;

			if (noteJson.scale != null)
				spriteScale = noteJson.scale;

			frames = FlxAtlasFrames.fromSparrow(ModAssets.getAsset('images/' + noteJson.imagePath, ModLib.curMod, null, 'shared'), ModAssets.getAsset('images/' + noteJson.xmlPath, ModLib.curMod, null, 'shared'));

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

			if (isSustainNote && noteJson.alpha != null)
				alpha = noteJson.alpha;
		}
		else{
		    switch (style)
		    {
			    case 'pixel':
				    loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);

				    animation.add('greenScroll', [6]);
				    animation.add('redScroll', [7]);
				    animation.add('blueScroll', [5]);
				    animation.add('purpleScroll', [4]);

				    if (isSustainNote)
				    {
					    loadGraphic(Paths.image('weeb/pixelUI/arrowEnds', 'week6'), true, 7, 6);

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

				    antialiasing = false;

			    default:
				    frames = Paths.getSparrowAtlas('NOTE_assets');

				    animation.addByPrefix('greenScroll', 'green instance');
				    animation.addByPrefix('redScroll', 'red instance');
				    animation.addByPrefix('blueScroll', 'blue instance');
				    animation.addByPrefix('purpleScroll', 'purple instance');

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

				    // colorSwap.colorToReplace = 0xFFF9393F;
				    // colorSwap.newColor = 0xFF00FF00;

				    // color = FlxG.random.color();
				    // color.saturation *= 4;
				    // replaceColor(0xFFC1C1C1, FlxColor.RED);
		    }
		}

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		updateColors();

		switch (noteData)
		{
			case 0:
				animation.play('purpleScroll');
			case 1:
				animation.play('blueScroll');
			case 2:
				animation.play('greenScroll');
			case 3:
				animation.play('redScroll');
		}

		// Engine.debugPrint(prevNote);

		if (isSustainNote && prevNote != null)
		{
			if (prevNote.style != style)
				prevNote.updateStyle(style);

			noteScore * 0.2;
			defaultAlpha = 0.6;

			if (strumTrack != null && strumTrack.isDownscroll)
				angle = 180;

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

			switch (style){
				default:
					xOffset += 35;
				case 'pixel':
					xOffset += 30;
			}

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
		if (strumTrack != null){
			x = strumTrack.x + xOffset;

			hideBitch = !strumTrack.visible;
		}

		super.update(elapsed);

		if (hideBitch)
			alpha = 0;
		else if (!inChart)
			alpha = defaultAlpha;

		if (mustPress)
		{
			// miss on the NEXT frame so lag doesnt make u miss notes
			if (willMiss && !wasGoodHit)
			{
				tooLate = true;
				canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset)
				{
					if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.7))
						canBeHit = true;
				}
				else
				{
					canBeHit = true;
					willMiss = true;
				}
			}
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}
	}

	/**
	 * I had something more planned out, but I couldn't get it to work.
	 * @param notes don't fucking worry about it dawg
	 */
	public function fuckNote(notes:FlxTypedGroup<Note>){
		noteFuckingDying = true;

		FlxTween.tween(this, {defaultAlpha: 0}, 0.5, {ease: FlxEase.circOut, onComplete: function(v:Dynamic){
			kill();
			notes.remove(this, true);
			destroy();
		}});
	}
}

typedef NoteData = {
	var ?singerID:Int;
}

typedef NoteJson = {
	var ?imagePath:String;
	var ?xmlPath:String;
	var ?animations:NoteAnimations;
	var ?scale:Float;
	var ?alpha:Float;
	var ?antialiasing:Bool;
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
