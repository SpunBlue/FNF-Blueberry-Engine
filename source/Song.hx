package;

import engine.modding.Modding;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var stage:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var ?seperatedVocalTracks:Bool;
	var speed:Float;
	var player1:String;
	var player2:String;
	var validScore:Bool;
	var ?events:Array<Events>;
	var ?introVideo:String;
	var ?outroVideo:String;
}
typedef Events = {
	var name:String;
	var ?ms:Float;
	var ?var1:String;
	var ?var2:String;
	var ?var3:String;
	var ?var4:String;
	var ?var5:String;
}

class Song
{
	public var song:String;
	public var stage:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var seperatedVocalTracks:Bool = false;
	public var speed:Float = 1;
	public var events:Array<Events> = [];
	public var introVideo:String;
	public var outroVideo:String;

	public var player1:String = 'bf';
	public var player2:String = 'dad';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = Assets.getText(Paths.json('charts/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		return parseJSONshit(rawJson);
	}

	public static function loadModChart(jsonInput:String, ?folder:String):SwagSong{
        var rawJson = Modding.retrieveContent('$jsonInput.json', 'data/charts/$folder').toString();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

        return parseJSONshit(rawJson);
    }

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}