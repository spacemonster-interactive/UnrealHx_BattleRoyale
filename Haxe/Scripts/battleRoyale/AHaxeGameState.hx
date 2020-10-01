package battleRoyale;

import unreal.*;

using unreal.CoreAPI;

// DECLARE_DYNAMIC_MULTICAST_DELEGATE(FWinnerFoundDelegate);
typedef FWinnerFoundDelegate = DynamicMulticastDelegate<FWinnerFoundDelegate, Void->Void>;

// TODO: work out

@:uclass
class AHaxeGameState extends AGameStateBase {
	// @:uproperty(ReplicatedUsing = OnRep_Winner, Transient, BlueprintReadOnly, Category = "Game State")
	// @:ureplicate(OnRep_Winner)
	@:uproperty(ReplicatedUsing = OnRep_Winner, Transient, BlueprintReadOnly, Category = "Game State")
	// @:ureplicate(OnRep_Winner)
	@:ureplicate
	public var Winner:AHaxePlayerState;

	// @:ureplicate
	@:uproperty(BlueprintAssignable, Category = "Game State")
	public var OnWinnerFound:FWinnerFoundDelegate;

	public function new(wrapped) {
		super(wrapped);
		trace("New2");
	}

	override function BeginPlay() {
		// Call the base class
		super.BeginPlay();
		trace("BeginPlay");
		// OnWinnerFound.AddDynamic(this, OnHit);
		OnWinnerFound.AddDynamic(this, TestTrigger);
	}

	/*
		@:ufunction(Server, Reliable)
		public function ServerTestTrigger():Void;

		@:uexpose public function ServerTestTrigger_Implementation():Void {
			trace("ServerShootBullet_Implementation");
			TestTrigger();
		}

		@:ufunction()
		function TestTrigger() {
			trace(HasAuthority());
			if (!HasAuthority()) {
				trace("TestTrigger");
				ServerTestTrigger();
				return;
			} else {
				trace("TestTrigger HasAuthority");
			}
		}
	 */
	@:uexpose
	@:ufunction()
	function TestTrigger() {
		trace("TestTrigger");
	}

	@:ufunction()
	function OnRep_Winner() {
		trace("OnRep_Winner2");
		// It seems like replicate isn't working
		OnWinnerFound.Broadcast();
	}

	// override function GetLifetimeReplicatedProps(OutLLifetimeProps:Array<FLifetimeProperty>) {
	// @:glueCppIncludes("UObject/NoExportTypes.h", "uhx/Wrapper.h", "Containers/Array.h", "UObject/Object.h", "uhx/glues/TArrayImpl_Glue_UE.h")
	// @:glueHeaderIncludes("IntPtr.h", "VariantPtr.h")
	// @:glueHeaderCode("static void GetLifetimeReplicatedProps(unreal::UIntPtr self, unreal::VariantPtr outLifetimeProps);")
	// @:glueCppCode("void uhx::glues::UObject_Glue_obj::GetLifetimeReplicatedProps(unreal::UIntPtr self, unreal::VariantPtr outLifetimeProps) {\n\t( (UObject *) self )->GetLifetimeReplicatedProps(*::uhx::TemplateHelper< TArray<FLifetimeProperty> >::getPointer(outLifetimeProps));\n}")
	// #if (!UHX_DISPLAY && cppia && !LIVE_RELOAD_BUILD)
	// @:deprecated("UHXERR: The field GetLifetimeReplicatedProps was not compiled into the latest C++ compilation. Please perform a full C++ compilation.")
	// #end
	// override public function GetLifetimeReplicatedProps(outLifetimeProps:unreal.PRef<unreal.TArray<unreal.FLifetimeProperty>>):Void {
	//	super.GetLifetimeReplicatedProps(outLifetimeProps);
	// DOREPLIDETIME(AHaxeGameState, Winner);
	// TODO: work out rep
	// }
}
