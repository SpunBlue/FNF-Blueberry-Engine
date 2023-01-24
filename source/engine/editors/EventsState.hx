package engine.editors;

import game.PlayState;
import flixel.FlxG;
import flixel.addons.ui.FlxUITabMenu;
import Song.SwagSong;

class EventsState extends MusicBeatState{
    var UI_box:FlxUITabMenu;

    var tabs = [
        {name: "Events", label: 'Events'}
    ];

    override function create()
    {
		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
        UI_box.screenCenter();
		add(UI_box);
    }

    override function update(elapsed:Float){
        super.update(elapsed);

        if (controls.BACK){
            FlxG.switchState(new ChartingState());
        }
    }
}