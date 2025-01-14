package;

#if desktop
import Discord.DiscordClient;
#end
import Options;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import Type.ValueType;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import LuaClass;
import flash.display.BitmapData;
import flash.display.Bitmap;
import Shaders;
import haxe.Exception;
import openfl.utils.Assets;
import ModChart;

import vm.lua.LuaVM;
import vm.lua.Exception;
import Sys;
import sys.FileSystem;
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;

import sys.io.File;
import animateatlas.AtlasFrameMaker;
using StringTools;
class PlayState extends MusicBeatState
{
	public static var currentPState:PlayState;

	public static var curStage:String = '';
	var anotherPoint = false;
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var scrollSpeed:Float = 1;
	public static var instance:PlayState;
	public var dontSync:Bool=false;
	public var currentTrackPos:Float = 0;
	public var currentVisPos:Float = 0;
	
	public var deathSound:String = 'fnf_loss_sfx';
	public var deathEndSong:String = 'gameOverEnd';
	public var deathSong:String = 'gameOver';
	public var boyf:String = 'bf';
	public var deathColor:String = '000000';
	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	
	public var hasScript:Bool = false;
	
	public var script:String = "";
	
	
	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var renderedNotes:FlxTypedGroup<Note>;
	private var hittableNotes:Array<Note> = [];
	private var unspawnNotes:Array<Note> = [];
	var skipCountdown = false;

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	public var currentOptions:Options;

	private static var prevCamFollow:FlxObject;
	private var lastHitDadNote:Note;
	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var dadStrums:FlxTypedGroup<FlxSprite>;
	private var playerStrumLines:FlxTypedGroup<FlxSprite>;
	public var refNotes:FlxTypedGroup<FlxSprite>;
	public var opponentRefNotes:FlxTypedGroup<FlxSprite>;
	public var refReceptors:FlxTypedGroup<FlxSprite>;
	public var opponentRefReceptors:FlxTypedGroup<FlxSprite>;
	private var opponentStrumLines:FlxTypedGroup<FlxSprite>;
	public var luaSprites:Map<String, Dynamic>;
	public var luaObjects:Map<String, Dynamic>;
	public var unnamedLuaSprites:Int=0;
	public var unnamedLuaShaders:Int=0;
	public var dadLua:LuaCharacter;
	public var gfLua:LuaCharacter;
	public var bfLua:LuaCharacter;

	private var camZooming:Bool = true;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var previousHealth:Float = 1;
	private var combo:Int = 0;
	private var highestCombo:Int = 0;
	private var assetSuffix:String = '';
	private var assetPrefix:String = '';

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	private var scootdrive:Int = 0;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;
	public var pauseHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var modchart:ModChart;
	public var botplayPressTimes:Array<Float> = [0,0,0,0];
	public var botplayHoldTimes:Array<Float> = [0,0,0,0];
	public var botplayHoldMaxTimes:Array<Float> = [0,0,0,0];
	public var hasDialogue:Bool = false;
	public var hasEndDialogue:Bool = false;
	public var dadaltAnim:String = "";
	public var bfaltAnim:String = "";
	public var gfaltAnim:String = "";

	public var camZoomTween:FlxTween;
	public var camBoomTween:FlxTween;
	
	public var camMoveTween:FlxTween;
	public var newChars:Array<Character> = [];
	
	
	public var playerNoteOffsets:Array<Array<Float>> = [
		[0,0], // left
		[0,0], // down
		[0,0], // up
		[0,0]// right
	];

	public var opponentNoteOffsets:Array<Array<Float>> = [
		[0,0], // left
		[0,0], // down
		[0,0], // up
		[0,0] // right
	];

	public var playerNoteAlpha:Array<Float>=[
		1,
		1,
		1,
		1
	];

	public var opponentNoteAlpha:Array<Float>=[
		1,
		1,
		1,
		1
	];
	var lua:LuaVM;

				var lighting:FlxSprite;
	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;
	static public var isPony:Bool = false;
	var hd_tree:FlxSprite;
	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var lightFadeShader:BuildingEffect;
	var vcrDistortionHUD:VCRDistortionEffect;
	var rainShader:RainEffect;
	var chromab:ChromaticAberrationEffect;
	var vcrDistortionGame:VCRDistortionEffect;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;
	var doof:DialogueBox;
	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var theSprites:Map<String,FlxSprite> = new Map<String,FlxSprite>();

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;
	var ponybg:FlxSprite;
	var hd_dash:FlxSprite;
	var treeexplode:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;
	var shitsTxt:FlxText;
	var badsTxt:FlxText;
	var goodsTxt:FlxText;
	var sicksTxt:FlxText;
	var highComboTxt:FlxText;
	var presetTxt:FlxText;
	var missesTxt:FlxText;

	var accuracy:Float = 1;
	var hitNotes:Float = 0;
	var totalNotes:Float = 0;

	var grade:String = ScoreUtils.gradeArray[0];
	var misses:Float = 0;
	var sicks:Float = 0;
	var goods:Float = 0;
	var bads:Float = 0;
	var shits:Float = 0;
	var luaModchartExists = false;
	
	var floatShits:Array<FlxSprite> = [];

	var bitch:Float = 0;
	var noteLanes:Array<Array<Note>> = [];
	var susNoteLanes:Array<Array<Note>> = [];

		var p1Color = 0xFF66FF33;
		var p2Color = 0xFFFF0000; // TODO: GIVE EVERYONE CUSTOM HP BAR COLOURS!!!
		// AND MAKE IT BETTER WITH A NOTEPAD FILE OR SOMETHING!!
	var velocityMarkers:Array<Float>=[];
	var beattype:String = "porche";
	//porche (liek bella borce)
	//polka (like weird al)
	//party (liek hip hop)

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;
	var defaultHudZoom:Float = 1;

	var cz = 1.00;
		
	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	public var camStep:Array<Float> = [];
	
	public var ponyvilleBG:FlxSprite;
	public var daInst:openfl.media.Sound;
	public var camBoomSpeed:Int = 4;
	public var camZoomSpeed:Float = 0.09;
	public var SKY:FlxSprite;
	//public var daVoices:openfl.media.Sound;

	var inCutscene:Bool = false;
	var cloudo1:FlxSprite;
	var cloudo2:FlxSprite;
	var cloudo3:FlxSprite;
	var cloudo4:FlxSprite;
	var fpsRatio:Float;
	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end
	override public function create()
	{
		Paths.imgCache.clear();
		Cache.Clear();
		instance = this;
		fpsRatio = (openfl.Lib.current.stage.frameRate / 60);
		Cache.Clear();
		modchart = new ModChart(this);
		FlxG.sound.music.looped=false;
		unnamedLuaSprites=0;
		currentPState=this;
		currentOptions = OptionUtils.options.clone();
		ScoreUtils.ratingWindows = OptionUtils.ratingWindowTypes[currentOptions.ratingWindow];
		ScoreUtils.ghostTapping = currentOptions.ghosttapping;
		ScoreUtils.botPlay = currentOptions.botPlay;

		Conductor.safeZoneOffset = ScoreUtils.ratingWindows[3]; // same as shit ms
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		//lua = new LuaVM();
		#if windows
			luaModchartExists = openfl.utils.Assets.exists('songs': + Paths.modchart(SONG.song.toLowerCase()));
		#end
		if (TitleState.curDir == 'assets'){
			daInst = FlxG.sound.cache(Paths.inst(SONG.song.toLowerCase()));
			//daVoices = //FlxG.sound.cache(Paths.voices(SONG.song.toLowerCase()));
		}else{
			
			daInst = (Paths.inst(SONG.song.toLowerCase()));
			//daVoicesopenfl.media.Sound.fromFile(Paths.music('freakyMenu'));
		}

		if (FileSystem.exists(Generic.retutnPath() + Paths.json(SONG.song.toLowerCase() + '/sliders'))){
			SONG.sliderVelocities = Song.loadFromJson('sliders', SONG.song.toLowerCase()).sliderVelocities;
		}
		grade = ScoreUtils.gradeArray[0] + " (FC)";
		hitNotes=0;
		totalNotes=0;
		misses=0;
		bads=0;
		goods=0;
		sicks=0;
		shits=0;
		accuracy=1;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		pauseHUD = new FlxCamera();
		pauseHUD.bgColor.alpha = 0;
		
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		FlxG.cameras.add(pauseHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		SONG.initialSpeed = SONG.speed*.45;
		
		SONG.sliderVelocities.sort((a,b)->Std.int(a.startTime-b.startTime));
		mapVelocityChanges();

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
			default:
				try {
					dialogue = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + "/dialogue"+(isPony?"-pony":"")));
					hasDialogue = true;
					if (currentOptions.lessBS) hasDialogue = false;
					trace(dialogue);
				} catch(e){
					trace("epic style " + e.message);
				}
				try {
					
					
					
					hasEndDialogue = FileSystem.exists(Generic.returnPath() + Paths.txt(SONG.song.toLowerCase() + "/dialogueEnd" + (isPony?"-pony":"")));
					if (currentOptions.lessBS) hasEndDialogue = false;
					trace(Paths.txt(SONG.song.toLowerCase() + "/dialogueEnd" + (isPony?"-pony":"")));
				} catch(e){
					trace("epic style " + e.message);
				}
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek+ " ";
		}
		else
		{
			detailsText = "Freeplay"+ " ";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end
		try{
			vcrDistortionHUD = new VCRDistortionEffect();
			vcrDistortionGame = new VCRDistortionEffect();
		}catch(e:Any){
			trace(e);
		}

		if(luaModchartExists && lua!=null){
			lua.call("create",[]);
		}
		switch (SONG.song.toLowerCase())
		{
				  case "fun" | "smile":
						if (SONG.noBG != true){
							chromab = new ChromaticAberrationEffect();
							camGame.setFilters([new ShaderFilter(chromab.shader)]);
							chromab.setValue(chromab.shader, 'rOffset', 0.01);
							chromab.setValue(chromab.shader, 'bOffset', 0.06);
							
		                  curStage = 'ponyville';
		                  defaultCamZoom = 0.9;
		                  
						 SKY = addSprite( -364.05, -376, "pinkie/skyy", 0);
						  addSprite( -169.5, -130, "pinkie/clouds", 0.1);
						  lighting = addSprite( 62.95, -809, "pinkie/lightning", 1);
				lighting.alpha = 0;
				cloudo1 = addAnimPrefix( 355.3, 89.5, "pinkie/discord/cottoncloud1","cottoncloud1",0.2);
				cloudo2 = addAnimPrefix( 894.65, -38.05, "pinkie/discord/cottoncloud2","cottoncloud2",0.6);
				cloudo3 = addAnimPrefix( -148.6, -103.5, "pinkie/discord/cottoncloud3", "cottoncloud3", 0.7);
				cloudo1.alpha = 0;
				cloudo2.alpha = 0;
				cloudo3.alpha = 0;
						  addSprite( 143.4, -291, "pinkie/backhouses", 0.5);
						  addSprite( -646, -502, "pinkie/house2", 0.7);
						  addSprite( 455.8, -526, "pinkie/house", 0.9);
						  addSprite( -488.2, 438, "pinkie/floor", 0.9);
						  
						  
		                  var sh:FlxSprite = new FlxSprite(168.05, 556.1).loadGraphic(Paths.image('pinkie/shadow'));
		                  sh.antialiasing = true;
		                  sh.active = false;
						  add(sh);
						  
		                  ponybg = new FlxSprite( -80, 157.05);
						  ponybg.frames = Paths.getSparrowAtlas('pinkie/ponybg');
		                  ponybg.antialiasing = true;
		                  ponybg.scrollFactor.set(0.9,0.9);
						  ponybg.animation.addByPrefix("porche", "ponybg_porche", 0, false );
						  ponybg.animation.addByPrefix("polka", "ponybg_polka", 0, false );
						  ponybg.animation.addByPrefix("trap", "ponybg_trap", 24, false );
						  ponybg.animation.play("porche");
						  add(ponybg);
						}
					case "smile-hd":
						if (SONG.noBG != true){
		                  curStage = 'hd';
		                  defaultCamZoom = 0.95;
						  //defaultHudZoom = 0.8;
						  addSprite( -54, -172, "pinkie/hd/sky",0);
						  addSprite( -49, -48, "pinkie/hd/mountains",0.2);
						  addSprite( -266.25, -79.45, "pinkie/hd/bg2",0.5);
						  hd_tree = addSprite( -266.25, -79.45, "pinkie/hd/bg",0.5);
						  addSprite( 477.1, 178.35, "pinkie/hd/ponies",0.5);
						  addSprite( -385.8, 279.3, "pinkie/hd/grass", 1);
						  
						  
		                  var sh:FlxSprite = new FlxSprite(168.05, 556.1).loadGraphic(Paths.image('pinkie/shadow'));
		                  sh.antialiasing = true;
		                  sh.active = false;
						  add(sh);
						  
		                  hd_dash = new FlxSprite( 1487, -55);
						  hd_dash.frames = Paths.getSparrowAtlas('pinkie/hd/dash');
		                  hd_dash.antialiasing = true;
						  hd_dash.animation.addByIndices("dashing", "rainbow dash", [0], '',24,false );
						  hd_dash.animation.addByIndices("ouch", "rainbow dash", [1], '',24,false );
						  hd_dash.animation.play("dashing");
						//  hd_dash.setGraphicSize(21);
						  add(hd_dash);
						  hd_dash.visible = false;
						  
		                  treeexplode = new FlxSprite( 644.4, 51);
						  treeexplode.frames = Paths.getSparrowAtlas('pinkie/hd/treeexplode');
		                  treeexplode.antialiasing = true;
						  treeexplode.animation.addByPrefix("boom", "treeexplode",24,false);
						  treeexplode.animation.play("boom");
						  add(treeexplode);
						  treeexplode.scrollFactor.set(0.5, 0.5);
						  treeexplode.visible = false;
						  
						  
						  
						 // camHUD.zoom = 0.8;
						  camHUD.scroll.y -= 150;
						}
					case "discord":
						//if (SONG.noBG != true){
		                  curStage = 'discord';
		                  defaultCamZoom = 0.7;
						  
		                 // bgColor = 0xFFA2E9AD;
				addSprite( -908.45, -125.35, "pinkie/discord/hills",0.2);
				addSprite( -378.85, -879.85, "pinkie/discord/bigcloud",0.25);
				
				
				setSpr('disc_end',addSprite( 0, 0, "characters/discord_end",1));
				setSpr('disc_die',addSprite( 0, 0, "characters/discord_die",1));
				getSpr('disc_end').alpha = 0.001;
				getSpr('disc_die').alpha = 0.001;
				
				
				
				floatShits.push(addSprite( 1046.55, 43.95, "pinkie/discord/floathouse2",0.3));
				floatShits.push(addSprite( 1198.5, 105.9, "pinkie/discord/groundpiece",0.35));
				floatShits.push(addSprite( 210.8, -96.65, "pinkie/discord/tree",0.2));
				
				addAnimPrefix( 355.3, 89.5, "pinkie/discord/cottoncloud1","cottoncloud1",0.2);
				
				floatShits.push(addSprite( 575.2, -210.15, "pinkie/discord/floathouse",0.4));
				floatShits.push(addSprite( 1106.15, -553.45, "pinkie/discord/citthall",0.5));
				
				addAnimPrefix( 894.65, -38.05, "pinkie/discord/cottoncloud2","cottoncloud2",0.6);
				addAnimPrefix( -148.6, -103.5, "pinkie/discord/cottoncloud3","cottoncloud3",0.7);
				
				addSprite( -447.8, 355.05, "pinkie/discord/discordground", 1);
				
				
				
				
						  setSpr('aj',addAnimPrefix( 1514.75, 53.55, "pinkie/discord/applejack", 'aj_end',1,false,0));
						  setSpr('pinkie',addAnimPrefix( 1809.9, 4.95, "pinkie/discord/pinkie", 'pinkie_end',1,false,0));
						  
						//  var bitchtwi:FlxSprite = new FlxSprite(2030.9, -148);
						// bitchtwi.frames = AtlasFrameMaker.construct('assets/shared/images/pinkie/discord/twilight');
						//  bitchtwi.animation.addByPrefix('twi_end','twi_end',24,false);
						  
						  
						  setSpr('twi', addAnimPrefix(2030.9, -148, "pinkie/discord/twi", 'twi_end', 1, false, 24));
						  getSpr('twi').animation.addByIndices('twiFloat', 'twi_end', Character.numArr(119, 129), '', 24);
						  
				
						//}
						  setSpr('rainbowsss', addAnimPrefix(0, 0, "pinkie/discord/rainbowsss", 'rainbowsss', 0, true, 24));
						  getSpr('rainbowsss').visible = false;
						  getSpr('rainbowsss').scale.set(1.5,1.5);
					  
				setSpr('disc_hey',addAnimPrefix( -661.55,-1199.25, "characters/DISCORDSPRITES/hey","discord_hey",1,false));
					getSpr('disc_hey').alpha = 0.001;
		          default:
		          {
											if(!SONG.noBG){
		                  defaultCamZoom = 1;
		                  curStage = 'stage';
		                  var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.9, 0.9);
		                  bg.active = false;
		                  add(bg);

		                  var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		                  stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		                  stageFront.updateHitbox();
		                  stageFront.antialiasing = true;
		                  stageFront.scrollFactor.set(0.9, 0.9);
		                  stageFront.active = false;
		                  add(stageFront);

		                  var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		                  stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		                  stageCurtains.updateHitbox();
		                  stageCurtains.antialiasing = true;
		                  stageCurtains.scrollFactor.set(1.3, 1.3);
		                  stageCurtains.active = false;

		                  add(stageCurtains);
										}else{
											curStage='custom';
										}
		          }
              }
			  
			  
			  

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		if(SONG.player1=='bf-neb')
			gfVersion = 'lizzy';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'bf-pixel':
				dad.y += 570;
				dad.x += 200;
			case 'bf' | 'bf-car' | 'bf-christmas':
				dad.y += 350;
			case 'pinkie-hd':
				camPos.x += 150;
				camPos.y = 0;
			case 'pinkie':
				camPos.y = 60;
				
			default:
				if(SONG.player2.startsWith('discord')){
					camPos.y = -100;
				}
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);


		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);
		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;
			case 'ponyville':
				dad.setPosition(0,-96);
				boyfriend.setPosition(880,234);
				gf.setPosition(400, -96);
				
				
				
				
				var scoot:FlxSprite = addAnimPrefix(1799.15, 270, 'pinkie/scootaloo','scootaloo', 1);
				setSpr('scoot', scoot);
				
				
				scootdrive = FlxG.random.int(10, 100);
				
				
				
						  setSpr('pony1', addAnimPrefix( 4000, 235, "poners/lyra", 'pony', 1));
						  getSpr('pony1').scale.set(1.2,1.2);
						  
						  setSpr('pony2', addAnimPrefix( -6000, 245, "poners/bonbon", 'bonbon', 1.1));
						  getSpr('pony2').scale.set(1.4,1.4);
						  getSpr('pony2').flipX = true;
						  
						  
						  setSpr('pony3',addAnimPrefix( -8000, 255, "poners/minuette",'pony', 1.2));
						  getSpr('pony3').scale.set(1.6,1.6);
						  getSpr('pony3').flipX = true;
						  
						  setSpr('pony4',addAnimPrefix( 14000, 245, "poners/vinyl",'pony', 1.2));
						  getSpr('pony4').scale.set(1.4,1.4);
						  
						  setSpr('pony5',addAnimPrefix( -10000, 235, "poners/octavia",'pony', 1.2));
						  getSpr('pony5').scale.set(1.2,1.2);
						  getSpr('pony5').flipX = true;
						  
				getSpr('pony1').velocity.x = -300;
				getSpr('pony2').velocity.x = 300;
				getSpr('pony3').velocity.x = 300;
				getSpr('pony4').velocity.x = -300;
				getSpr('pony5').velocity.x = 300;
				
					for( i in 1...5){
						new FlxTimer().start(35+5*i, function (e:FlxTimer){
							
								if (getSpr('pony'+i).x < -2400 && getSpr('pony'+i).velocity.x < 0 || getSpr('pony'+i).x > 2400 && getSpr('pony'+i).velocity.x > 0){
									
									getSpr('pony'+i).velocity.x = -getSpr('pony'+i).velocity.x;
									getSpr('pony' + i).flipX = !getSpr('pony' + i).flipX;
									
								}
						},0);
					}
				
				
			case 'hd':
				dad.setPosition(0,-1000);
				boyfriend.setPosition(880,234);
				gf.setPosition(9999, 9999);
				
				setSpr('dashCam', addAnimPrefix(1279, -48, 'pinkie/hd/dashcam', 'dashcam', 0, false));
				getSpr('dashCam').visible = true;
				getSpr('dashCam').cameras = [camHUD];
				
				setSpr('killometer', addAnimPrefix(474.3, 720, 'pinkie/hd/kill-o-meter', 'kill-o-meter', 0, false));
				getSpr('killometer').cameras = [camOther];
				
				
				setSpr('pinkieGlow', addAnimPrefix(117.75, 50.1, 'pinkie/hd/PINKIEGLOW', 'PINKIEGLOW', 1, true));
				getSpr('pinkieGlow').visible = false;
				getSpr('pinkieGlow').blend = 'add';
				
				
			//	strumLine.y += 150;
			case 'discord':
				dad.setPosition(-661.55,-1199.25);
				boyfriend.setPosition(880,234);
				gf.setPosition(400, -96);
				gf.scale.x = gf.scale.y = 0.2;
				gf.angle = 20;
				gf.scrollFactor.set(0.4, 0.4);
				floatShits.push(gf);
						  setSpr('flutter', addAnimPrefix( 2536.8, 60.8, "pinkie/discord/fluttershy", 'flutter_end', 1, false, 0));
						  setSpr('rarity', addAnimPrefix( 2168.85, 310.45, "pinkie/discord/rarity", 'rarity_end', 1, false, 0));
						  setSpr('dash', addAnimPrefix( 1428.5, 332.75, "pinkie/discord/dash", 'dash_end', 1, false, 0));
				
						  
						  getSpr('pinkie').alpha = 0.0001;
						  getSpr('twi').alpha = 0.0001;
						  getSpr('aj').alpha = 0.0001;
						  
						  getSpr('flutter').alpha = 0.0001;
						  getSpr('rarity').alpha = 0.0001;
						  getSpr('dash').alpha = 0.0001;
						  
						  
						  setSpr('screwball', addAnimPrefix( 1280, -13, "pinkie/discord/screwball", 'screwball', 1));
						  getSpr('screwball').cameras = [camOther];
						 
				remove(gf, true);
				insert(members.indexOf(getSpr('aj')), gf);
						  

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;

		}
		if(boyfriend.curCharacter=='spirit'){
			var evilTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
			add(evilTrail);
		}
		if(dad.curCharacter=='spirit'){
			var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
			add(evilTrail);
		}
		if(SONG.player1=='bf-neb')
			boyfriend.y -= 75;

		doof = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;


		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrumLines = new FlxTypedGroup<FlxSprite>();
		opponentStrumLines = new FlxTypedGroup<FlxSprite>();
		luaSprites = new Map<String, FlxSprite>();
		luaObjects = new Map<String, FlxBasic>();
		refNotes = new FlxTypedGroup<FlxSprite>();
		opponentRefNotes = new FlxTypedGroup<FlxSprite>();
		refReceptors = new FlxTypedGroup<FlxSprite>();
		opponentRefReceptors = new FlxTypedGroup<FlxSprite>();
		playerStrums = new FlxTypedGroup<FlxSprite>();
		dadStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, camZoomSpeed / fpsRatio);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();

		switch(SONG.player1){
			case 'bf-neb':
				p1Color = 0xFF9534EB;
			case 'bf' | 'bf-car' | 'bf-pixel' | 'bf-christmas':
				p1Color = 0xFF31B0D1;
			default:
				p1Color = 0xFF66FF33;
		}

		switch(SONG.player2){
			case 'bf-neb':
				p2Color = 0xFF9534EB;
			case 'bf' | 'bf-car' | 'bf-pixel' | 'bf-christmas':
				p2Color = 0xFF31B0D1;
			default:
				p2Color=0xFFFF0000;
		}

		cameraShits(true,true);

		healthBar.createFilledBar(p2Color,p1Color);
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 150, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.setFormat(Paths.font("Woodrow W00 Reg.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		presetTxt = new FlxText(0, FlxG.height/2-80, 0, "", 20);
		presetTxt.setFormat(Paths.font("Woodrow W00 Reg.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		presetTxt.scrollFactor.set();
		presetTxt.visible=false;

		highComboTxt = new FlxText(0, FlxG.height/2-60, 0, "", 20);
		highComboTxt.setFormat(Paths.font("Woodrow W00 Reg.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		highComboTxt.scrollFactor.set();

		sicksTxt = new FlxText(0, FlxG.height/2-40, 0, "", 20);
		sicksTxt.setFormat(Paths.font("Woodrow W00 Reg.ttf"), 16, FlxColor.CYAN, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		sicksTxt.scrollFactor.set();

		goodsTxt = new FlxText(0, FlxG.height/2-20, 0, "", 20);
		goodsTxt.setFormat(Paths.font("Woodrow W00 Reg.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		goodsTxt.scrollFactor.set();

		badsTxt = new FlxText(0, FlxG.height/2, 0, "", 20);
		badsTxt.setFormat(Paths.font("Woodrow W00 Reg.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		badsTxt.scrollFactor.set();

		shitsTxt = new FlxText(0, FlxG.height/2+20, 0, "", 20);
		shitsTxt.setFormat(Paths.font("Woodrow W00 Reg.ttf"), 16, FlxColor.GRAY, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		shitsTxt.scrollFactor.set();

		missesTxt = new FlxText(0, FlxG.height/2+40, 0, "", 20);
		missesTxt.setFormat(Paths.font("Woodrow W00 Reg.ttf"), 16, FlxColor.RED, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		missesTxt.scrollFactor.set();

		missesTxt.text = "Miss: " + misses;
		sicksTxt.text = "Sick: " + sicks;
		goodsTxt.text = "Good: " + goods;
		badsTxt.text = "Bad: " + bads;
		shitsTxt.text = "Shit: " + shits;
		highComboTxt.text = "Highest Combo: " + highestCombo;
		if(currentOptions.ratingWindow!=0){
			presetTxt.text = OptionUtils.ratingWindowNames[currentOptions.ratingWindow] + " Judgement";
			presetTxt.x = 0;
			presetTxt.y = FlxG.height/2-80;
			presetTxt.visible=true;
		}

		add(highComboTxt);
		add(sicksTxt);
		add(goodsTxt);
		add(badsTxt);
		add(shitsTxt);
		add(missesTxt);
		add(presetTxt);

		iconP1 = new HealthIcon(SONG.player1, true);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		add(iconP2);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		add(scoreTxt);
		
		
		strumLineNotes.cameras = [camHUD];
		renderedNotes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		missesTxt.cameras = [camHUD];
		sicksTxt.cameras = [camHUD];
		goodsTxt.cameras = [camHUD];
		badsTxt.cameras = [camHUD];
		shitsTxt.cameras = [camHUD];
		highComboTxt.cameras = [camHUD];
		presetTxt.cameras = [camHUD];
		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		if(luaModchartExists && currentOptions.loadModcharts){
			lua = new LuaVM();
			lua.setGlobalVar("curBeat",0);
			lua.setGlobalVar("curStep",0);
			lua.setGlobalVar("songPosition",Conductor.songPosition);
			lua.setGlobalVar("bpm",Conductor.bpm);
			lua.setGlobalVar("XY","XY");
			lua.setGlobalVar("X","X");
			lua.setGlobalVar("Y","Y");
			lua.setGlobalVar("version",SONG.version);
			lua.setGlobalVar("GameVersion",1.2);
			lua.setGlobalVar("isPony",isPony);

			Lua_helper.add_callback(lua.state,"skipCountdown", function(){
				skipCountdown = true;
			});
			Lua_helper.add_callback(lua.state,"flashCam", function(cam:String='game',?dur:Float=0.5,?color:String='FFFFFF'){
				CoolUtil.cameraFromString(cam).flash(CoolUtil.getColorFromHex(color), dur);
			});
			Lua_helper.add_callback(lua.state,"fadeCam", function(cam:String='game',?dur:Float=0.5,?color:String='FFFFFF'){
				CoolUtil.cameraFromString(cam).fade(CoolUtil.getColorFromHex(color), dur);
			});
			Lua_helper.add_callback(lua.state,"notePlayAnim", function(note:Int,animation:String,forced:Bool=false){
				hittableNotes[note].animation.play(animation,forced);
			});
			Lua_helper.add_callback(lua.state,"unspawnNotePlayAnim", function(note:Int,animation:String,forced:Bool=false){
				unspawnNotes[note].animation.play(animation,forced);
			});
			Lua_helper.add_callback(lua.state,"vcr", function(on:Bool=true,mod:Float=0.2){
				
											if(currentOptions.senpaiShaders){
												if (vcrDistortionHUD != null){
													if(on){
														
													vcrDistortionGame.setGlitchModifier(mod);
													vcrDistortionHUD.setGlitchModifier(mod);
													vcrDistortionHUD.setDistortion(false);
													modchart.addCamEffect(vcrDistortionGame);
													modchart.addHudEffect(vcrDistortionHUD);
													}else{
														
													modchart.removeCamEffect(vcrDistortionGame);
													modchart.removeHudEffect(vcrDistortionHUD);
													}
												}
											}
			});
			Lua_helper.add_callback(lua.state,"playSound", function(snd:String,vol:Float=1,loop:Bool=false){
				FlxG.sound.play(Paths.sound(snd),vol,loop);
			});
			Lua_helper.add_callback(lua.state, "endSong", function(){
				KillNotes();
				endSong();
			});
			Lua_helper.add_callback(lua.state, "setCamPos", function(xx:Float=0, yy:Float=0,reset:Bool=false){
				setCamPos(xx,yy,reset);
			});
			Lua_helper.add_callback(lua.state, "changeBPM", function(bpm:Int){
				Conductor.changeBPM(bpm);
			});
		Lua_helper.add_callback(lua.state, "getVar", function(variable:String) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = null;
					coverMeInPiss = Reflect.getProperty(PlayState.instance, killMe[0]);

				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
			}
			return Reflect.getProperty(PlayState.instance, variable);
		});
		Lua_helper.add_callback(lua.state, "setVar", function(variable:String, value:Dynamic) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = null;
					coverMeInPiss = Reflect.getProperty(PlayState.instance, killMe[0]);

				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
			}
			return Reflect.setProperty(PlayState.instance, variable, value);
		});
		Lua_helper.add_callback(lua.state, "tweenVar", function(variable:String, value:Dynamic,duration:Float,easing:String='linear') {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = null;
					coverMeInPiss = Reflect.getProperty(PlayState.instance, killMe[0]);

				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				var object:Dynamic = {};
				Reflect.setField(object, killMe[killMe.length - 1], value);
				FlxTween.tween(coverMeInPiss, object, duration, {ease:Reflect.field(FlxEase, easing)});
				//return Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
			}
			
				var object:Dynamic = {};
				Reflect.setField(object, variable, value);
			
			
				FlxTween.tween(PlayState.instance, object, duration, {ease:Reflect.field(FlxEase, easing)});
			//return Reflect.setProperty(PlayState.instance, variable, value);
		});
		Lua_helper.add_callback(lua.state, "getGroupVar", function(obj:String, index:Int, variable:Dynamic) {
			if(Std.isOfType(Reflect.getProperty(PlayState.instance, obj), FlxTypedGroup)) {
				return getGroupStuff(Reflect.getProperty(PlayState.instance, obj).members[index], variable);
			}

			var leArray:Dynamic = Reflect.getProperty(PlayState.instance, obj)[index];
			if(leArray != null) {
				if(Type.typeof(variable) == ValueType.TInt) {
					return leArray[variable];
				}
				return getGroupStuff(leArray, variable);
			}
		//	luaTrace("Object #" + index + " from group: " + obj + " doesn't exist!");
			return null;
		});
		Lua_helper.add_callback(lua.state, "setGroupVar", function(obj:String, index:Int, variable:Dynamic, value:Dynamic) {
			if(Std.isOfType(Reflect.getProperty(PlayState.instance, obj), FlxTypedGroup)) {
				setGroupStuff(Reflect.getProperty(PlayState.instance, obj).members[index], variable, value);
				return;
			}

			var leArray:Dynamic = Reflect.getProperty(PlayState.instance, obj)[index];
			if(leArray != null) {
				if(Type.typeof(variable) == ValueType.TInt) {
					leArray[variable] = value;
					return;
				}
				setGroupStuff(leArray, variable, value);
			}
		});
			Lua_helper.add_callback(lua.state,"setOption", function(variable:String,val:Any){
				Reflect.setField(currentOptions,variable,val);
			});

			Lua_helper.add_callback(lua.state,"trace", function(val:String){
				trace(val);
			});

			Lua_helper.add_callback(lua.state,"getOption", function(variable:String){
				return Reflect.field(currentOptions,variable);
			});
			Lua_helper.add_callback(lua.state,"beatCam", function(z1:Float,z2:Float){
				beatCam(z1,z2);
			});

			
			
			
			
		Lua_helper.add_callback(lua.state, "getClassVar", function(classVar:String, variable:String) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = Reflect.getProperty(Type.resolveClass(classVar), killMe[0]);
				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
			}
			return Reflect.getProperty(Type.resolveClass(classVar), variable);
		});
		Lua_helper.add_callback(lua.state, "setClassVar", function(classVar:String, variable:String, value:Dynamic) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = Reflect.getProperty(Type.resolveClass(classVar), killMe[0]);
				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
			}
			return Reflect.setProperty(Type.resolveClass(classVar), variable, value);
		});

			
			
			
			
			
			
			
			
			
			
			
			/*
			Lua_helper.add_callback(lua.state,"newShader", function(shaderType:String, ?shaderName:String){
				var shader:Any;
				var name = "UnnamedShader"+unnamedLuaShaders;

				if(shaderName!=null)
					name=shaderName;
				else
					unnamedLuaShaders++;

				var lShader = new LuaShaderClass(shader,name,shaderName!=null);
				var classIdx = Lua.gettop(lua.state)+1;
				lShader.Register(lua.state);
				Lua.pushvalue(lua.state,classIdx);
			});*/
			// put on pause for now

			Lua_helper.add_callback(lua.state,"newCharacter", function(xx:Float,yy:Float,name:String,isPlayer:Bool=false,drawBehind:Bool=false){
				addNewCharacter(xx, yy, name, isPlayer,drawBehind,'camGame');
			});
			Lua_helper.add_callback(lua.state,"newCharacterHUD", function(xx:Float,yy:Float,name:String,isPlayer:Bool=false,drawBehind:Bool=false){
				addNewCharacter(xx, yy, name, isPlayer,drawBehind,'camHUD');
			});
			Lua_helper.add_callback(lua.state,"newSprite", function(?x:Int=0,?y:Int=0,?drawBehind:Bool=false,?spriteName:String,camera:String='game'){
				var sprite = new FlxSprite(x,y);
				var name = "UnnamedSprite"+unnamedLuaSprites;
				if(spriteName!=null)
					name=spriteName;
				else
					unnamedLuaSprites++;

				var lSprite = new LuaSprite(sprite,name,spriteName!=null);
				var classIdx = Lua.gettop(lua.state)+1;
				lSprite.Register(lua.state);
				Lua.pushvalue(lua.state,classIdx);
				if(drawBehind){
					var idx=0;
					var foundGF=-1;
					var foundBF=-1;
					var foundDad=-1;
					var daIndex=-1;
					this.forEach( function(blegh:FlxBasic){ // WEIRD LAYERING SHIT BUT HEY IT WORKS
						if(blegh==gf){
							foundGF=idx;
						}
						if(blegh==boyfriend){
							foundBF=idx;
						}
						if(blegh==dad){
							foundDad=idx;
						}

						if(foundDad!=-1 && foundGF!=-1 && foundBF!=-1 && daIndex==-1){
							var bruh = [foundDad,foundGF,foundBF];
							var curr = foundDad;
							for(v in bruh){
								if(v<curr){
									curr=v;
								}
							}
							daIndex=curr;
						}
						idx++;
					});
					if(daIndex!=-1){
						members.insert(daIndex,sprite);
						@:bypassAccessor
							this.length++;
					}else{
						add(sprite);
					}
				}else{
					add(sprite);
				};
				
				sprite.cameras = [CoolUtil.cameraFromString(camera)];
			});

			var leftPlayerNote = new LuaNote(0,true);
			var downPlayerNote = new LuaNote(1,true);
			var upPlayerNote = new LuaNote(2,true);
			var rightPlayerNote = new LuaNote(3,true);

			var leftDadNote = new LuaNote(0,false);
			var downDadNote = new LuaNote(1,false);
			var upDadNote = new LuaNote(2,false);
			var rightDadNote = new LuaNote(3,false);

			var luaModchart = new LuaModchart(modchart);

			bfLua = new LuaCharacter(boyfriend,"bf",true);
			gfLua = new LuaCharacter(gf,"gf",true);
			dadLua = new LuaCharacter(dad,"dad",true);

			var bfIcon = new LuaSprite(iconP1,"iconP1",true);
			var dadIcon = new LuaSprite(iconP2,"iconP2",true);

			var window = new LuaWindow();

			var luaGameCam = new LuaCam(FlxG.camera,"gameCam");
			var luaHUDCam = new LuaCam(camHUD, "HUDCam");
			
			
			for(i in [luaModchart,leftPlayerNote,downPlayerNote,upPlayerNote,rightPlayerNote,leftDadNote,downDadNote,upDadNote,rightDadNote,window,bfLua,gfLua,dadLua,bfIcon,dadIcon,luaGameCam,luaHUDCam])
				i.Register(lua.state);

			try {
				lua.runFile(openfl.utils.Assets.grtText('songs': + Paths.modchart(SONG.song.toLowerCase())));
			}catch (e:Exception){
				trace("ERROR: " + e);
			};
			
			
			
			if(luaModchartExists && lua!=null){
				lua.call("createPost",[]);
			}
		}

		scrollSpeed = (currentOptions.downScroll?-1:1);
		if(currentOptions.downScroll){
			strumLine.y = FlxG.height-150;
		}
		if(currentOptions.downScroll){
			healthBar.y = 5+FlxG.height*.1;
			healthBarBG.y = FlxG.height*.1;
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		}


		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					if (hasDialogue){
						dialogueText(doof);
					}else{
						new FlxTimer().start(0.5,function(e:FlxTimer){
						startCountdown();
						});
					}
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				case 'smile-hd':
					
					new FlxTimer().start(0.5,function(e:FlxTimer){
						FlxG.sound.play(Paths.sound('pinkie_land'));
						dad.playAnim('fall');
					FlxTween.tween(dad, {y: 0}, 11 / 24, {ease:FlxEase.circIn,onComplete:function(e:FlxTween){
						
						dad.playAnim('land');
						
						
					}});
					new FlxTimer().start(0.9,function(e:FlxTimer){
						startCountdown();
						});
					});
				default:
					new FlxTimer().start(0.5,function(e:FlxTimer){
						startCountdown();
						});
			}
		}

		cz = FlxG.camera.zoom;
		super.create();
	}
	
	public function setCamPos(xx:Float, yy:Float, reset:Bool=false) 
	{
		anotherPoint = true;
				if(xx != 9999 && yy != 9999 && !reset)
					camFollow.setPosition(xx, yy);
				else
					anotherPoint = false;
				
	}

	function AnimWithoutModifiers(a:String){
		var reg1 = new EReg(".+Hold","i");
		var reg2 = new EReg(".+Repeat","i");
		trace(reg1.replace(reg2.replace(a,""),""));
		return reg1.replace(reg2.replace(a,""),"");
	}
	function addNewCharacter(x,y,name,isplayer,drawBehind,cam:String=''){
			var sprite = new Character(x, y, name, isplayer);
			
			sprite.cameras = [CoolUtil.cameraFromString(cam)];
			
			
				if(drawBehind){
					var idx=0;
					var foundGF=-1;
					var foundBF=-1;
					var foundDad=-1;
					var daIndex=-1;
					this.forEach( function(blegh:FlxBasic){ // WEIRD LAYERING SHIT BUT HEY IT WORKS
						if(blegh==gf){
							foundGF=idx;
						}
						if(blegh==boyfriend){
							foundBF=idx;
						}
						if(blegh==dad){
							foundDad=idx;
						}

						if(foundDad!=-1 && foundGF!=-1 && foundBF!=-1 && daIndex==-1){
							var bruh = [foundDad,foundGF,foundBF];
							var curr = foundDad;
							for(v in bruh){
								if(v<curr){
									curr=v;
								}
							}
							daIndex=curr;
						}
						idx++;
					});
					if(daIndex!=-1){
						members.insert(daIndex,sprite);
						@:bypassAccessor
							this.length++;
					}else{
						add(sprite);
					}
				}else{
					add(sprite);
				};
			
			
			
			
			
			
			
			
			
			
			add(sprite);
			newChars.push(sprite);
			var newluachar = new LuaCharacter(sprite,name,true);
				var classIdx = Lua.gettop(lua.state)+1;
				newluachar.Register(lua.state);
				Lua.pushvalue(lua.state,classIdx);
	}
	public function swapCharacterByLuaName(spriteName:String,newCharacter:String){
		var sprite = luaSprites[spriteName];
		if(sprite!=null){
			var newSprite:Character;
			var spriteX = sprite.x;
			var spriteY = sprite.y;
			var currAnim:String = "idle";
			if(sprite.animation.curAnim!=null)
				currAnim=sprite.animation.curAnim.name;
			trace(currAnim);
			remove(sprite);
			// TODO: Make this BETTER!!!
			if(spriteName=="bf"){
				boyfriend = new Boyfriend(spriteX,spriteY,newCharacter);
				newSprite = boyfriend;
				bfLua.sprite = boyfriend;
				//iconP1.changeCharacter(newCharacter);
			}else if(spriteName=="dad"){
				dad = new Character(spriteX,spriteY,newCharacter);
				newSprite = dad;
				dadLua.sprite = dad;
				//iconP2.changeCharacter(newCharacter);
			}else if(spriteName=="gf"){
				gf = new Character(spriteX,spriteY,newCharacter);
				newSprite = gf;
				gfLua.sprite = gf;
			}else{
				newSprite = new Character(spriteX,spriteY,newCharacter);
			}

			luaSprites[spriteName]=newSprite;
			add(newSprite);
			trace(currAnim);
			if(currAnim!="idle" && !currAnim.startsWith("dance")){
				newSprite.playAnim(currAnim);
			}else if(currAnim=='idle' || currAnim.startsWith("dance")){
				newSprite.dance();
			}


		}
	}
	
	function dialogueText(?dialogueBox:DialogueBox){
		
		inCutscene = true;
		add(dialogueBox);
	}
	function meter(){
		getSpr('killometer').animation.play('kill-o-meter', true);
		FlxTween.tween(getSpr('killometer'), {y:455.8}, 0.1,{ease:FlxEase.backOut});
		new FlxTimer().start(1.6, function(e:FlxTimer){
			
		getSpr('pinkieGlow').visible = true;
			
		FlxTween.tween(getSpr('killometer'),{y:720},0.3,{ease:FlxEase.sineIn});
			
			
		}
		);
	}
	function dashCam(){
		
		FlxG.sound.play(Paths.sound('dashCam'),0.8);
		getSpr('dashCam').visible = true;
		getSpr('dashCam').animation.play('dashcam', true);
		FlxTween.tween(getSpr('dashCam'), {x:555.45}, 0.3);
		setCamPos(640,360);
		new FlxTimer().start(80 / 24, function(e:FlxTimer){
			
			
		setCamPos(0,0,true);
		FlxTween.tween(getSpr('dashCam'),{x:1280},0.2,{ease:FlxEase.sineIn});
			
			
		}
		);
	}
	function kickcutscene(){
		hd_dash.visible = true;
		dad.disabledDance = true;
		dad.playAnim('kick', true);
		hd_dash.origin.set(452, 0);
		hd_dash.scale.set(0.04, 0.04);
		hd_dash.angle = -10;
		FlxG.sound.play(Paths.sound('pinkie_kick'),0.8);
		FlxTween.tween(hd_dash.scale, {x:1, y:1}, 9 / 24, {ease:FlxEase.quadIn});
		FlxTween.tween(hd_dash, {x:757.45, y:57,angle:0}, 9 / 24, {ease:FlxEase.quadIn,onComplete:function(e:FlxTween=null){
			
			hd_dash.animation.play('ouch', true);
			camGame.zoom = 1.2;
			FlxTween.tween(camGame, {zoom:0.9}, 10 / 24, {ease:FlxEase.circIn});
			
			new FlxTimer().start(1, function(e:FlxTimer){
				
				dad.disabledDance = false;
			});
			
			
			FlxG.camera.shake(0.02, 8 / 24, function(){
				
				hd_dash.visible = false;
			new FlxTimer().start(2 / 24, function(e:FlxTimer){
				
				hd_tree.visible = false;
				FlxG.camera.shake(0.01, 0.5);
			});
				treeexplode.visible = true;
				treeexplode.animation.play('boom');
				beatCam(0.02,0.03);
				
			});
			
		}});
	}
	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	
	
	
	
	public function KillNotes(skipping:Bool = false) {
		
		if (skipping){
			
		}
		
		
		while(hittableNotes.length > 0) {
			var daNote:Note = hittableNotes[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			hittableNotes.remove(daNote);
			daNote.destroy();
		}
		unspawnNotes = [];
	}
	
	
	
	
	
	
	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	
	
	
	
	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;//Conductor.songPosition -= Conductor.crochet * 1;
		if(!skipCountdown)Conductor.songPosition -= Conductor.crochet * 5;
		
		var swagCounter:Int = 0;
		if (skipCountdown) swagCounter = 3;
		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance(dadaltAnim);
			gf.dance();
			boyfriend.dance(bfaltAnim);
			
			if(luaModchartExists && lua!=null){
				lua.call("countdown", [swagCounter]);
				lua.call("beatHit",[0]);
			}
			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', [assetPrefix+'ready'+assetSuffix, assetPrefix+"set"+assetSuffix, assetPrefix+"go"+assetSuffix]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound(assetPrefix+'intro3'+assetSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();
					ready.cameras = [camHUD];
					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound(assetPrefix+'intro2'+assetSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					set.cameras = [camHUD];
					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound(assetPrefix+'intro1'+assetSuffix), 0.6);
				case 3:
					if(!skipCountdown){
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();

					go.cameras = [camHUD];
						if (curStage.startsWith('school'))
							go.setGraphicSize(Std.int(go.width * daPixelZoom));

						go.updateHitbox();

						go.screenCenter();
						add(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound(assetPrefix+'introGo'+assetSuffix), 0.6);
				}
				case 4:
			}
			beatHit();
			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;
	var plane:FlxSound;
	function startSong():Void
	{
		
		
		startingSong = false;

		if(luaModchartExists && lua!=null){
			lua.call("startSong",[]);
		}
		if(luaModchartExists && lua!=null){
			lua.call("beatHit",[0]);
		}
		if(luaModchartExists && lua!=null){
			lua.call("stepHit",[0]);
		}
		if(luaModchartExists && lua!=null){
			lua.call("songStart",[]);
		}
		
		if (SONG.song.toLowerCase() == 'discord'){
			new FlxTimer().start(FlxG.random.int(60, 120), function(e:FlxTimer){
						  getSpr('screwball').velocity.x = -300;
						  plane = FlxG.sound.play(Paths.sound('plane'), 0.7, true);
						  plane.proximity( 0, 0, getSpr('screwball'), 1200, true);
						 });
		}
		
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(daInst, 1, false);
			FlxG.sound.music.looped=false;
			if(currentOptions.noteOffset==0)
				FlxG.sound.music.onComplete = endSong;
			else
				FlxG.sound.music.onComplete = function(){
					dontSync=true;
				};

		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (songData.needsVoices){
			vocals = new FlxSound().loadEmbedded(Paths.voices(songData.song));
		}else
			vocals = new FlxSound();

		vocals.looped=false;

		FlxG.sound.list.add(vocals);

		renderedNotes = new FlxTypedGroup<Note>();
		add(renderedNotes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for(idx in 0...4){ // TODO: 6K OR 7K MODE!!
			if(idx==4)break;
			noteLanes[idx]=[];
			susNoteLanes[idx]=[];

		}

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daType:Int=0;
				var daTex:String='';
				if (songNotes[3] != null) daType = songNotes[3];
				if (songNotes[4] != null) daTex = songNotes[4];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;
				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				daStrumTime += currentOptions.noteOffset;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, getPosFromTime(daStrumTime),false,daType,daTex);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;

				if (susLength < 2) susLength = 0;//to get rid of tiny hold notes
				unspawnNotes.push(swagNote);
				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					var sussy = daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet;
					var sustainNote:Note = new Note(sussy, daNoteData, oldNote, true, getPosFromTime(sussy),false,daType,daTex);

					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
						sustainNote.defaultX = sustainNote.x;
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
					swagNote.defaultX = swagNote.x;
				}
				else {}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}
	// ADAPTED FROM QUAVER!!!
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	function mapVelocityChanges(){
		if(SONG.sliderVelocities.length==0)
			return;

		var pos:Float = SONG.sliderVelocities[0].startTime*(SONG.initialSpeed);
		velocityMarkers.push(pos);
		for(i in 1...SONG.sliderVelocities.length){
			trace(SONG.sliderVelocities[i],SONG.sliderVelocities[i-1],i-1,i);
			pos+=(SONG.sliderVelocities[i].startTime-SONG.sliderVelocities[i-1].startTime)*(SONG.initialSpeed*SONG.sliderVelocities[i-1].multiplier);
			velocityMarkers.push(pos);
		}
	};
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// ADAPTED FROM QUAVER!!!

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var dirs = ["left","down","up","right"];
			var clrs = ["purple","blue","green","red"];

			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			if(currentOptions.middleScroll && player==0)
				babyArrow.visible=false;

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					
						
			var path = "";
			var balls:Array<String> = [TitleState.curDir, "assets"];
			var stopLookin = false;
			for (i in balls){
				if(!stopLookin){
					if (FileSystem.exists(Generic.returnPath() + i + "/shared/images/"+SONG.strumskin+".xml")){
						path = i + "/shared/images/"+SONG.strumskin+".xml";
						stopLookin = true;
						break;
					}
				}
			}
			
			
			
			
			
				babyArrow.frames = FlxAtlasFrames.fromSparrow(Paths.getbmp(SONG.strumskin), File.getContent(path));//Paths.getSparrowAtlas('NOTE_assets');

				
				
					
					
					
					
					
					

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * SONG.notescale));

					var idx = Std.int(Math.abs(i));
					var dir = dirs[idx];
					babyArrow.x += Note.swagWidth*idx;
					babyArrow.animation.addByPrefix('static', 'arrow${dir.toUpperCase()}');
					babyArrow.animation.addByPrefix('pressed', '${dir} press', 24, false);
					babyArrow.animation.addByPrefix('confirm', '${dir} confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.ID = i;
			var newStrumLine:FlxSprite = new FlxSprite(0, strumLine.y).makeGraphic(10, 10);
			newStrumLine.scrollFactor.set();

			var newNoteRef:FlxSprite = new FlxSprite(0,-1000).makeGraphic(10, 10);
			newNoteRef.scrollFactor.set();

			var newRecepRef:FlxSprite = new FlxSprite(0,-1000).makeGraphic(10, 10);
			newRecepRef.scrollFactor.set();

			if (player == 1)
			{
				playerStrums.add(babyArrow);
				playerStrumLines.add(newStrumLine);
				refNotes.add(newNoteRef);
				refReceptors.add(newRecepRef);
			}else{
				dadStrums.add(babyArrow);
				opponentStrumLines.add(newStrumLine);
				opponentRefNotes.add(newNoteRef);
				opponentRefReceptors.add(newRecepRef);
			}

			if (!isStoryMode)
			{
				newStrumLine.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(newNoteRef, {alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				FlxTween.tween(newStrumLine,{y: babyArrow.y + 10}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.animation.play('static');
			if(!currentOptions.middleScroll){
				babyArrow.x += 50;
				babyArrow.x += ((800) * player);
			}

			newStrumLine.x = babyArrow.x;

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	function updateAccuracy():Void
	{
		if(totalNotes==0)
			accuracy = 1;
		else
			accuracy = hitNotes / totalNotes;

		grade = ScoreUtils.AccuracyToGrade(accuracy) + (misses==0 ? " (FULL COMBO)" : ""); // TODO: Diff types of FC?? (MFC, SFC, GFC, BFC, WTFC)
		missesTxt.text = "Miss: " + misses;
		sicksTxt.text = "Sick: " + sicks;
		goodsTxt.text = "Good: " + goods;
		badsTxt.text = "Bad: " + bads;
		shitsTxt.text = "Shit: " + shits;
	}
	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC, true, songLength-Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(!dontSync){
			vocals.pause();

			FlxG.sound.music.play();
			Conductor.songPosition = FlxG.sound.music.time;
			vocals.time = Conductor.songPosition;
			vocals.play();
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}
	//public float GetSpritePosition(long offset, float initialPos) => HitPosition + ((initialPos - offset) * (ScrollDirection.Equals(ScrollDirection.Down) ? -HitObjectManagerKeys.speed : HitObjectManagerKeys.speed) / HitObjectManagerKeys.TrackRounding);
	// ADAPTED FROM QUAVER!!!
	// COOL GUYS FOR OPEN SOURCING
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	function getPosFromTime(strumTime:Float):Float{
		var idx:Int = 0;
		while(idx<SONG.sliderVelocities.length){
			if(strumTime<SONG.sliderVelocities[idx].startTime)
				break;
			idx++;
		}
		return getPosFromTimeSV(strumTime,idx);
	}

	public static function getSusLength(strumTime:Float):Float{
		return (getSVFromTime(strumTime)*(scrollSpeed*(1/.45) ));
	}

	public static function getSVFromTime(strumTime:Float):Float{
		var idx:Int = 0;
		while(idx<SONG.sliderVelocities.length){
			if(strumTime<SONG.sliderVelocities[idx].startTime)
				break;
			idx++;
		}
		idx--;
		if(idx<=0)
			return SONG.initialSpeed;
		return SONG.initialSpeed*SONG.sliderVelocities[idx].multiplier;
	}

	function getPosFromTimeSV(strumTime:Float,?svIdx:Int=0):Float{
		if(svIdx==0)
			return strumTime*SONG.initialSpeed;

		svIdx--;
		var curPos = velocityMarkers[svIdx];
		curPos += ((strumTime-SONG.sliderVelocities[svIdx].startTime)*(SONG.initialSpeed*SONG.sliderVelocities[svIdx].multiplier));
		return curPos;
	}

	function updatePositions(){
		currentVisPos = Conductor.songPosition;
		currentTrackPos = getPosFromTime(currentVisPos);
	}

	function getYPosition(note:Note):Float{
		var hitPos = playerStrumLines.members[note.noteData];
		if(!note.mustPress){
			hitPos = opponentStrumLines.members[note.noteData];
		}
		return hitPos.y + ((note.initialPos-currentTrackPos) * scrollSpeed);
	}

	// ADAPTED FROM QUAVER!!!
	// COOL GUYS FOR OPEN SOURCING
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver
	// https://github.com/Quaver/Quaver

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end
		updatePositions();
		if(vcrDistortionHUD!=null){
			vcrDistortionHUD.update(elapsed);
			vcrDistortionGame.update(elapsed);
		}
		if(rainShader!=null){
			rainShader.update(elapsed);
		}
		modchart.update(elapsed);
		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				//phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
				if(currentOptions.picoShaders && lightFadeShader!=null)
					lightFadeShader.addAlpha((Conductor.crochet / 1000) * FlxG.elapsed * 1.5);
				else
					phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
		}

		iconP1.visible = modchart.hudVisible;
		iconP2.visible = modchart.hudVisible;
		healthBar.visible = modchart.hudVisible;
		healthBarBG.visible = modchart.hudVisible;
		sicksTxt.visible = modchart.hudVisible;
		badsTxt.visible = modchart.hudVisible;
		shitsTxt.visible = modchart.hudVisible;
		goodsTxt.visible = modchart.hudVisible;
		missesTxt.visible = modchart.hudVisible;
		highComboTxt.visible = modchart.hudVisible;
		scoreTxt.visible = modchart.hudVisible;
		if(presetTxt!=null)
			presetTxt.visible = modchart.hudVisible;


		super.update(elapsed);

		if (ScoreUtils.botPlay){
			scoreTxt.x = healthBarBG.x + healthBarBG.width / 2 - 150;
			scoreTxt.y = healthBarBG.y + 50;
			scoreTxt.fieldWidth = 0;
			scoreTxt.size = 60;
			scoreTxt.screenCenter(X);
			if(currentOptions.downScroll) scoreTxt.offset.y = 0;
			if(!currentOptions.downScroll) scoreTxt.offset.y = 180;
			scoreTxt.text = 'BOTPLAY';
		}else{
			scoreTxt.x = healthBarBG.x + healthBarBG.width / 2 - 150;
			scoreTxt.y = healthBarBG.y + 50;
			scoreTxt.fieldWidth = 0;
			scoreTxt.size = 30;
			scoreTxt.screenCenter(X);
			scoreTxt.offset.y = 0;
			if(currentOptions.downScroll) scoreTxt.offset.y = -20;
			if(!currentOptions.downScroll) scoreTxt.offset.y = 180;
		scoreTxt.text = "Score:" + songScore + " | Accuracy:" + truncateFloat(accuracy*100, 2) + "% | " + grade;
		}

		if(misses>0 && currentOptions.failForMissing){
			health=0;
		}
		previousHealth=health;
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
				Cache.Clear();
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			DiscordClient.changePresence(detailsPausedText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{


			
			if(lua!=null){
				lua.destroy();
				trace("cringe");
				lua=null;
			}
			
			FlxG.switchState(new ChartingState());
			Cache.Clear();

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

	//	iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.width, 150, 0.2/fpsRatio)));
		//iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.width, 150, 0.2/fpsRatio)));

		//iconP1.updateHitbox();
		//iconP2.updateHitbox();

		iconP1.scale.set(FlxMath.lerp(iconP1.scale.x, 1, 0.2 / fpsRatio),FlxMath.lerp(iconP1.scale.y, 1, 0.2 / fpsRatio));
		iconP2.scale.set(FlxMath.lerp(iconP2.scale.x, 1, 0.2 / fpsRatio),FlxMath.lerp(iconP2.scale.y, 1, 0.2 / fpsRatio));
		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2){
			health = 2;
			previousHealth = health;
			if(luaModchartExists && lua!=null)
				lua.setGlobalVar("health",health);
		}

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		if (FlxG.keys.justPressed.EIGHT){
			
				AnimationDebug.isDad = true;
				FlxG.switchState(new AnimationDebug(SONG.player2));
				Cache.Clear();
				
				if(lua!=null){
					lua.destroy();
					lua=null;
				}
				
			}
			if (FlxG.keys.justPressed.NINE){
				AnimationDebug.isDad = false;
				FlxG.switchState(new AnimationDebug(SONG.player1,false));
				Cache.Clear();
				
				if(lua!=null){
					lua.destroy();
					lua=null;
				}
				
			}
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			if(!endingSong)Conductor.songPosition += FlxG.elapsed * 1000;
			if(Conductor.songPosition>=vocals.length){
				dontSync=true;
				vocals.volume=0;
				vocals.stop();
			}

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}
		try{
			if(luaModchartExists && lua!=null)
				lua.setGlobalVar("songPosition",Conductor.songPosition);
		}catch(e:Any){
			trace(e);
		}
		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}
			

		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom,defaultCamZoom, 0.07/fpsRatio);
			camHUD.zoom = FlxMath.lerp(camHUD.zoom,defaultHudZoom, 0.07/fpsRatio);
		}
		if (cz != defaultCamZoom){
			//cz = defaultCamZoom;
			
			//if (camMoveTween != null) camMoveTween.cancel();
			//camMoveTween = FlxTween.tween(FlxG.camera, {zoom:defaultCamZoom},Conductor.crochet/1000,{ease:FlxEase.sineInOut});
			
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if(curSong == 'Spookeez'){
			switch (curStep){
				case 444,445:
					gf.playAnim("cheer",true);
					boyfriend.playAnim("hey",true);
			}
		}

		
		
		
		
		
		
		
		
		bitch += (elapsed/0.016);
		if (curSong == 'Discord')
		{
			
			var t = 0.00;
			for (i in floatShits){
				var r = 1;
				if (t % 160 == 0) r = -1;
				t += 80;
				i.angle = Math.sin((bitch + t)/100) * 2 * r;
				i.offset.y = Math.sin((bitch + t)/10)*8;
			}
		}
		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			previousHealth = health;
			if(luaModchartExists && lua!=null)
				lua.setGlobalVar("health",health);
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y,boyf,deathSound,deathSong,deathEndSong,deathColor));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText + SONG.song + " (" + storyDifficultyText + ")", grade + " | Acc: " + truncateFloat(accuracy*100,2) + "%", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (currentTrackPos-getPosFromTime(unspawnNotes[0].strumTime)>-300000)
			{
				var dunceNote:Note = unspawnNotes[0];
				renderedNotes.add(dunceNote);

				if(dunceNote.mustPress){
					if(dunceNote.isSustainNote)
						susNoteLanes[dunceNote.noteData].push(dunceNote);
					else
						noteLanes[dunceNote.noteData].push(dunceNote);
					noteLanes[dunceNote.noteData].sort((a,b)->Std.int(a.strumTime-b.strumTime));
					susNoteLanes[dunceNote.noteData].sort((a,b)->Std.int(a.strumTime-b.strumTime));
				}
				hittableNotes.push(dunceNote);
				hittableNotes.sort((a,b)->Std.int(a.strumTime-b.strumTime));
				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);

			}
		}

		if (generatedMusic)
		{
			for(idx in 0...playerStrumLines.length){
				var line = playerStrumLines.members[idx];
				if(currentOptions.middleScroll){
					line.screenCenter(X);
					line.x += Note.swagWidth*(-2+idx) + playerNoteOffsets[idx][0];
				}else{
					line.x = (Note.swagWidth*idx) + 120 + ((FlxG.width / 2)) + playerNoteOffsets[idx][0];
				}
				line.y = strumLine.y+playerNoteOffsets[idx][1];
			}
			for(idx in 0...opponentStrumLines.length){
				var line = opponentStrumLines.members[idx];

				line.x = (Note.swagWidth*idx) + 50 +opponentNoteOffsets[idx][0];
				line.y = strumLine.y+opponentNoteOffsets[idx][1];
			}

			for (idx in 0...strumLineNotes.length){
				var note = strumLineNotes.members[idx];
				var offset = opponentNoteOffsets[idx%4];
				var strumLine = opponentStrumLines.members[idx%4];
				var alpha = opponentRefReceptors.members[idx%4].alpha;
				var angle = opponentRefReceptors.members[idx%4].angle;
				if(idx>3){
					offset = playerNoteOffsets[idx%4];
					strumLine = playerStrumLines.members[idx%4];
					alpha = refReceptors.members[idx%4].alpha;
					angle = refReceptors.members[idx%4].angle;
				}
				if(modchart.opponentNotesFollowReceptors && idx>3 || idx<=3 && modchart.playerNotesFollowReceptors){
					note.x = strumLine.x;
					note.y = strumLine.y;
				}else{

				}

				note.alpha = alpha;
				note.angle=angle;
			}

			if(startedCountdown){
				renderedNotes.forEachAlive(function(daNote:Note)
				{
					var strumLine = strumLine;
					if(modchart.playerNotesFollowReceptors)
						strumLine = playerStrumLines.members[daNote.noteData];


					var alpha = refNotes.members[daNote.noteData].alpha;
					if(!daNote.mustPress){
						alpha = opponentRefNotes.members[daNote.noteData].alpha;
						if(modchart.opponentNotesFollowReceptors)
							strumLine = opponentStrumLines.members[daNote.noteData];
					}

					if (daNote.y > FlxG.height)
					{
						daNote.active = false;

						daNote.visible = false;
					}
					else
					{
						if((daNote.mustPress || !daNote.mustPress && !currentOptions.middleScroll)){
							daNote.visible = true;
						}

						daNote.active = true;
					}

					if(!daNote.mustPress && currentOptions.middleScroll){
						daNote.visible=false;
					}

					var brr = strumLine.y + Note.swagWidth/2;
					daNote.y = getYPosition(daNote);
					if(currentOptions.downScroll){
						if(daNote.isSustainNote){
							if(daNote.animation.curAnim.name.endsWith("end") && daNote.prevNote!=null){
								daNote.y += daNote.prevNote.height;
							}else{
								daNote.y += daNote.height/2;
							}
						}
						if (daNote.isSustainNote
							&& daNote.y-daNote.offset.y*daNote.scale.y+daNote.height>=brr
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0,0,daNote.frameWidth*2,daNote.frameHeight*2);
							swagRect.height = (brr-daNote.y)/daNote.scale.y;
							swagRect.y = daNote.frameHeight-swagRect.height;

							daNote.clipRect = swagRect;
						}
					}else{
						if (daNote.isSustainNote
							&& daNote.y + daNote.offset.y * daNote.scale.y <= brr
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0,0,daNote.width/daNote.scale.x,daNote.height/daNote.scale.y);
							swagRect.y = (brr-daNote.y)/daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}



					daNote.x = strumLine.x;
					if(daNote.isSustainNote){

						if(daNote.tooLate)
							daNote.alpha = .3;
						else
							daNote.alpha = FlxMath.lerp(.6, 0, (1-alpha)/fpsRatio);
					}else{
						if(daNote.tooLate)
							daNote.alpha = .3;
						else
							daNote.alpha = alpha;
					}

					if (!daNote.mustPress && daNote.canBeHit && !daNote.wasGoodHit)
					{
						dadStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
							}
						});
						if (SONG.song != 'Tutorial')
							camZooming = true;

						var altAnim:String = dadaltAnim;
						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim)
								altAnim = '-alt';
						}
						if(luaModchartExists && lua!=null){
							lua.call("dadNoteHit",[Math.abs(daNote.noteData),daNote.strumTime,Conductor.songPosition,daNote.isSustainNote,daNote.noteType]); // TODO: Note lua class???
						}
						
						if(health > modchart.opponentHPDrain){
						health -= modchart.opponentHPDrain;
						}
							//if(!daNote.isSustainNote){

							var anim = "";
							
							switch (Math.abs(daNote.noteData))
							{
							case 0:
								//dad.playAnim('singLEFT' + altAnim, true);
								anim='singLEFT' + altAnim;
							case 1:
								//dad.playAnim('singDOWN' + altAnim, true);
								anim='singDOWN' + altAnim;
							case 2:
								//dad.playAnim('singUP' + altAnim, true);
								anim='singUP' + altAnim;
							case 3:
								//dad.playAnim('singRIGHT' + altAnim, true);
								anim='singRIGHT' + altAnim;
							}
							if(!daNote.noAnim){

							var canHold = daNote.isSustainNote && dad.animation.getByName(anim+"Hold")!=null;
							if(canHold && !dad.animation.curAnim.name.startsWith(anim)){
								dad.playAnim(anim,true);
							}else if(currentOptions.pauseHoldAnims && !canHold){
								dad.playAnim(anim,true);
								if(daNote.holdParent )
									dad.holding=true;
								else{
									dad.holding=false;
								}
							}else if(!currentOptions.pauseHoldAnims && !canHold){
								dad.playAnim(anim,true);
							}

							}
						//}
						dad.holdTimer = 0;


						if (SONG.needsVoices)
							vocals.volume = 1;
						daNote.wasGoodHit=true;
						lastHitDadNote=daNote;
						if(!daNote.isSustainNote){
							daNote.kill();
							if(daNote.mustPress)
								noteLanes[daNote.noteData].remove(daNote);

							hittableNotes.remove(daNote);
							daNote.destroy();
						}else if(daNote.mustPress){
							susNoteLanes[daNote.noteData].remove(daNote);
						}
					}

					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

					if (daNote.strumTime < Conductor.songPosition - Conductor.safeZoneOffset*1.5 && (!currentOptions.downScroll && daNote.y < -daNote.height || currentOptions.downScroll && daNote.y>FlxG.height) && daNote.mustPress)
					{
						if ((daNote.tooLate || !daNote.wasGoodHit) && !daNote.endHold)
						{
							
							trace(daNote.strumTime,daNote.wasGoodHit);
							health -= 0.0475;
							noteMiss(daNote.noteData);
							totalNotes++;
							vocals.volume = 0;
							updateAccuracy();
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						if(daNote.mustPress){
							if(daNote.isSustainNote)
								susNoteLanes[daNote.noteData].remove(daNote);
							else
								noteLanes[daNote.noteData].remove(daNote);
						}
						hittableNotes.remove(daNote);

						renderedNotes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
		}
		dadStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished && spr.animation.curAnim.name=='confirm' && (lastHitDadNote==null || !lastHitDadNote.isSustainNote || lastHitDadNote.animation.curAnim==null || lastHitDadNote.animation.curAnim.name.endsWith("end")))
			{
				spr.animation.play('static',true);
				spr.centerOffsets();
			}

				spr.centerOrigin();
			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
			}
			else
				spr.centerOffsets();
		});

		if (!inCutscene){
			if(currentOptions.newInput)
				keyShit();
			else
				oldKeyShit();

		}

		if (Conductor.songPosition - currentOptions.noteOffset >= FlxG.sound.music.length){
			trace('song ending?????');
			if(FlxG.sound.music.volume>0 || vocals.volume>0)
				endSong();

			FlxG.sound.music.volume=0;
			vocals.volume=0;
		}
		
		
		
	
		
		
						if (luaModchartExists && lua != null){
							lua.setGlobalVar('stepCrochet', Conductor.stepCrochet);
							lua.setGlobalVar('crochet', Conductor.crochet);
							lua.call("update", [elapsed]);
						}
		
		
		
		
		if (FlxG.keys.justPressed.ONE){
			KillNotes();
			FlxG.sound.music.time = FlxG.sound.music.length;
		}
		if (FlxG.keys.justPressed.TWO){
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
		}
		
	}
	
	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		vocals.time = time;
		vocals.play();
		Conductor.songPosition = time;
	}
	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = hittableNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = hittableNotes[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;

				daNote.kill();
				hittableNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}
	}
	
	
	function cameraShits(bf:Bool,center:Bool=false){
		
			if (!bf)
			{
				if(!anotherPoint){
				camFollow.setPosition(dad.getMidpoint().x + 150+dad.camOffset[0], dad.getMidpoint().y - 100+dad.camOffset[1]);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'pinkie' | 'pinkie-hd':
						camFollow.x = dad.getMidpoint().x ;
						camFollow.y = dad.getMidpoint().y ;
					case 'discord' | 'discord-atlas':
					//	camFollow.x = 704;
						//camFollow.y =-572.7;
						camFollow.x = dad.getMidpoint().x ;
						camFollow.y = dad.getMidpoint().y ;
				}
				}
				
				if(luaModchartExists && lua!=null){
					lua.call("dadTurn",[]);
				}
				
				
				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}
			
			
			if (bf)
			{
				if(!anotherPoint){
				camFollow.setPosition(boyfriend.getMidpoint().x - 100+boyfriend.camOffset[0], boyfriend.getMidpoint().y - 100+boyfriend.camOffset[1]);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}
				}
					if(luaModchartExists && lua!=null){
						lua.call("bfTurn",[]);
					}
				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
			
			if (center)
			{
				if (!anotherPoint){
					
				var ofsx = boyfriend.getMidpoint().x - 100 + boyfriend.camOffset[0];
				var ofsy = boyfriend.getMidpoint().y - 100 + boyfriend.camOffset[1];
					
				var ofsx2 = dad.getMidpoint().x + 100 + dad.camOffset[0];
				var ofsy2 = dad.getMidpoint().y - 100 + dad.camOffset[1];
				camFollow.setPosition((ofsx + ofsx2) / 2, bf?ofsy:ofsy2);
				}

			}
	}
	function endSong():Void
	{
		endingSong = true;
		TitleState.curDir = "assets";
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.stop();
		
		if(lua!=null){
			lua.destroy();
			lua=null;
		}
		
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			
			trace(hasEndDialogue);
			if (hasEndDialogue){
				
				try {
					dialogue = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + "/dialogueEnd"+(isPony?"-pony":"")));
					hasEndDialogue = false;
					if (currentOptions.lessBS) hasEndDialogue = false;
					
		doof = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.cameras = [camHUD];
					if (SONG.song.toLowerCase() == 'fun'){
						doof.finishThing = function(){
								FlxTween.tween(camHUD, {alpha: 0}, 0.4);
							trace(Conductor.songPosition);
						camFollow.x = dad.getMidpoint().x ;
				cloudo4 = addAnimPrefix( 300, -203.5, "pinkie/discord/cottoncloud3", "cottoncloud3", 1);
				cloudo4.alpha = 0;
				
				var discord = addAnimPrefix( -22.95, -809, "pinkie/discordEnter", "discordEnter", 1,false);
				discord.visible = false;
							dad.playAnim('lookback');
								FlxTween.tween(cloudo1, {alpha: 1}, 1);
								FlxTween.tween(cloudo2, {alpha: 1}, 1);
								FlxTween.tween(cloudo3, {alpha: 1}, 1);
								FlxTween.tween(cloudo4, {alpha: 1}, 0.2);
								
								
								
								
							new FlxTimer().start(0.2, function(e:FlxTimer){
								FlxG.sound.play(Paths.sound('ENTER_DISCORD'),1,false);
								FlxTween.tween(camFollow, {y: -240}, 2,{ease:FlxEase.sineInOut});
								FlxTween.tween(camGame, {zoom: 0.8}, 1.3);
								FlxTween.tween(instance, {defaultCamZoom: 0.8}, 1.3);
								
								
								
								new FlxTimer().start(2, function(e:FlxTimer){
									FlxTween.tween(camGame, {zoom: 1.1}, 2);
									FlxTween.tween(instance, {defaultCamZoom: 1.1}, 3);
									FlxTween.tween(SKY, {alpha: 0.4}, 2);
								});
								
								
								new FlxTimer().start(4.5, function(e:FlxTimer){
									camGame.flash();
									discord.visible = true;
									discord.animation.play('discordEnter');
									FlxG.sound.play(Paths.sound('discorddrink'),1,false);
									FlxTween.tween(instance, {defaultCamZoom: 0.8}, 0.3, {ease:FlxEase.circOut});
									FlxTween.tween(camGame, {zoom:  0.8}, 0.3, {ease:FlxEase.circOut});
								new FlxTimer().start(1.4, function(e:FlxTimer){
									lighting.alpha = 1;
									SKY.alpha = 0;
									FlxTween.tween(SKY, {alpha: 0.4}, 1);
									FlxTween.tween(lighting, {alpha: 0}, 1, {ease:FlxEase.linear});
									FlxG.sound.play(Paths.sound('lightning'));
									
								});
								new FlxTimer().start(5, function(e:FlxTimer){
									
									endSong();
									
								});
									
								});
								
								
								
							});
								
						};
					}else{
					doof.finishThing = endSong;
					}
		
					dialogueText(doof);
					trace(dialogue);
					
				} catch(e){
					trace("epic style " + e.message);
				}
			}else{
				trace('idfhuidhfjidjfidfijdifjdf');
				campaignScore += songScore;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{


					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					//FlxG.switchState(new HahaState());
					Cache.Clear();

					// if ()
					StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (SONG.validScore)
					{
						//NGio.unlockMedal(60961);
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					FlxG.save.flush();
					trace(SONG.song.toLowerCase());
					if (SONG.song.toLowerCase() == 'discord' ){
						if(isPony){
							FlxG.switchState(new CutsceneState("mods/introMod/_append/Twi End Cutscene.mp4", function(){
								FlxG.switchState(new CutsceneState("assets/videos/credits-pony.mp4", CutsceneState.end ));
							}));
						}else{
							FlxG.switchState(new CutsceneState("assets/videos/credits.mp4",CutsceneState.end ));
						}
					}else{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
						CutsceneState.end();
					}
				}
				else
				{
					var difficulty:String = "";

					if (storyDifficulty == 0)
						difficulty = '-easy';

					if (storyDifficulty == 2)
						difficulty = '-hard';

					trace('LOADING NEXT SONG');
					trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

					if (SONG.song.toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

			
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
					Cache.Clear();
				}
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
			Cache.Clear();
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(noteDiff:Float):Void
	{
		var daRating = ScoreUtils.DetermineRating(noteDiff);
		if(ScoreUtils.botPlay){
			daRating='sick';
		}

		totalNotes++;
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, strumLine.y-100, 0, placement, 32);
		coolText.screenCenter(X);
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = ScoreUtils.RatingToScore(daRating);

		if(daRating=='shit')
			shits++;
		else if(daRating=='bad')
			bads++;
		else if(daRating=='good')
			goods++;
		else
			sicks++;

		hitNotes+=ScoreUtils.RatingToHit(daRating);
		songScore += score;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(assetPrefix+pixelShitPart1 + daRating + pixelShitPart2+assetSuffix));
		rating.screenCenter(X);
		rating.x = coolText.x - 40;
		rating.y = strumLine.y;
		//rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(40, 75);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.cameras = [camHUD];
		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(assetPrefix+pixelShitPart1 + 'combo' + pixelShitPart2+assetSuffix));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		comboSpr.cameras = [camHUD];
		
	
		
		if(!ScoreUtils.botPlay)add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();
		if(currentOptions.ratingInHUD){
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];
			coolText.cameras = [camHUD];

			coolText.scrollFactor.set(0,0);
			rating.scrollFactor.set(0,0);
			comboSpr.scrollFactor.set(0,0);

			rating.x -= 175;
			coolText.x -= 175;
			comboSpr.x -= 175;
		}
		var seperatedScore:Array<String> = Std.string(combo).split("");
		var displayedMS = truncateFloat(noteDiff,2);
		var seperatedMS:Array<String> = Std.string(displayedMS).split("");
		var daLoop:Float = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2));
			numScore.screenCenter(XY);
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y = strumLine.y;
			numScore.y += 80;
			numScore.cameras = [camHUD];

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if(currentOptions.ratingInHUD){
				numScore.cameras = [camHUD];
				numScore.scrollFactor.set(0,0);
			}
			if(combo>=10){
				if(!ScoreUtils.botPlay)add(numScore);
			}
			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		daLoop=0;
		if(currentOptions.showMS){
			for (i in seperatedMS)
			{
				if(i=="."){
					i = "point";
					daLoop-=.5;
				}

				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = coolText.x + (32 * daLoop) - 25;
				numScore.y += 130;
				if(i=='point'){
					if(!curStage.startsWith("school"))
						numScore.x += 25;
					else{
						numScore.y += 35;
						numScore.x += 24;
					}
				}

				switch(daRating){
					case 'sick':
						numScore.color = 0x00ffff;
					case 'good':
						numScore.color = 0x14cc00;
					case 'bad':
						numScore.color = 0xa30a11;
					case 'shit':
						numScore.color = 0x5c2924;
				}
				if (!curStage.startsWith('school'))
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int((numScore.width * 0.5)*.75));
				}
				else
				{
					numScore.setGraphicSize(Std.int((numScore.width * daPixelZoom)*.75));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(100, 150);
				numScore.velocity.y -= FlxG.random.int(50, 75);
				numScore.velocity.x = FlxG.random.float(-2.5, 2.5);

				if(currentOptions.ratingInHUD){
					numScore.cameras = [camHUD];
					numScore.scrollFactor.set(0,0);
				}

				add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.0005
				});

				daLoop++;
			}
		}
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});


		updateAccuracy();
		curSection += 1;
	}

	private function keyShit():Void
	{
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var holdArray:Array<Bool> = [left,down,up,right];
		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		if(ScoreUtils.botPlay){
			holdArray=[false,false,false,false];
			controlArray=[false,false,false,false];
		}
		
		//i'll make my own input since this bit assin right now
		/*
		var lanes:Array<Array<Note>> = [[],[],[],[]];
		var FRONT_NOTES:Array<Note> = [];
		for (note in hittableNotes){
			if (note.mustPress)lanes[note.noteData].push(note);
		}
		
		for (nota in lanes){
			
				nota.sort((a,b)->Std.int(a.strumTime-b.strumTime));
			if (FRONT_NOTES[nota[0].noteData] == null) FRONT_NOTES.push(nota[0]);
		}
		
			var boobs = [];
		for (t in FRONT_NOTES){
			boobs.push(t.noteData);
		}
		trace(boobs);
		for (note in FRONT_NOTES){
			if (ScoreUtils.botPlay){
			
				if (note.mustPress && note.canBeHit && note.strumTime <= Conductor.songPosition){
					note.wasGoodHit = true;
					noteHit(note);
					boyfriend.holdTimer=0;
				}
			}
			if(note.mustPress){
				if (note.isSustainNote){
					if (holdArray[note.noteData] && note.strumTime < Conductor.songPosition+Conductor.safeZoneOffset){
						noteHit(note);
					}
				}else{
					if (controlArray[note.noteData]&& note.strumTime < Conductor.songPosition+Conductor.safeZoneOffset){
						noteHit(note);
					}
				}
				boyfriend.holdTimer=0;
			}
		
		}
		
		*/
/**/
		if(ScoreUtils.botPlay){
			for(note in hittableNotes){
				if(note.mustPress && note.canBeHit && note.strumTime<=Conductor.songPosition){
					if(note.sustainLength>0 && botplayHoldMaxTimes[note.noteData]<note.sustainLength){
						controlArray[note.noteData]=true;
						botplayHoldTimes[note.noteData] = (note.sustainLength/1000)+.2;
					}else if(note.isSustainNote && botplayHoldMaxTimes[note.noteData]==0){
						holdArray[note.noteData] = true;
					}
					if(!note.isSustainNote){
						controlArray[note.noteData]=true;
						if(botplayHoldTimes[note.noteData]<=.2){
							botplayHoldTimes[note.noteData] = .2;
						}
					}
							boyfriend.holdTimer=0;
				}
			}
			for(idx in 0...botplayHoldTimes.length){
				if(botplayHoldTimes[idx]>0){
					holdArray[idx]=true;
					botplayHoldTimes[idx]-=FlxG.elapsed;
				}
			}
		}

		if(holdArray.contains(true)){
			for(idx in 0...holdArray.length){
				var isHeld = holdArray[idx];
				if(isHeld){
					for(daNote in susNoteLanes[idx]){
						if(daNote.isSustainNote && daNote.canBeHit && !daNote.wasGoodHit){
							noteHit(daNote);
						}
					}
				}
			}
		}

		var hitSomething=false;
		// probably a naive way but idc
		if(controlArray.contains(true)){
			for(idx in 0...controlArray.length){
				var pressed = controlArray[idx];
				if(pressed){
					var nextHit = noteLanes[idx][0];
					if(nextHit!=null){
						if(nextHit.canBeHit && !nextHit.wasGoodHit){
							hitSomething=true;
							boyfriend.holdTimer=0;
							noteHit(nextHit);
						}
					}
				}
			}
			if(!hitSomething && currentOptions.ghosttapping==false){
				badNoteCheck();
			}
		}

		// CLEAN UP ANY STACKED NOTES!!
		for(lane in noteLanes){
			var what = [];
			for(idx in 0...lane.length){
				var c = lane[idx];
				var n = lane[idx+1];
				if(n!=null && c!=null){
					if(Math.abs(n.strumTime-c.strumTime)<10)
						what.push(n);
				}
			}

			for(daNote in what){
				daNote.kill();
				renderedNotes.remove(daNote,true);
				lane.remove(daNote);
				hittableNotes.remove(daNote);
				daNote.destroy();
			};
		}
/**/
		var bfVar:Float=4;
		if(boyfriend.curCharacter=='dad')
			bfVar=6.1;

		if (boyfriend.holdTimer > Conductor.stepCrochet * bfVar * 0.001 && !up && !down && !right && !left)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance(bfaltAnim);
			}
		}


		playerStrums.forEach(function(spr:FlxSprite)
		{
				spr.centerOrigin();
			if(controlArray[spr.ID] && spr.animation.curAnim.name!="confirm")
				spr.animation.play("pressed");

			if(!holdArray[spr.ID]){
				spr.animation.play("static");
			}
			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
			}
			else
				spr.centerOffsets();
		});

	}

	private function oldKeyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var holdArray:Array<Bool> = [left,down,up,right];
		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		if((left || right || up || down) && generatedMusic ){
			var hitting=[];
			for(daNote in hittableNotes){
				if(daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData]){
					noteHit(daNote);
				}
			};

		};

		if ((upP || rightP || downP || leftP) && generatedMusic)
			{
				boyfriend.holdTimer=0;
				var possibleNotes:Array<Note> = [];
				var ignoreList = [];
				var what = [];
				for(daNote in hittableNotes){
					if(daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote){
						if(ignoreList.contains(daNote.noteData)){
							for(note in possibleNotes){
								if(note.noteData==daNote.noteData && Math.abs(daNote.strumTime-note.strumTime)<10){
									what.push(daNote);
								}else if(note.noteData==daNote.noteData && daNote.strumTime<note.strumTime){
									possibleNotes.remove(note);
									possibleNotes.push(daNote);
								}
							}
						}else{
							possibleNotes.push(daNote);
							ignoreList.push(daNote.noteData);
						};
					};
				};

				for(daNote in what){
					daNote.kill();
					renderedNotes.remove(daNote,true);
					noteLanes[daNote.noteData].remove(daNote);
					hittableNotes.remove(daNote);
					daNote.destroy();
				};

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if(perfectMode){
					noteHit(possibleNotes[0]);
				}else if(possibleNotes.length>0){
					for (idx in 0...controlArray.length){
						var pressed = controlArray[idx];
						if(pressed && ignoreList.contains(idx)==false && currentOptions.ghosttapping==false )
							badNoteCheck();
					}
					for (daNote in possibleNotes){
						trace(daNote.strumTime);
						if(controlArray[daNote.noteData])
							noteHit(daNote);
					};
				}else{
					if(currentOptions.ghosttapping==false){
						badNoteCheck();
					}
				};
				}

			var bfVar:Float=4;
			if(boyfriend.curCharacter=='dad')
				bfVar=6.1;

			if (boyfriend.holdTimer > Conductor.stepCrochet * bfVar * 0.001 && !up && !down && !right && !left)
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.dance(bfaltAnim);
				}
			}


			playerStrums.forEach(function(spr:FlxSprite)
			{
				if(controlArray[spr.ID] && spr.animation.curAnim.name!="confirm")
					spr.animation.play("pressed");

				if(!holdArray[spr.ID]){
					spr.animation.play("static");
				}
				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
	}


	function noteMiss(direction:Int = 1):Void
	{
		boyfriend.holding=false;
		misses++;
		health -= 0.04;
		previousHealth=health;
		if(luaModchartExists && lua!=null)
		if (combo > 5 && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad');
		}
		combo = 0;

		songScore -= 10;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.3, 0.6));
		// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
		// FlxG.log.add('played imss note');

		/*boyfriend.stunned = true;

		// get stunned for 5 seconds
		new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
		{
			boyfriend.stunned = false;
		});*/

		switch (direction)
		{
			case 0:
				boyfriend.playAnim('singLEFTmiss', true);
			case 1:
				boyfriend.playAnim('singDOWNmiss', true);
			case 2:
				boyfriend.playAnim('singUPmiss', true);
			case 3:
				boyfriend.playAnim('singRIGHTmiss', true);
		}

		updateAccuracy();

	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			//badNoteCheck();
		}
	}

	function noteHit(note:Note):Void
	{
		if (!note.wasGoodHit){
			switch(note.noteType){
				case 0:
					goodNoteHit(note);
				default:
					goodNoteHit(note);
			}
			note.wasGoodHit=true;
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			if (!note.isSustainNote)
			{
				note.kill();
				if(note.mustPress)
					noteLanes[note.noteData].remove(note);
				hittableNotes.remove(note);
				renderedNotes.remove(note, true);
				note.destroy();
			}else if(note.mustPress){
				susNoteLanes[note.noteData].remove(note);
			}
		}

	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.isSustainNote)
		{
			combo++;
			var noteDiff:Float = Math.abs(Conductor.songPosition - note.strumTime);
			popUpScore(noteDiff);
			if(combo>highestCombo)
				highestCombo=combo;

			highComboTxt.text = "Highest Combo: " + highestCombo;
		}else{
			hitNotes++;
			totalNotes++;
		}

		if(currentOptions.hitSound && !note.isSustainNote)
			FlxG.sound.play(Paths.sound('Normal_Hit'),1);

		var strumLine = playerStrumLines.members[note.noteData%4];


		if(luaModchartExists && lua!=null){
			lua.call("goodNoteHit",[note.noteData,note.strumTime,Conductor.songPosition,note.isSustainNote,note.noteType]); // TODO: Note lua class???
		}


		if (note.noteData >= 0)
			health += 0.023;
		else
			health += 0.004;

		previousHealth=health;

						var altAnim:String = bfaltAnim;
		//if(!note.isSustainNote){
		var anim = "";
		switch (note.noteData)
		{
		case 0:
			anim='singLEFT'+bfaltAnim;
		case 1:
			anim='singDOWN'+bfaltAnim;
		case 2:
			anim='singUP'+bfaltAnim;
		case 3:
			anim='singRIGHT'+bfaltAnim;
		}
							if(!note.noAnim){


		var canHold = note.isSustainNote && boyfriend.animation.getByName(anim+"Hold")!=null;
		if(canHold && !boyfriend.animation.curAnim.name.startsWith(anim)){
			boyfriend.playAnim(anim,true);
		}else if(currentOptions.pauseHoldAnims && !canHold){
			boyfriend.playAnim(anim,true);
			if(note.holdParent ){
				//trace("BF HOLDING",note.holdParent,note.isSustainNote,note.animation.curAnim.name);
				boyfriend.holding=true;
			}else{
				boyfriend.holding=false;
			}


		}else if(!currentOptions.pauseHoldAnims && !canHold){
			boyfriend.playAnim(anim,true);
		}

							}
		//}
		vocals.volume = 1;
		updateAccuracy();

	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		trainSound.play(true,0);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			if(currentOptions.picoCamshake)
				camGame.shake(.0025,.1,null,true,X);

			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}
	var lastStepHit = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition -currentOptions.noteOffset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition -currentOptions.noteOffset)) > 20)){
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}
		
		lastStepHit = curStep;
		
		if(luaModchartExists && lua!=null){
			lua.setGlobalVar("curStep",curStep);
			lua.call("stepHit",[curStep]);
		}
			
		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
		
		
		
		
		
		
		if (curStage == 'ponyville'){
			
			
			
		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			var curSec = Math.floor(curStep / 16);
			if (SONG.song.toLowerCase() == "fun"){
				if(curSec >= 48 && curSec < 56 || curSec >= 58 && curSec < 64 || curSec >= 80 && curSec < 84){
					switch(curStep % 32){
						case 0 | 1 | 6 | 7 | 12 | 13 | 20 | 21 | 22 | 26 | 27 | 28:
							FlxG.camera.shake(0.003);
							beatCam(0.015,0.015);
							beatCam(0.015,0.015);
							beatCam(0.015,0.015);
					}
				}
				if (curSec == 57){
					switch(curBeat % 4){
						case 2 | 3:
							FlxG.camera.shake(0.003);
							beatCam(0.015,0.015);
							beatCam(0.015,0.015);
							beatCam(0.015,0.015);
							beatCam(0.015,0.015);
					}
				}
			}
		}
			
			switch (beattype){
				case "porche":
					var f = curStep % 4;
					ponybg.animation.play(beattype, true, false, f);
				case "trap":
					var b = curBeat % 2 == 0;
					if(b) ponybg.animation.play(beattype, false, false);
				case "polka":
					var f = curStep % 8;
					ponybg.animation.play(beattype, true, false, Std.int(f/2));
			}
			
			
			if (curBeat == scootdrive){
				getSpr('scoot').velocity.x = -1000;
			}
			
			
			
		}
		
		
			if (curSong.toLowerCase() == "smile-hd"){
				
				switch(curStep){
					case 782:
						modchart.opponentHPDrain = 0.02;
						iconP2.shake = 5;
						meter();
					case 992:
						dashCam();
					case 1034:
						modchart.opponentHPDrain = 0;
						iconP2.shake = 0;
						getSpr('pinkieGlow').visible = false;
						kickcutscene();
				}
			}
		
			//if (camStep.contains(curStep)){
			//}
		
		
	}

	public function beatCam(z1:Float=0.015,z2:Float = 0.03){
		FlxG.camera.zoom +=  z1;
		camHUD.zoom += z2;
		
		
		//if (camZoomTween != null) camZoomTween.cancel();
		//if (camBoomTween != null) camZoomTween.cancel();
		
		//camZoomTween = FlxTween.tween(FlxG.camera, {zoom:defaultCamZoom}, Conductor.crochet/1000,{ease:FlxEase.circOut});
		//camBoomTween = FlxTween.tween(camHUD, {zoom:defaultHudZoom}, Conductor.crochet/1000,{ease:FlxEase.circOut});
	}
	
	
	public function setSpr(name:String,sprite:FlxSprite):FlxSprite{
		
		theSprites.set(name, sprite);
		
		
		return theSprites.get(name);
	}
	public function getSpr(name:String):FlxSprite{
		
		return theSprites.get(name);
	}
	public function addSprite(x,y,path:String,scrollFactor:Float=1):FlxSprite{
		var sprite:FlxSprite = new FlxSprite(x, y).loadGraphic(Paths.image(path));
		sprite.scrollFactor.set(scrollFactor, scrollFactor);
		sprite.active = false;
		sprite.antialiasing = true;
		instance.add(sprite);
		return sprite;
	}
	public function addAnimPrefix(x,y,path:String,prefix:String,scrollFactor:Float=1,loop:Bool=true,fps:Int=24):FlxSprite{
		var sprite:FlxSprite = new FlxSprite(x, y);
		sprite.frames = Paths.getSparrowAtlas(path);
		sprite.animation.addByPrefix(prefix,prefix,fps,loop);
		sprite.animation.play(prefix);
		sprite.antialiasing = true;
		sprite.scrollFactor.set(scrollFactor, scrollFactor);
		instance.add(sprite);
		return sprite;
	}
	public function addAnimIndices(x,y,path:String,prefix:String,indices:Array<Int>,scrollFactor:Float=1,loop:Bool=true,fps:Int=24):FlxSprite{
		var sprite:FlxSprite = new FlxSprite(x, y);
		sprite.frames = Paths.getSparrowAtlas(path);
		sprite.animation.addByIndices(prefix, prefix, indices, "", fps,loop);
		sprite.animation.play(prefix);
		sprite.antialiasing = true;
		sprite.scrollFactor.set(scrollFactor, scrollFactor);
		instance.add(sprite);
		return sprite;
	}
	
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var lastBeatHit = -1;
	override function beatHit()
	{
		super.beatHit();

		if(curBeat == lastBeatHit) {
			return;
		}
		
		lastBeatHit = curBeat;
		
		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			
			//if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection){
				cameraShits(PlayState.SONG.notes[Std.int(curBeat / 4)].mustHitSection);
			//}
			
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
				if(luaModchartExists && lua!=null){
					lua.setGlobalVar("bpm",Conductor.bpm);
				}
			}
			
			
			
			
			
			
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (!dad.animation.curAnim.name.startsWith("sing") && !dad.animation.curAnim.name.startsWith("h")&& !dad.animation.curAnim.name.startsWith("w") )
				if(!dad.unintAnims.contains(dad.animation.curAnim.name))dad.dance(dadaltAnim);

		}
		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % camBoomSpeed == 0)
		{
				beatCam();
		}
		
		if (SONG.song.toLowerCase() == "smile"){
			switch(curBeat){
				case 37:
					dad.playAnim("howdy");
				case 44:
					dad.playAnim("howyadoin");
				case 69:
					boyfriend.playAnim("hey");
				case 155:
					dad.playAnim("whatsup");
				case 181:
					dad.playAnim("hello");
				case 300:
					  getSpr('pony1').visible = false;
					  getSpr('pony2').visible = false;
					  getSpr('pony3').visible = false;
					  getSpr('pony4').visible = false;
					  getSpr('pony5').visible = false;
				case 361:
					  getSpr('pony1').visible = true;
					  getSpr('pony2').visible = true;
					  getSpr('pony3').visible = true;
					  getSpr('pony4').visible = true;
					  getSpr('pony5').visible = true;
				case 183:
					dad.dance(dadaltAnim);
			}
		}
			if (curSong.toLowerCase() == "fun"){
				
				switch(curBeat){
					case 0:
						beattype = "polka";
					case 64:
						beattype = "porche";
				}
			}
			if (curSong.toLowerCase() == "discord"){
				
				switch(curBeat){
					case 552:
						
						  getSpr('pinkie').alpha = 1;
						  getSpr('twi').alpha = 1;
						  getSpr('twi').animation.play('twi_end',true,false,10);
						  getSpr('aj').alpha = 1;
						  
						  getSpr('flutter').alpha = 1;
						  getSpr('rarity').alpha = 1;
						  getSpr('dash').alpha = 1;
						  FlxTween.tween(camHUD, {alpha:0}, 0.4);
					case 288:
						PlayState.instance.getSpr('disc_hey').alpha = 0.001;
					case 554:
						
						  setCamPos(2325, 296);
						  
						  
					case 567:
						
						  getSpr('pinkie').animation.curAnim.curFrame = 1;
						  getSpr('aj').animation.curAnim.curFrame = 1;
						  
						  getSpr('flutter').animation.curAnim.curFrame = 1;
						  getSpr('rarity').animation.curAnim.curFrame = 1;
						  getSpr('dash').animation.curAnim.curFrame = 1;
					case 569:
						
						  getSpr('pinkie').animation.curAnim.curFrame = 2;
						  getSpr('aj').animation.curAnim.curFrame = 2;
						  
						  getSpr('flutter').animation.curAnim.curFrame = 2;
						  getSpr('rarity').animation.curAnim.curFrame = 2;
						  getSpr('dash').animation.curAnim.curFrame = 2;
						  
						  var p = ['pinkie', 'aj', 'rarity', 'dash', 'flutter', 'twi'];
						  
						  for (u in p){
							 FlxTween.tween(getSpr(u), {y:getSpr(u).y - 240}, 3, {ease:FlxEase.sineInOut});
						  }
							 FlxTween.tween(camGame.scroll, {y:56.05}, 1, {ease:FlxEase.sineInOut});
						  
						  
					case 573:
						  setCamPos(9999,9999,true);
					case 580:
						  getSpr('rainbowsss').visible = true;
					case 594:
						  getSpr('rainbowsss').visible = false;
					
				}
			}
		
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}


		//iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		//iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		//iconP1.updateHitbox();
		//iconP2.updateHitbox();
		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);
		if (curBeat % gfSpeed == 0)
		{
			gf.dance(gfaltAnim);
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && !boyfriend.animation.curAnim.name.startsWith("hey"))
		{
			if(!boyfriend.disabledDance)boyfriend.dance(bfaltAnim);
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		/*if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}*/

		if(luaModchartExists && lua!=null){
			lua.setGlobalVar("curBeat",curBeat);
			lua.call("beatHit",[curBeat]);
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
					if(currentOptions.picoShaders && lightFadeShader!=null)
						lightFadeShader.setAlpha(0);
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	function getGroupStuff(leArray:Dynamic, variable:String) {
		var killMe:Array<String> = variable.split('.');
		if(killMe.length > 1) {
			var coverMeInPiss:Dynamic = Reflect.getProperty(leArray, killMe[0]);
			for (i in 1...killMe.length-1) {
				coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
			}
			return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
		}
		return Reflect.getProperty(leArray, variable);
	}

	function setGroupStuff(leArray:Dynamic, variable:String, value:Dynamic) {
		var killMe:Array<String> = variable.split('.');
		if(killMe.length > 1) {
			var coverMeInPiss:Dynamic = Reflect.getProperty(leArray, killMe[0]);
			for (i in 1...killMe.length-1) {
				coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
			}
			Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
			return;
		}
		Reflect.setProperty(leArray, variable, value);
	}
	var curLight:Int = 0;
}
