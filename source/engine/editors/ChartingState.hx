package engine.editors;

import Song;
import sys.FileSystem;
import engine.modding.Modding;
import game.PlayState;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;
	var eventGridBG:FlxSprite;

	var _song:SwagSong;
	var eventNotes:FlxTypedGroup<EventNote> = new FlxTypedGroup();
	var eventSelected:Int = -1;

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;

	var vocals:FlxSound;
	var vocals2:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var enableHitsounds = false;
	var hitSound:FlxSound;

	var validEvents:Array<Dynamic> = PlayState.validEvents;

	var eventDropDown:FlxUIDropDownMenu;

	var eventVar1:FlxUIInputText;
	var eventVar2:FlxUIInputText;
	var eventVar3:FlxUIInputText;
	var eventVar4:FlxUIInputText;
	var eventVar5:FlxUIInputText;
	
	var eventVar1InfoText:FlxText;
	var eventVar2InfoText:FlxText;
	var eventVar3InfoText:FlxText;
	var eventVar4InfoText:FlxText;
	var eventVar5InfoText:FlxText;

	var eventInstructionText:FlxText;

	var ui_videoIntroName:FlxUIInputText;
	var ui_videoOutroName:FlxUIInputText;

	var noteActionDropdown:FlxUIDropDownMenu;

	override function create()
	{
		hitSound = new FlxSound();
		hitSound.loadEmbedded(Paths.sound('hit', 'shared'));

		curSection = lastSection;

		var funnyBG:FlxSprite = new FlxSprite();
		funnyBG.loadGraphic(Paths.image('menuDesat'));
		funnyBG.color = FlxColor.GRAY;
		funnyBG.scrollFactor.set(0, 0);
		add(funnyBG);

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);

		eventGridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE, GRID_SIZE * 16);
		eventGridBG.x -= GRID_SIZE;
		add(eventGridBG);

		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 64);
		rightIcon.setGraphicSize(0, 64);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		var gridBlackLine2:FlxSprite = new FlxSprite(0).makeGraphic(2, Std.int(eventGridBG.height), FlxColor.BLACK);
		add(gridBlackLine2);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				stage: 'default',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				gfVersion: 'gf',
				speed: 1,
				validScore: false,
				events: []
			};
		}

		FlxG.mouse.visible = true;

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Events", label: 'Events'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addEventsUI();

		add(curRenderedNotes);
		add(curRenderedSustains);
		add(eventNotes);

		super.create();

		updateHeads();
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			Engine.debugPrint('CHECKED!');
		};

		var check_voices_2 = new FlxUICheckBox(10, 45, null, null, "Seperated Vocals", 100);
		check_voices_2.checked = _song.seperatedVocalTracks;
		// _song.needsVoices = check_voices.checked;
		check_voices_2.callback = function()
		{
			_song.seperatedVocalTracks = check_voices_2.checked;
			Engine.debugPrint('CHECKED!');

			loadVocals();
		};

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		/*var songEventsButt:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 60, "Startup Events", function()
		{
			PlayState.SONG = _song;
			FlxG.switchState(new EventsState());
		});*/

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 0.1, 1, 1, 339, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));

		if (Modding.modLoaded && FileSystem.readDirectory('mods/' + Modding.curLoaded + '/data/characters/') != null){
			for (char in FileSystem.readDirectory('mods/' + Modding.curLoaded + '/data/characters/')){
				if (char != null && char.length > 0 && char.contains('.json')){
					characters.push(char.replace('.json', ''));
				}
			}
		}

		var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));

		if (Modding.modLoaded && FileSystem.readDirectory('mods/' + Modding.curLoaded + '/data/stages/') != null){
			for (stage in FileSystem.readDirectory('mods/' + Modding.curLoaded + '/data/stages/')){
				if (stage != null && stage.length > 0 && stage.contains('.json')){
					stages.push(stage.replace('.json', ''));
				}
			}
		}

		var player1DropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		player1DropDown.selectedLabel = _song.player1;

		var player2DropDown = new FlxUIDropDownMenu(140, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});
		player2DropDown.selectedLabel = _song.player2;

		var gfVersionDropDown = new FlxUIDropDownMenu(10, 150, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.gfVersion = characters[Std.parseInt(character)];
		});
		gfVersionDropDown.selectedLabel = _song.gfVersion;

		var stageDropDown = new FlxUIDropDownMenu(140, 150, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String)
		{
			_song.stage = stages[Std.parseInt(stage)];
		});

		var check_hitSounds = new FlxUICheckBox(10, check_mute_inst.y + 20, null, null, "Enable Hitsounds", 100);

		var text1:FlxText = new FlxText(10, check_mute_inst.y + 40, 0, "Intro Video");
		var text2:FlxText = new FlxText(10, check_mute_inst.y + 100, 0, "Outro Video");

		ui_videoIntroName = new FlxUIInputText(10, check_mute_inst.y + 60, 120, "", 8);
		ui_videoOutroName = new FlxUIInputText(10, check_mute_inst.y + 120, 120, "", 8);

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.add(text1);
		tab_group_song.add(text2);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);
		tab_group_song.add(check_voices);
		tab_group_song.add(check_voices_2);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		//tab_group_song.add(songEventsButt);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(check_hitSounds);
		tab_group_song.add(stageDropDown);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player2DropDown);
		tab_group_song.add(gfVersionDropDown);
		tab_group_song.add(ui_videoIntroName);
		tab_group_song.add(ui_videoOutroName);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addEventsUI():Void{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Events';

		var eventNames:Array<String> = [];

		for (array in validEvents){
			if (array != null){
				eventNames.push(array[0]);
			}
		}

		eventDropDown = new FlxUIDropDownMenu(10, 50, FlxUIDropDownMenu.makeStrIdLabelArray(eventNames, true), function(lol:String)
		{
			if (eventSelected >= 0 && _song.events != null && _song.events[eventSelected] != null){
				_song.events[eventSelected].name = eventDropDown.selectedLabel;
			}
		});

		eventVar1 = new FlxUIInputText(10, 100);
		eventVar1InfoText = new FlxText(eventVar1.width + 10, eventVar1.y);

		eventVar2 = new FlxUIInputText(10, 150);
		eventVar2InfoText = new FlxText(eventVar2.width + 10, eventVar2.y);

		eventVar3 = new FlxUIInputText(10, 200);
		eventVar3InfoText = new FlxText(eventVar3.width + 10, eventVar3.y);

		eventVar4 = new FlxUIInputText(10, 250);
		eventVar4InfoText = new FlxText(eventVar4.width + 10, eventVar4.y);

		eventVar5 = new FlxUIInputText(10, 300);
		eventVar5InfoText = new FlxText(eventVar5.width + 10, eventVar5.y);

		var saveButton:FlxButton = new FlxButton(0, 8, "Update", function()
		{
			if (eventSelected >= 0 && _song.events != null && _song.events[eventSelected] != null){
				_song.events[eventSelected].name = eventDropDown.selectedLabel;

				_song.events[eventSelected].var1 = 	eventVar1.text;
				_song.events[eventSelected].var2 = 	eventVar2.text;
				_song.events[eventSelected].var3 = 	eventVar3.text;
				_song.events[eventSelected].var4 = 	eventVar4.text;
				_song.events[eventSelected].var5 = 	eventVar5.text;

				Engine.debugPrint('Updated Event');
			}
		});

		var delButton:FlxButton = new FlxButton(100, 8, "Delete Event", function()
			{
				if (eventSelected >= 0 && _song.events != null && _song.events[eventSelected] != null){
					_song.events.remove(_song.events[eventSelected]);

					for (note in eventNotes){
						if (note != null && note.eventID == eventSelected){
							eventNotes.remove(note);
							note.kill();
						}
					}
	
					Engine.debugPrint('Deleted Event');
				}
			});

		eventInstructionText = new FlxText(10, 325);
		eventInstructionText.text = "Click to place, Right click to Edit\nYou cannot delete by clicking!";

		tab_group_section.add(eventVar1);
		tab_group_section.add(eventVar2);
		tab_group_section.add(eventVar3);
		tab_group_section.add(eventVar4);
		tab_group_section.add(eventVar5);
		tab_group_section.add(eventVar1InfoText);
		tab_group_section.add(eventVar2InfoText);
		tab_group_section.add(eventVar3InfoText);
		tab_group_section.add(eventVar4InfoText);
		tab_group_section.add(eventVar5InfoText);
		tab_group_section.add(eventInstructionText);
		tab_group_section.add(saveButton);
		tab_group_section.add(delButton);
		tab_group_section.add(eventDropDown);

		UI_box.addGroup(tab_group_section);
	}

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		// someone help fix this!!! it wont carry over some data!!!
		var swapSection:FlxButton = new FlxButton(10, 170, "Swap Section (Erases some Data)", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var stepperCharID:FlxUINumericStepper;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var text:FlxText = new FlxText(10, 40, 0, "Character ID (-1 is Selected Character)");

		stepperCharID = new FlxUINumericStepper(10, 60, 1, -1, -1, 1000);
		stepperCharID.value = -1;
		stepperCharID.name = "note_charID";

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply'); // I don't even think this does anything..
		
		var noteActions:Array<String> = [""];

		if (FileSystem.readDirectory('mods/' + Modding.curLoaded + '/scripts/notes/') != null){
			for (file in FileSystem.readDirectory('mods/' + Modding.curLoaded + '/scripts/notes/')){
				if (file != null && file.contains('.json')){
					noteActions.push(file.replace('.json', ''));
				}
			}
		}

		var instructionsNote:FlxText = new FlxText(10, 90, 0, "Note Scripts");

		noteActionDropdown = new FlxUIDropDownMenu(10, 110, FlxUIDropDownMenu.makeStrIdLabelArray(noteActions, true), function(lol:String)
		{	
			if (curSelectedNote != null)
				curSelectedNote[4] = noteActionDropdown.selectedLabel;

			updateGrid();
		});

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(stepperCharID);
		tab_group_note.add(text);
		tab_group_note.add(applyLength);
		tab_group_note.add(instructionsNote);
		tab_group_note.add(noteActionDropdown);

		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		if (Modding.modLoaded)
			FlxG.sound.playMusic(Modding.retrieveAudio('Inst', 'songs/$daSong'), 1, false);
		else
			FlxG.sound.playMusic(Paths.inst(daSong), 1, false);

		loadVocals();

		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;

					updateHeads();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
				case "Enable Hitsounds":
					enableHitsounds = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = nums.value;
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(nums.value);
			}
			else if (wname == 'note_susLength')
			{
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'note_charID')
				{
					curSelectedNote[3] = nums.value;
					updateGrid();
				}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = nums.value;
				updateGrid();
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		_song.bpm = tempBpm;

		if (_song.introVideo != ui_videoIntroName.text)
			_song.introVideo = ui_videoIntroName.text;

		if (_song.outroVideo != ui_videoIntroName.text)
			_song.outroVideo = ui_videoIntroName.text;

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');
	
			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}
	
			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			vocals.stop();
			FlxG.switchState(new PlayState());
		}

		if (FlxG.mouse.overlaps(gridBG)){
			if (FlxG.keys.justPressed.X)
				toggleAltAnimNote();

			if (FlxG.mouse.justPressed)
				{
					if (FlxG.mouse.overlaps(curRenderedNotes))
					{
						curRenderedNotes.forEach(function(note:Note)
						{
							if (FlxG.mouse.overlaps(note))
							{
								if (FlxG.keys.pressed.CONTROL)
								{
									selectNote(note);
								}
								else
								{
									trace('tryin to delete note...');
									deleteNote(note);
								}
							}
						});
					}
					else
					{
						if (FlxG.mouse.x > gridBG.x
							&& FlxG.mouse.x < gridBG.x + gridBG.width
							&& FlxG.mouse.y > gridBG.y
							&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
						{
							FlxG.log.add('added note');
							addNote();
						}
					}
				}
				if (FlxG.keys.justPressed.E)
					{
						changeNoteSustain(Conductor.stepCrochet);
					}
					if (FlxG.keys.justPressed.Q)
					{
						changeNoteSustain(-Conductor.stepCrochet);
					}
			
					if (FlxG.keys.justPressed.TAB)
					{
						if (FlxG.keys.pressed.SHIFT)
						{
							UI_box.selected_tab -= 1;
							if (UI_box.selected_tab < 0)
								UI_box.selected_tab = 2;
						}
						else
						{
							UI_box.selected_tab += 1;
							if (UI_box.selected_tab >= 3)
								UI_box.selected_tab = 0;
						}
					}
			
					if (!typingShit.hasFocus)
					{
						if (FlxG.keys.justPressed.R)
						{
							if (FlxG.keys.pressed.SHIFT)
								resetSection(true);
							else
								resetSection();
						}
			
						if (FlxG.mouse.wheel != 0)
						{
							FlxG.sound.music.pause();
							vocals.pause();
			
							FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
							vocals.time = FlxG.sound.music.time;
						}
					}
		}
		else if (FlxG.mouse.overlaps(eventGridBG)){
			if (FlxG.mouse.justPressedRight){
				for (note in eventNotes.members){
					if (note != null && FlxG.mouse.overlaps(note)){
						eventSelected = note.eventID;
						trace('Event Selected: ' + eventSelected);
						
						if (_song.events[eventSelected].name != null)
							eventDropDown.selectedLabel = _song.events[eventSelected].name;
						else
							eventDropDown.selectedLabel = "None";
	
						if (_song.events[eventSelected].var1 != null)
							eventVar1.text = _song.events[eventSelected].var1;
	
						if (_song.events[eventSelected].var2 != null)
							eventVar2.text = _song.events[eventSelected].var2;
	
						if (_song.events[eventSelected].var3 != null)
							eventVar3.text = _song.events[eventSelected].var3;
	
						if (_song.events[eventSelected].var4 != null)
							eventVar4.text = _song.events[eventSelected].var4;
	
						if (_song.events[eventSelected].var5 != null)
							eventVar5.text = _song.events[eventSelected].var5;
	
						break;
					}
				}
			}

			dummyArrow.x = -40;

			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;

			if (FlxG.mouse.justPressed){
				var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();

				for (note in eventNotes.members){
					if (note != null && FlxG.mouse.overlaps(note)){
						return;
						break;
					}
				}

				Engine.debugPrint('Made new Event | Event MS: $noteStrum');
				var event:Events = {
					name: '',
					ms: noteStrum
				};

				if (_song.events == null)
					_song.events = [];

				_song.events.push(event);

				var newEvent:EventNote = new EventNote(dummyArrow.x, getYfromStrum(Math.floor(noteStrum % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps))), _song.events.length - 1);
				eventNotes.add(newEvent);

				eventSelected = _song.events.length - 1;

				eventDropDown.selectedLabel = "None";

				eventVar1InfoText.text = "";
				eventVar2InfoText.text = "";
				eventVar3InfoText.text = "";
				eventVar4InfoText.text = "";
				eventVar5InfoText.text = "";

				autosaveSong();
			}
		}

		if (!typingShit.hasFocus)
			{
				if (FlxG.keys.justPressed.SPACE)
				{
					if (FlxG.sound.music.playing)
					{
						FlxG.sound.music.pause();
						vocals.pause();
						vocals2.pause();
					}
					else
					{
						vocals.play();
						vocals2.play();
						FlxG.sound.music.play();
					}
				}

				if (!FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
						{
							FlxG.sound.music.pause();
							vocals.pause();
		
							var daTime:Float = 700 * FlxG.elapsed;
		
							if (FlxG.keys.pressed.W)
							{
								FlxG.sound.music.time -= daTime;
							}
							else
								FlxG.sound.music.time += daTime;
		
							vocals.time = FlxG.sound.music.time;
						}
					}
					else
					{
						if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
						{
							FlxG.sound.music.pause();
							vocals.pause();
		
							var daTime:Float = Conductor.stepCrochet * 2;
		
							if (FlxG.keys.justPressed.W)
							{
								FlxG.sound.music.time -= daTime;
							}
							else
								FlxG.sound.music.time += daTime;
		
							vocals.time = FlxG.sound.music.time;
						}
					}
			}

		// I am pretty sure I did this the most horrible way possible but whatever it works.

		if (_song.events != null){
			if (eventNotes.length <= 0){
				for (eventNote in _song.events){
					var strumTime = eventNote.ms;
					var yPos = getYfromStrum(Math.floor(eventNote.ms % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

					if (eventNote != null && strumTime >= sectionStartTime() && strumTime < sectionEndTime())
					{
						var newEvent:EventNote = new EventNote(-40, yPos, _song.events.indexOf(eventNote));
						eventNotes.add(newEvent);
					}
				}
			}
			
			for (array in validEvents){
				if (array != null && _song.events[eventSelected] != null && array[0] == _song.events[eventSelected].name){
					eventVar1InfoText.text = array[1];
					eventVar2InfoText.text = array[2];
					eventVar3InfoText.text = array[3];
					eventVar4InfoText.text = array[4];
					eventVar5InfoText.text = array[5];

					eventInstructionText.text = array[6];
				}
			}
		}

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection;

		for (note in curRenderedNotes) {
			if (strumLine.overlaps(note)){

				if (enableHitsounds && note.alpha == 1) {
					hitSound.stop();
					hitSound.play(true);
					Engine.debugPrint("played hit");
				}
				
				note.alpha = 0.2;
			}
			else if (note != null)
				note.alpha = 1;
		}
		
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function toggleAltAnimNote():Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[3] != null)
			{
				trace('ALT NOTE SHIT');
				curSelectedNote[3] = !curSelectedNote[3];
				trace(curSelectedNote[3]);
			}
			else
				curSelectedNote[3] = true;
		}
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			leftIcon.changeIcon(_song.player1);
			rightIcon.changeIcon(_song.player2);
		}
		else
		{
			leftIcon.changeIcon(_song.player2);
			rightIcon.changeIcon(_song.player1);
		}

		leftIcon.updateHitbox();
		rightIcon.updateHitbox();
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null){
			stepperSusLength.value = curSelectedNote[2];
			stepperCharID.value = curSelectedNote[3];

			if (curSelectedNote[4] != null)
				noteActionDropdown.selectedLabel = curSelectedNote[4];
			else
				noteActionDropdown.selectedLabel = "";
		}
	}

	function updateGrid():Void
	{
		for (event in eventNotes){
			if (event != null)
				event.kill();
		}
		eventNotes.clear();

		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = [];

		if (_song.notes[curSection].sectionNotes != null){
			sectionInfo = _song.notes[curSection].sectionNotes;
		}

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		for (i in sectionInfo)
		{
			if (i != null){
				var daNoteInfo = i[1];
				var daStrumTime = i[0];
				var daSus = i[2];
				var daSinger = i[3];
				var daType = i[4];
	
				var note:Note = new Note(daStrumTime, daNoteInfo % 4, null, daSinger, daType);
				note.sustainLength = daSus;
				note.setGraphicSize(GRID_SIZE, GRID_SIZE);
				note.updateHitbox();
				note.x = Math.floor(daNoteInfo * GRID_SIZE);
				note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));
	
				curRenderedNotes.add(note);
	
				if (daSus > 0)
				{
					var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
						note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
					curRenderedSustains.add(sustainVis);
				}
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % 4 == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] % 4 == note.noteData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;
		var noteAlt = false;

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteAlt]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, noteAlt]);
		}

		noteActionDropdown.selectedLabel = "";

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	function calculateSectionLengths(?sec:SwagSection):Int
	{
		var daLength:Int = 0;

		for (i in _song.notes)
		{
			var swagLength = i.lengthInSteps;

			if (i.typeOfSection == Section.COPYCAT)
				swagLength * 2;

			daLength += swagLength;

			if (sec != null && sec == i)
			{
				trace('swag loop??');
				break;
			}
		}

		return daLength;
	}

	function sectionEndTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection + 1)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	private var daSpacing:Float = 0.3;

	function loadVocals(){
		if (_song.seperatedVocalTracks == false || _song.seperatedVocalTracks == null){
			if (Modding.modLoaded){
				vocals = new FlxSound().loadEmbedded(Modding.retrieveAudio('Voices', 'songs/' + PlayState.SONG.song));
				vocals2 = new FlxSound();
			}
			else{
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				vocals2 = new FlxSound();
			}
		}
		else if(_song.seperatedVocalTracks){
			if (Modding.modLoaded){
				vocals = new FlxSound().loadEmbedded(Modding.retrieveAudio('Voices-BF', 'songs/' + PlayState.SONG.song));
				vocals2 = new FlxSound().loadEmbedded(Modding.retrieveAudio('Voices-DAD', 'songs/' + PlayState.SONG.song));
			}
			else{
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, '-BF'));
				vocals2 = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, '-DAD'));
			}
		}
	}

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());

		var disablePre:Bool = false;

		if (PlayState.songPlaylist != null && PlayState.songPlaylist != [])
			disablePre = PlayState.songPlaylist[0].disablePreload;

		LoadingState.loadAndSwitchState(new ChartingState(), Modding.curLoaded, !disablePre);
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
class EventNote extends FlxSprite
{
	public var eventID:Int;

	public function new(x:Float, y:Float, id:Int){
		super(x, y);

		loadGraphic(Paths.image('event', 'preload'));
		setGraphicSize(40, 40);
		updateHitbox();

		this.x = x;
		this.y = y;

		eventID = id;
	}
}
