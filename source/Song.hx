package;

import util.EventNote.EventSection;
import util.EventNote.EventNote;
import engine.modding.SpunModLib.ModLib;
import engine.modding.SpunModLib.ModAssets;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var ?events:Array<EventSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var player1:String;
	var player2:String;
	var ?gfVersion:String;
	var ?stage:String;
	var ?style:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

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
		var rawJson = ModAssets.getContent("data/charts/" + folder.toLowerCase() + '/' + jsonInput.toLowerCase() + '.json', null, ModLib.getModID(ModLib.curMod), null).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
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
