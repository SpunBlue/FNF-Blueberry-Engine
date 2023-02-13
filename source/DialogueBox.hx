package;

import game.PlayState;
import lime.math.RGBA;
import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogueList:Array<DialogueShit> = [];
	var json:DialogueShitJson;

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueJson:DialogueShitJson)
	{
		super();

		json = dialogueJson;

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		var xOff:Float = json.boxXOffset;
		var yOff:Float = json.boxYOffset;

		box = new FlxSprite(-20 + xOff, 45 + yOff);
		if (FileSystem.exists('assets/images/' + dialogueJson.boxImage + '.png') && FileSystem.exists('assets/images/' + dialogueJson.boxXML + '.xml')){
			box.frames = Paths.getSparrowAtlas(dialogueJson.boxImage, 'shared');
			box.animation.addByPrefix('normalOpen', dialogueJson.boxOpenAnimation, dialogueJson.fps, false);
			box.animation.addByPrefix('normal', dialogueJson.boxIdleAnimation, dialogueJson.fps, true);
		}
		else{
			switch (PlayState.SONG.song.toLowerCase())
			{
				default:
					box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel', 'week6');
					box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
					box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

					box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel', 'week6');
					box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
					box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
	
				case 'thorns':
					box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil', 'week6');
					box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
					box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);
			}
		}

		this.dialogueList = dialogueJson.dialogues;

		portraitLeft = new FlxSprite();
		portraitRight = new FlxSprite();

		add(portraitLeft);
		add(portraitRight);
		
		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);

		portraitLeft.visible = false;
		portraitRight.visible = false;

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.alpha = 0;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dropText.color = FlxColor.GRAY;
		swagDialogue.color = FlxColor.BLACK;

		if (dialogueJson.usePixelFont == true){
			dropText.font = 'Pixel Arial 11 Bold';
			swagDialogue.font = 'Pixel Arial 11 Bold';
		}
		else{
			dropText.font = Paths.font("PhantomMuff.ttf");
			swagDialogue.font = Paths.font("PhantomMuff.ttf");
		}

		if (PlayState.storyWeek == 6){
			box.screenCenter(X);

			handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox', 'week6'));
			add(handSelect);

			dropText.color = 0xFFD89494;
			dropText.alpha = 1;

			swagDialogue.color = 0xFF3F2021;

			dropText.font = 'Pixel Arial 11 Bold';
			swagDialogue.font = 'Pixel Arial 11 Bold';
		}
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY  && dialogueStarted == true)
		{				
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
						FlxG.sound.music.fadeOut(2.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						PlayState.inCutscene = false;
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0].dialogue);

		if (dialogueList[0].speed > 0)
			swagDialogue.start(dialogueList[0].speed, true);
		else
			swagDialogue.start(0.04, true);

		var lXOff:Float = 0;
		var rXOff:Float = 0;
		var yOff:Float = 0;

		if (json.leftPortraitXOffset != null)
			lXOff = json.leftPortraitXOffset;

		if (json.rightPortraitXOffset != null)
			rXOff = json.rightPortraitXOffset;

		if (json.portraitYOffset != null)
			yOff = json.portraitYOffset;

		switch (dialogueList[0].facing.toLowerCase()){
			case 'left':
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;

					portraitLeft.loadGraphic(Paths.image(dialogueList[0].image));

					if (portraitLeft.flipX != false)
						portraitLeft.flipX = false;

					if (PlayState.storyWeek == 6)
						portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
					portraitLeft.updateHitbox();
					portraitLeft.setPosition(box.x + lXOff, (box.y - portraitLeft.height) + yOff);
				}
			case 'right':
				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;

					portraitRight.loadGraphic(Paths.image(dialogueList[0].image));

					if (portraitRight.flipX != true)
						portraitRight.flipX = true;

					if (PlayState.storyWeek == 6)
						portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
					portraitRight.updateHitbox();
					portraitRight.setPosition((box.width - portraitRight.width) + rXOff, (box.y - portraitRight.height) + yOff);
				}
		}
	}
}

typedef DialogueShitJson = {
	var ?boxImage:String;
	var ?boxXML:String;
	var ?boxOpenAnimation:String;
	var ?boxIdleAnimation:String;
	var ?boxXOffset:Float;
	var ?boxYOffset:Float;
	var ?portraitYOffset:Float;
	var ?leftPortraitXOffset:Float;
	var ?rightPortraitXOffset:Float;
	var ?fps:Int;
	var ?color:FlxColor;
	var ?usePixelFont:Bool;
	var dialogues:Array<DialogueShit>;
}

typedef DialogueShit = {
	var dialogue:String;
	var ?speed:Float; // Lower is faster and Higher as slower... for some reason.
	var image:String;
	var facing:String; // Left or Right
}
