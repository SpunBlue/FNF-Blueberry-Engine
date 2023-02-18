package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import game.PlayState;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import shaderslmfao.ColorSwap;

class StrumNotes extends FlxSpriteGroup{
	public var arrows:Array<StrumArrow> = [];
	public var style:String = '';

	private var lastStyle:String = '';

	var didTransition:Bool = false;

    public function new(x:Float, y:Float, strumLineY:Float, xOffset:Float, ?style:String = '', downscroll:Bool = false){
		setSize(FlxG.width, FlxG.height);

        super(x, y);

		this.style = style;
		lastStyle = style;

        for (i in 0...4){
            var babyArrow:StrumArrow = new StrumArrow(0, strumLineY, downscroll);
            var colorswap:ColorSwap = new ColorSwap();
            babyArrow.shader = colorswap.shader;
            colorswap.update(Note.arrowColors[i]);

            switch (style)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * PlayState.daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 14, 18], 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 3');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.centerOffsets();

            babyArrow.ID = i;

            babyArrow.x += 50;
			babyArrow.x += xOffset;

            babyArrow.animation.play('static');
			babyArrow.alpha = 0; // for note transition
			add(babyArrow);

			arrows.push(babyArrow);
        }
    }

	override function update(elapsed:Float){
		super.update(elapsed);
	}

	/**
	 * Updates the Offsets for Confirm/Static Animations
	 */
	public function updateOffsets(){
		for (i in 0...4){
			if (arrows[i].animation.curAnim.name == 'confirm' && style == ''){
				arrows[i].centerOffsets();
				arrows[i].offset.x -= 13;
				arrows[i].offset.y -= 13;
			}
			else{
				arrows[i].centerOffsets();
			}
		}
	}

	public function doNoteTransition(){
		if (!didTransition){
			var i = 0;

			for (babyArrow in arrows){
				babyArrow.y -= 10;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
	
				++i;
			}

			didTransition = true;
		}
	}
}

class StrumArrow extends FlxSprite{
	public var isDownscroll:Bool = false;

	public function new (x:Float, y:Float, downscroll:Bool){
		super(x, y);

		isDownscroll = downscroll;
	}
}