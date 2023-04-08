package game.editors;

import Note.NoteData;
import util.EventNote;
import lime.app.Application;
import engine.modutil.ModVariables;
import flixel.system.FlxAssets.FlxSoundAsset;
import engine.modding.SpunModLib.ModAssets;
import engine.modding.SpunModLib.ModLib;
import util.EventNote.ChartEvent;
import util.EventNote.EventSection;
import util.ui.PreferencesMenu;
import engine.Engine;
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
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

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
	var curRenderedSustains:FlxTypedGroup<FakeSustain>;
	var curRenderedEvents:FlxTypedGroup<EventNote>;
	var ignoreRenderShit:FlxGroup = new FlxGroup();

	var gridBG:FlxSprite;
	var eventGridBG:FlxSprite;

	var _song:SwagSong;

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;
	var curSelectedEvent:ChartEvent;

	var tempBpm:Float = 0;

	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var bg:FlxSprite;
	var lastTouchedNote:Note = null;

	var sectionBGs:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

	var senpai:Character;
	var gf:Character;
	var bf:Character;

	var funnyCamObj:FlxSprite;

	private var inst:FlxSoundAsset;

	var hitsound:String = '-pluck';
	var ext:String = 'ogg';

	override function create()
	{
		#if web
		ext = 'mp3'
		#end

		curSection = lastSection;

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.scrollFactor.set(0, 0);
        bg.color = FlxColor.GRAY;
		add(bg);

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		// width is 320. x is 0.
		// height is 640.

		eventGridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE, GRID_SIZE * 16);
		eventGridBG.x -= GRID_SIZE;
		add(eventGridBG);

		var invisGridBG1 = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		invisGridBG1.y = (gridBG.height * -1);
		invisGridBG1.alpha = 0.75;
		sectionBGs.add(invisGridBG1);

		sectionBGs.add(gridBG);

		var invisGridBG2 = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		invisGridBG2.y = gridBG.height;
		invisGridBG2.alpha = 0.75;
		
		sectionBGs.add(invisGridBG2);

		add(sectionBGs);

		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2, gridBG.height * -1).makeGraphic(2, Std.int(gridBG.height * 3), FlxColor.BLACK);
		add(gridBlackLine);

		var gridEventLine:FlxSprite = new FlxSprite(0, gridBG.y).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridEventLine);

		if (PreferencesMenu.getPref('chart-perf')){
			invisGridBG1.visible = false;
			invisGridBG2.visible = false;

			gridBlackLine.y = 0;
			gridBlackLine.makeGraphic(2, Std.int(gridBG.height));
		}

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FakeSustain>();
		curRenderedEvents = new FlxTypedGroup();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Dadbattle',
				notes: [],
				events: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				speed: 1,
				validScore: false
			};
		}

		FlxG.mouse.visible = true;

		tempBpm = _song.bpm;

		addSection();
		addEventSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(-40, 50).makeGraphic(Std.int(gridBG.width + eventGridBG.width), 4);
		strumLine.setSize(strumLine.width, 1);
		add(strumLine);

		funnyCamObj = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width/ 2), 4);
		funnyCamObj.alpha = 0;
		add(funnyCamObj);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Assets", label: 'Assets'},
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

		addAssetsUI();
		addEventsUI();

		UI_box.selected_tab_id = 'Song';

		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedEvents);
		add(ignoreRenderShit);

		changeSection();

		add(leftIcon);
		add(rightIcon);

		// chose these characters cuz their graphics are smol and will be less resource intensive		
		gf = new Character(gridBG.x + 737, gridBG.y + 535, 'gf-pixel');
		gf.setGraphicSize(120, 106);
		gf.scrollFactor.set();
		add(gf);
		
		senpai = new Character(gridBG.x + 674, gridBG.y + 506, 'chartSenpai');
		senpai.scrollFactor.set();
		add(senpai);
		
		bf = new Character(gridBG.x + 837, gridBG.y + 582, 'chartBF');
		bf.scrollFactor.set();
		bf.flipX = !bf.flipX;
		add(bf);

		super.create();
	}

	function addAssetsUI():Void{
		var tab_assets = new FlxUI(null, UI_box);
		tab_assets.name = 'Assets';

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));

		if (ModLib.curMod != null){
			if (ModVariables.characterList == null)
				ModVariables.updateCharacterList();

			for (char in ModVariables.characterList){
				characters.push('${char.string}:${char.mod.id}');
			}

			if (ModVariables.stageList == null)
				ModVariables.updateStageList();

			for (stage in ModVariables.stageList){
				stages.push('${stage.string}:${stage.mod.id}');
			}
		}

		var p1DD_Text:FlxText = new FlxText(10, 25, 0, "Player 1 (BF)");
		var player1DropDown = new FlxUIDropDownMenu(10, 50, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
			updateHeads();
		});
		player1DropDown.selectedLabel = _song.player1;
		player1DropDown.dropDirection = Down;

		var p2DD_Text:FlxText = new FlxText(150, 25, 0, "Player 2 (DAD)");
		var player2DropDown = new FlxUIDropDownMenu(150, 50, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
			updateHeads();
		});
		player2DropDown.selectedLabel = _song.player2;
		player1DropDown.dropDirection = Down;

		var gfDD_Text:FlxText = new FlxText(10, 75, 0, "Girlfriend");
		var gfDropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.gfVersion = characters[Std.parseInt(character)];
		});
		gfDropDown.selectedLabel = _song.gfVersion;
		gfDropDown.dropDirection = Down;

		var stageDD_Text:FlxText = new FlxText(150, 75, 0, "Stage");
		var stageDropDown = new FlxUIDropDownMenu(150, 100, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String)
		{
			_song.stage = stages[Std.parseInt(stage)];
		});
		stageDropDown.selectedLabel = _song.stage;
		stageDropDown.dropDirection = Down;

		tab_assets.add(stageDD_Text);
		tab_assets.add(stageDropDown);
		tab_assets.add(gfDD_Text);
		tab_assets.add(gfDropDown);
		tab_assets.add(p1DD_Text);
		tab_assets.add(player1DropDown);
		tab_assets.add(p2DD_Text);
		tab_assets.add(player2DropDown);

		UI_box.addGroup(tab_assets);
		UI_box.scrollFactor.set();
	}


	var eventVar1:FlxUIInputText;
	var eventVar2:FlxUIInputText;
	var eventVar3:FlxUIInputText;
	var eventVar4:FlxUIInputText;
	var eventVar5:FlxUIInputText;

	var loadCurEvent:Void -> Void;

	function addEventsUI():Void{
		var tab_events = new FlxUI(null, UI_box);
		tab_events.name = 'Events';

		var events:Array<EventListData> = [];
		var eventNames:Array<String> = [];

		for (array in ModVariables.validEvents){
			if (array != null){
				events.push(array);
				eventNames.push(array.eventName);
			}
		}

		eventVar1 = new FlxUIInputText(10, 100);
		var eventVar1InfoText = new FlxText(eventVar1.width + 10, eventVar1.y);

		eventVar2 = new FlxUIInputText(10, 150);
		var eventVar2InfoText = new FlxText(eventVar2.width + 10, eventVar2.y);

		eventVar3 = new FlxUIInputText(10, 200);
		var eventVar3InfoText = new FlxText(eventVar3.width + 10, eventVar3.y);

		eventVar4 = new FlxUIInputText(10, 250);
		var eventVar4InfoText = new FlxText(eventVar4.width + 10, eventVar4.y);

		eventVar5 = new FlxUIInputText(10, 300);
		var eventVar5InfoText = new FlxText(eventVar5.width + 10, eventVar5.y);

		var eventInstructionText = new FlxText(10, 325);
		eventInstructionText.text = "Click to place or remove.\nClick Update to save Event Changes.\nPlacing also saves.";

		var eventDropDown = new FlxUIDropDownMenu(10, 50, FlxUIDropDownMenu.makeStrIdLabelArray(eventNames, true), function(lol:String)
		{
			if (curSelectedEvent != null)
				curSelectedEvent.event = eventNames[Std.parseInt(lol)];
			else
				trace('$curSelectedEvent - ${eventNames[Std.parseInt(lol)]} | event is null');

			for (event in events){
				if (event != null && event.eventName.toLowerCase() == eventNames[Std.parseInt(lol)].toLowerCase()){
					eventVar1InfoText.text = event.var1Hint;
					eventVar2InfoText.text = event.var2Hint;
					eventVar3InfoText.text = event.var3Hint;
					eventVar4InfoText.text = event.var4Hint;
					eventVar5InfoText.text = event.var5Hint;
					eventInstructionText.text = event.info;

					trace('Setting Event Info');

					break;
				}
			}
		});

		var saveButton:FlxButton = new FlxButton(0, 8, "Update", function()
		{
			if (curSelectedEvent != null){
				curSelectedEvent.event = eventDropDown.selectedLabel;
				curSelectedEvent.variable1 = eventVar1.text;
				curSelectedEvent.variable2 = eventVar2.text;
				curSelectedEvent.variable3 = eventVar3.text;
				curSelectedEvent.variable4 = eventVar4.text;
				curSelectedEvent.variable5 = eventVar5.text;
			}
			else
				trace('$curSelectedEvent | event is null');
		});

		
		loadCurEvent = function(){
			eventDropDown.selectedLabel = curSelectedEvent.event;

			eventVar1.text = curSelectedEvent.variable1;
			eventVar2.text = curSelectedEvent.variable2;
			eventVar3.text = curSelectedEvent.variable3;
			eventVar4.text = curSelectedEvent.variable4;
			eventVar5.text = curSelectedEvent.variable5;

			for (event in events){
				if (event != null && event.eventName.toLowerCase() == eventNames[eventNames.indexOf(curSelectedEvent.event)].toLowerCase()){
					eventVar1InfoText.text = event.var1Hint;
					eventVar2InfoText.text = event.var2Hint;
					eventVar3InfoText.text = event.var3Hint;
					eventVar4InfoText.text = event.var4Hint;
					eventVar5InfoText.text = event.var5Hint;
					eventInstructionText.text = event.info;

					trace('Setting Event Info');

					break;
				}
			}
		}

		tab_events.add(eventVar1);
		tab_events.add(eventVar2);
		tab_events.add(eventVar3);
		tab_events.add(eventVar4);
		tab_events.add(eventVar5);
		tab_events.add(eventVar1InfoText);
		tab_events.add(eventVar2InfoText);
		tab_events.add(eventVar3InfoText);
		tab_events.add(eventVar4InfoText);
		tab_events.add(eventVar5InfoText);
		tab_events.add(eventInstructionText);
		tab_events.add(saveButton);
		tab_events.add(eventDropDown);

		UI_box.addGroup(tab_events);
		UI_box.scrollFactor.set();
	}

	var check_hitsounds:FlxUICheckBox;

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
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 120, null, null, "Mute Inst", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		check_hitsounds = new FlxUICheckBox(110, 120, null, null, "Hit Sounds", 100);
		check_hitsounds.checked = true;

		var hitSounds:Array<String> = ['pluck', 'snare', 'swaghit1', 'swaghit2', 'swaghit3'];

		var hitsoundDD_Text:FlxText = new FlxText(10, 155, 0, "Hitsound to play");
		var hitsoundDropDown = new FlxUIDropDownMenu(10, 180, FlxUIDropDownMenu.makeStrIdLabelArray(hitSounds, true), function(hit:String)
		{
			hitsound = '-' + hitSounds[Std.parseInt(hit)];
			FlxG.save.data.defaultHitsound = hitSounds[Std.parseInt(hit)];
			trace('switched hitsound');
		});
		if (FlxG.save.data.defaultHitsound != null){
			hitsoundDropDown.selectedLabel = FlxG.save.data.defaultHitsound;
			hitsound = '-' + FlxG.save.data.defaultHitsound;
		}

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

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 2);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 0.5, 120, 1, 999, 3);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(check_hitsounds);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(hitsoundDD_Text);
		tab_group_song.add(hitsoundDropDown);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(funnyCamObj);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 1, 999, 3);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
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
	var idSingStepper:FlxUINumericStepper;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var info:FlxText = new FlxText(10, 30, 0, "ID of Singer (0 = Default)", 10);
		idSingStepper = new FlxUINumericStepper(10, 50, 1, 0, 0, 9999, 0);
		idSingStepper.value = 0;
		idSingStepper.name = 'note_SingerID';

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);
		tab_group_note.add(info);
		tab_group_note.add(idSingStepper);

		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		var modID:String = ModLib.getModID(ModLib.curMod);

		inst = ModAssets.getSound('songs/$daSong/Inst.$ext', null, modID, null);
		FlxG.sound.playMusic(inst, 0.6);

		if (_song.needsVoices && ModAssets.assetExists('songs/' + _song.song.toLowerCase() + '/Voices.$ext', null, modID, null))
			vocals = new FlxSound().loadEmbedded(ModAssets.getSound('songs/$daSong/Voices.$ext', null, modID, null));
		else
			vocals = new FlxSound();
		
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
			else if (wname == 'note_SingerID'){
				if (curSelectedNote[4] == null)
					curSelectedNote[4] = {};

				var data:NoteData = curSelectedNote[4];
				data.singerID = Std.int(nums.value);
				curSelectedNote[4] = data;
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
	function sectionStartTime(?section:Int):Float
	{
		if (section == null)
			section = curSection;

		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...section)
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

		if (FlxG.keys.justPressed.X)
			toggleAltAnimNote();

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));
		funnyCamObj.y = strumLine.y;

		bg.color = FlxColor.interpolate(bg.color, FlxColor.GRAY, 0.045);

		if (curRenderedNotes != null){
			for (note in curRenderedNotes){
				if (strumLine.overlaps(note)){
					
					if (note.alpha == 1 && FlxG.sound.music.playing){
						makeCharacterSing(note);

						if (check_hitsounds.checked)
							FlxG.sound.play(Paths.sound('hit' + hitsound));
					}

					if (lastTouchedNote != note && PreferencesMenu.getPref('chart-lights')){
						switch(note.noteData){
							case 0:
								bg.color = FlxColor.fromRGB(194, 75, 153);
							case 1:
								bg.color = FlxColor.fromRGB(0, 255, 255);
							case 2:
								bg.color = FlxColor.fromRGB(18, 250, 5);
							case 3:
								bg.color = FlxColor.fromRGB(249, 57, 63);
						}
	
						lastTouchedNote = note;
					}

					note.alpha = 0.5;
				}
				else if (note.alpha == 0.5)
					note.alpha = 1;
			}

			for (daSus in curRenderedSustains){
				if (strumLine.overlaps(daSus) && FlxG.sound.music.playing){
					makeCharacterSing(daSus);
				}
			}
		}

		if (curStep % 4 == 0 && FlxG.sound.music.playing)
			daBeatHit();

		if (curStep < 16 * curSection && _song.notes[curSection - 1] != null){
			changeSection(curSection - 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;

		if (FlxG.keys.justPressed.SPACE && !typingShit.hasFocus){
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
				}
			}
		}

		if (!typingShit.hasFocus && !FlxG.mouse.overlaps(UI_box))
		{
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

		if (FlxG.mouse.x <= gridBG.width && FlxG.mouse.x >= 0){
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

				if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
					changeSection(curSection + shiftThing, true);
				if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
					changeSection(curSection - shiftThing, true);
		}

		if (FlxG.mouse.x < 0 && FlxG.mouse.x >= -40 && FlxG.mouse.y >= eventGridBG.y && FlxG.mouse.y < eventGridBG.height){
			dummyArrow.x = eventGridBG.x;

			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;

			if (FlxG.mouse.justPressed){
				if (FlxG.mouse.overlaps(curRenderedEvents))
				{
					curRenderedEvents.forEach(function(note:EventNote)
					{
						if (FlxG.mouse.overlaps(note))
						{
							if (FlxG.keys.pressed.CONTROL)
							{
								curSelectedEvent = note.thisEvent;
								loadCurEvent();
							}
							else
							{
								trace('tryin to delete event...');
								deleteEvent(note);
							}
						}
					});
				}
				else
				{
					trace('attempting to add event');
					UI_box.selected_tab_id = 'Events';
					addEvent();
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection;

		super.update(elapsed);

		if (FlxG.keys.justPressed.F10){
			ModLib.setMod('FunkinTestMod');

			PlayState.SONG = Song.loadFromJson('its-goofy', 'its-goofy');
			FlxG.resetState();
		}
	}

	function makeCharacterSing(goofy:Dynamic){
		if (goofy.x < gridBG.width / 2 && !check_mustHitSection.checked || goofy.x >= gridBG.width / 2 && check_mustHitSection.checked){
			switch (goofy.noteData){
				case 0:
					senpai.playAnim('singLEFT', true);
				case 1:
					senpai.playAnim('singDOWN', true);
				case 2:
					senpai.playAnim('singUP', true);
				case 3:
					senpai.playAnim('singRIGHT', true);
			}

			senpai.holdTimer = 0;
		}

		if (goofy.x >= gridBG.width / 2 && !check_mustHitSection.checked || goofy.x < gridBG.width / 2 && check_mustHitSection.checked){
			switch (goofy.noteData){
				case 0:
					bf.playAnim('singLEFT', true);
				case 1:
					bf.playAnim('singDOWN', true);
				case 2:
					bf.playAnim('singUP', true);
				case 3:
					bf.playAnim('singRIGHT', true);
			}
			
			bf.holdTimer = 0;
		}
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

				FlxG.sound.music.time = sectionStartTime() + 0.001;
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			// updateGrid();
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
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null){
			stepperSusLength.value = curSelectedNote[2];
			if (curSelectedNote[4] != null){
				var data:NoteData = curSelectedNote[4];

				if (data.singerID != null)
					idSingStepper.value = data.singerID;
			}
			else
				idSingStepper.value = 0;
		}
	}

	function getSectionJunk(section:Int){
		var sectionInfo:Array<Dynamic> = _song.notes[section].sectionNotes;

		return sectionInfo;
	}

	function updateGrid():Void
	{
		curRenderedNotes.clear();
		curRenderedSustains.clear();
		ignoreRenderShit.clear();
		curRenderedEvents.clear();

		var sectionInfo:Array<Dynamic> = getSectionJunk(curSection);

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

		if (!PreferencesMenu.getPref('chart-perf')){
			if ((curSection - 1) >= 0 && curSection < _song.notes.length - 1 && _song.notes[curSection - 1] != null){
				for (i in _song.notes[curSection - 1].sectionNotes)
				{
					genSection(i, -1, curSection);
				}
			}
	
			if (curSection < _song.notes.length - 1) {
				for (i in _song.notes[curSection + 1].sectionNotes)
				{
					genSection(i, 1, curSection);
				}
			}
		}
		
		for (i in sectionInfo)
		{
			genSection(i, 0, curSection);
		}

		if (_song.events[curSection] != null && _song.events[curSection].eventNotes != null){
			for (i in _song.events[curSection].eventNotes){
				if (i != null)
					genEventSection(i);
			}
		}
		else if (_song.events[curSection] == null)
			addEventSection();
	}

	function genEventSection(i:ChartEvent){
		var section:Int = curSection;

		var event:EventNote = new EventNote(i);
		event.setGraphicSize(GRID_SIZE, GRID_SIZE);
		event.updateHitbox();
		event.x = -40;
		event.y = Math.floor(getYfromStrum((i.strumtime - sectionStartTime(section)) % (Conductor.stepCrochet * _song.events[section].lengthInSteps), eventGridBG));
		curRenderedEvents.add(event);
	}

	function genSection(i:Array<Dynamic>, ?addToSection:Int = 0, currentSection:Int){
		var section:Int = currentSection + addToSection;
		
		var daNoteInfo = i[1];
		var daStrumTime = i[0];
		var daSus = i[2];
		
		var note:Note = new Note(daStrumTime, daNoteInfo % 4);
		note.sustainLength = daSus;
		note.setGraphicSize(GRID_SIZE, GRID_SIZE);
		note.updateHitbox();
		note.belongsToSection = section;
		note.x = Math.floor(daNoteInfo * GRID_SIZE);
		note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime(section)) % (Conductor.stepCrochet * _song.notes[section].lengthInSteps), 
			sectionBGs.members[addToSection + 1]));
		
		if (addToSection == 0)
			curRenderedNotes.add(note);
		else{
			note.alpha = 0.75;
			ignoreRenderShit.add(note);
		}
		
		if (daSus > 0)
		{
			var sustainVis:FakeSustain = new FakeSustain(note.x + (GRID_SIZE / 2), note.y + GRID_SIZE, note.noteData % 4);
			sustainVis.belongsToSection = section;
			sustainVis.makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, (gridBG.height))));
			sustainVis.setSize(sustainVis.width, sustainVis.height - 2); // offset for mini-characters

			if (addToSection == 0)
				curRenderedSustains.add(sustainVis);
			else{
				sustainVis.alpha = 0.75;
				ignoreRenderShit.add(sustainVis);
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

	private function addEventSection(lengthInSteps:Int = 16):Void
	{
		var sec:EventSection = {
			lengthInSteps: lengthInSteps,
			eventNotes: [],
			typeOfSection: 0
		};

		if (_song.events != null)
			_song.events.push(sec);
		else{
			_song.events = [];
			_song.events.push(sec);
		}
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

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteAlt, {singerID: idSingStepper.value}]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, noteAlt]);
		}

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	private function addEvent():Void{
		if (curSelectedEvent != null){
			trace("Saving event before placing a new one lol");

			curSelectedEvent.variable1 = eventVar1.text;
			curSelectedEvent.variable2 = eventVar2.text;
			curSelectedEvent.variable3 = eventVar3.text;
			curSelectedEvent.variable4 = eventVar4.text;
			curSelectedEvent.variable5 = eventVar5.text;
		}

		trace('Adding note at ' + getStrumTime(dummyArrow.y) + sectionStartTime());

		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();

		_song.events[curSection].eventNotes.push({strumtime: noteStrum, event: 'test'});
		curSelectedEvent = _song.events[curSection].eventNotes[_song.events[curSection].eventNotes.length - 1];

		updateGrid();
		autosaveSong();
	}

	function deleteEvent(event:EventNote):Void
	{
		for (i in _song.events[curSection].eventNotes)
		{
			if (i.strumtime == event.strumTime && i.event == event.thisEvent.event)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.events[curSection].eventNotes.remove(i);
			}
		}

		updateGrid();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float, ?grid:FlxSprite):Float
	{
		if (grid == null)
			grid = gridBG;

		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, grid.y, grid.y + grid.height);
	}

	/*
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
	}*/
	private var daSpacing:Float = 0.3;

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
		LoadingState.loadAndSwitchState(new ChartingState());
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

	override function stepHit() {
		super.stepHit();

		if (curStep % 4 == 0 && FlxG.sound.music.playing)
			daBeatHit();
	}

	function daBeatHit(){
		if (senpai.isDancing() || !senpai.isDancing() && senpai.animation.curAnim.finished)
			senpai.dance();

		if (bf.isDancing() || !bf.isDancing() && bf.animation.curAnim.finished)
			bf.dance();

		if (gf.isDancing() && gf.animation.curAnim.finished){
			gf.dance();
			gf.animation.curAnim.frameRate = 48; // i dunno how to make it work properly lol
		}
	}
}

class FakeSustain extends FlxSprite{
	public var noteData:Int = 0;
	public var mustPress:Bool;
	public var belongsToSection:Int = 0;

	public function new(x:Float, y:Float, data:Int, ?bfNote:Bool){
		super(x, y);

		noteData = data;
		mustPress = bfNote;
	}
}