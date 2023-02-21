package game.editors;

import flixel.FlxSprite;

class EventNote extends FlxSprite
{
    public var strumTime:Float;
    public var thisEvent:ChartEvent;

    public function new(event:ChartEvent){
        super();

        this.strumTime = event.strumtime;
        this.thisEvent = event;

        loadGraphic(Paths.image('event'));
    }
}

typedef ChartEvent = {
    var strumtime:Float;
    var event:String;
    var ?variable1:String;
    var ?variable2:String;
    var ?variable3:String;
    var ?variable4:String;
    var ?variable5:String;
}

typedef EventSection =
{
	var eventNotes:Array<ChartEvent>;
	var lengthInSteps:Int;
	var typeOfSection:Int; // dunno what dis does
}