package battleRoyale;

import unreal.*;

using unreal.CoreAPI;

@:uclass
class AHaxeGameMode extends AGameModeBase {
	@:uproperty(EditAnywhere, Category = Character)
	var CharacterClass:TSubclassOf<AHaxeCharacter>;

	@:uproperty(Transient)
	var AlivePlayers:TArray<AHaxePlayerController>;

	public function new(wrapped) {
		super(wrapped);

		PlayerControllerClass = AHaxePlayerController.StaticClass();
		var AHaxeCharacterClass = AHaxeCharacter.StaticClass();
		trace("AHaxeGameMode");
		trace(PlayerControllerClass);
		trace(AHaxeCharacterClass);

		// new FClassFinder("/Game/FirstPersonCPP/Blueprints/BP_HaxeCharacter", AHaxeCharacterClass);
		if (CharacterClass != null) {
			DefaultPawnClass = CharacterClass;
		} else {
			// DefaultPawnClass = AHaxeCharacterClass;
		}

		var Init = FObjectInitializer.Get();
		// var MyWidget:UWidgetComponent = Init.CreateDefaultSubobject(new TypeParam<UWidgetComponent>(), this, "Widget", UWidgetComponent.StaticClass());
		// var MyWidgetClass = new FClassFinder("/Game/HUD/SelectableActorHUD_Widget", UUserWidget);

		// var PlayerPawnClass:FClassFinder = FClassFinder.Find("/Game/FirstPersonCPP/Blueprints/FirstPersonCharacter");
		HUDClass = AHUD.StaticClass();

		// FClassFinder.Find("/Game/FirstPersonCPP/Blueprints/FirstPersonCharacter");
		// FClassFinder.Find("/Game/Pawn/PlayerPawn");
		// var obj = FClassFinderImpl.Find(new TypeParam<UObject>(), "/Game/FirstPersonCPP/Blueprints/FirstPersonCharacter");

		// PlayerControllerClass = PlayerController.StaticClass();
		// var PlayerPawnClass:FClassFinder<APawn> = FClassFinder.Find("/Game/FirstPersonCPP/Blueprints/FirstPersonCharacter");
		// DefaultPawnClass = PlayerPawnClass.Class;
		// HUDClass = AHUD.StaticClass();

		// set default pawn class to our Blueprinted character
		// ConstructorHelpers::FClassFinder<APawn>PlayerPawnClassFinder(TEXT("/Game/FirstPersonCPP/Blueprints/FirstPersonCharacter"));
		// DefaultPawnClass = PlayerPawnClassFinder.Class;

		// use our custom HUD class
		// HUDClass = ABRHUD::StaticClass();
	}

	public function PlayerDied(Killed:AHaxeCharacter, Killer:AHaxeCharacter) {
		trace("PlayerDied");
		if (Killed != null) {
			var PC:AHaxePlayerController = cast Killed.GetController();
			if (PC != null) {
				trace("AlivePlayers.length = " + AlivePlayers.length);
				trace(AlivePlayers.indexOf(PC));
				AlivePlayers.remove(PC);
				trace("AlivePlayers.length = " + AlivePlayers.length);
			}

			if (AlivePlayers.length == 1) {
				trace("Call WinnerFound");
				WinnerFound(cast AlivePlayers[0].PlayerState);
			}
		}
	}

	function WinnerFound(Winner:AHaxePlayerState) {
		trace("WinnerFound");
		// var AuthGameMode:AGameModeBase = GetWorld().GetAuthGameMode();
		// GetWorld().GetGameState()
		var GS:AHaxeGameState = cast get_GameState();
		trace(GS);
		if (GS != null) {
			GS.Winner = Winner;
		}
	}

	// override function PostLogin(NewPlayer:AHaxePlayerController) {
	override public function PostLogin(NewPlayer:unreal.APlayerController):Void {
		super.PostLogin(NewPlayer);
		AlivePlayers.push(cast(NewPlayer, AHaxePlayerController));
	}
}
