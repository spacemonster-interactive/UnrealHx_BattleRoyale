package battleRoyale;

import unreal.inputcore.*;
import unreal.headmounteddisplay.*;
import unreal.*;

@:uclass(Abstract)
class AHaxeCharacter extends ACharacter {
	/** Base turn rate, in deg/sec. Other scaling may affect final turn rate. */
	@:uproperty(VisibleAnywhere, BlueprintReadOnly, Category = Camera)
	public var BaseTurnRate:Float32;

	/** Base look up/down rate, in deg/sec. Other scaling may affect final rate. */
	@:uproperty(VisibleAnywhere, BlueprintReadOnly, Category = Camera)
	public var BaseLookUpRate:Float32;

	/** Gun muzzle's offset from the characters location */
	@:uproperty(EditAnywhere, BlueprintReadWrite, Category = Gameplay)
	public var GunOffset:FVector;

	/** Projectile class to spawn */
	@:uproperty(EditDefaultsOnly, Category = Projectile)
	public var ProjectileClass:TSubclassOf<AHaxeProjectile>;

	/** Sound to play each time we fire */
	@:uproperty(EditAnywhere, BlueprintReadWrite, Category = Gameplay)
	public var FireSound:USoundBase;

	/** AnimMontage to play each time we fire */
	@:uproperty(EditAnywhere, BlueprintReadWrite, Category = Gameplay)
	public var FireAnimation:UAnimMontage;

	/** Whether to use motion controller location for aiming. */
	@:uproperty(EditAnywhere, BlueprintReadWrite, Category = Gameplay)
	public var bUsingMotionControllers:Bool;

	/** Pawn mesh: 1st person view (arms; seen only by self) */
	@:uproperty(VisibleDefaultsOnly, Category = Mesh)
	var Mesh1P:USkeletalMeshComponent;

	/** Gun mesh: 1st person view (seen only by self) */
	@:uproperty(VisibleDefaultsOnly, Category = Mesh)
	var FP_Gun:USkeletalMeshComponent;

	/** Location on gun mesh where projectiles should spawn. */
	@:uproperty(VisibleDefaultsOnly, Category = Mesh)
	var FP_MuzzleLocation:USceneComponent;

	/** Gun mesh: VR view (attached to the VR controller directly, no arm, just the actual gun) */
	@:uproperty(VisibleDefaultsOnly, Category = Mesh)
	var VR_Gun:USkeletalMeshComponent;

	/** Location on VR gun mesh where projectiles should spawn. */
	@:uproperty(VisibleDefaultsOnly, Category = Mesh)
	var VR_MuzzleLocation:USceneComponent;

	/** First person camera */
	@:uproperty(VisibleAnywhere, BlueprintReadOnly, Category = Camera, meta = (AllowPrivateAccess = "true"))
	var FirstPersonCameraComponent:UCameraComponent;

	/** Motion controller (right hand) */
	@:uproperty(VisibleAnywhere, BlueprintReadOnly, meta = (AllowPrivateAccess = "true"))
	var R_MotionController:UMotionControllerComponent;

	/** Motion controller (left hand) */
	@:uproperty(VisibleAnywhere, BlueprintReadOnly, meta = (AllowPrivateAccess = "true"))
	var L_MotionController:UMotionControllerComponent;

	@:uproperty(ReplicatedUsing = OnRep_Killer, BlueprintReadOnly, Category = Gameplay)
	// @:ureplicate(OnRep_Killer)
	@:ureplicate
	public var Killer:AHaxeCharacter;

	public function new(wrapped) {
		super(wrapped);

		// Set size for collision capsule
		// GetCapsuleComponent().InitCapsuleSize(55.0, 96.0);
		var CapsuleComponent = GetCapsuleComponent();
		CapsuleComponent.SetCapsuleSize(55.0, 96.0);

		// set our turn rates for input
		BaseTurnRate = 45.0;
		BaseLookUpRate = 45.0;

		// Create a CameraComponent

		var Init = FObjectInitializer.Get();
		FirstPersonCameraComponent = Init.CreateDefaultSubobject(new TypeParam<UCameraComponent>(), this, "FirstPersonCamera", UCameraComponent.StaticClass());
		FirstPersonCameraComponent.SetupAttachment(GetCapsuleComponent());
		FirstPersonCameraComponent.RelativeLocation = new FVector(-39.56, 1.75, 64.0); // Position the camera
		FirstPersonCameraComponent.bUsePawnControlRotation = true;

		// Create a mesh component that will be used when being viewed from a '1st person' view (when controlling this pawn)
		Mesh1P = Init.CreateDefaultSubobject(new TypeParam<USkeletalMeshComponent>(), this, "CharacterMesh1P", USkeletalMeshComponent.StaticClass());
		Mesh1P.SetOnlyOwnerSee(true);
		Mesh1P.SetupAttachment(FirstPersonCameraComponent);
		Mesh1P.bCastDynamicShadow = false;
		Mesh1P.CastShadow = false;
		Mesh1P.RelativeRotation = FRotator.createWithValues(1.9, -19.19, 5.2);
		Mesh1P.RelativeLocation = new FVector(-0.5, -4.4, -155.7);

		// Create a gun mesh component
		FP_Gun = Init.CreateDefaultSubobject(new TypeParam<USkeletalMeshComponent>(), this, "FP_Gun", USkeletalMeshComponent.StaticClass());
		FP_Gun.SetOnlyOwnerSee(true); // only the owning player will see this mesh
		FP_Gun.bCastDynamicShadow = false;
		FP_Gun.CastShadow = false;
		FP_Gun.SetupAttachment(RootComponent);

		FP_MuzzleLocation = Init.CreateDefaultSubobject(new TypeParam<USceneComponent>(), this, "MuzzleLocation", USceneComponent.StaticClass());
		FP_MuzzleLocation.SetupAttachment(FP_Gun);
		FP_MuzzleLocation.SetRelativeLocation(new FVector(0.2, 48.4, -10.6), false, null, None);

		// Default offset from the character location for projectiles to spawn
		GunOffset = new FVector(100.0, 0.0, 10.0);

		// Note: The ProjectileClass and the skeletal mesh/anim blueprints for Mesh1P, FP_Gun, and VR_Gun
		// are set in the derived blueprint asset named MyCharacter to avoid direct content references in C++.

		// Create VR Controllers.
		R_MotionController = Init.CreateDefaultSubobject(new TypeParam<UMotionControllerComponent>(), this, "R_MotionController",
			UMotionControllerComponent.StaticClass());
		// R_MotionController.MotionSource = FXRMotionControllerBase.RightHandSourceId;
		R_MotionController.SetupAttachment(RootComponent);
		L_MotionController = Init.CreateDefaultSubobject(new TypeParam<UMotionControllerComponent>(), this, "L_MotionController",
			UMotionControllerComponent.StaticClass());
		L_MotionController.SetupAttachment(RootComponent);

		// Create a gun and attach it to the right-hand VR controller.
		// Create a gun mesh component
		VR_Gun = Init.CreateDefaultSubobject(new TypeParam<USkeletalMeshComponent>(), this, "VR_Gun", USkeletalMeshComponent.StaticClass());
		VR_Gun.SetOnlyOwnerSee(true); // only the owning player will see this mesh
		VR_Gun.bCastDynamicShadow = false;
		VR_Gun.CastShadow = false;
		VR_Gun.SetupAttachment(R_MotionController);
		VR_Gun.K2_SetRelativeRotation(FRotator.createWithValues(0.0, -90.0, 0.0), false, null, false);

		VR_MuzzleLocation = Init.CreateDefaultSubobject(new TypeParam<USceneComponent>(), this, "VR_MuzzleLocation", USceneComponent.StaticClass());
		VR_MuzzleLocation.SetupAttachment(VR_Gun);
		VR_MuzzleLocation.SetRelativeLocation(new FVector(0.000004, 53.999992, 10.000000), false, null, None);
		VR_MuzzleLocation.K2_SetRelativeRotation(FRotator.createWithValues(0.0, 90.0, 0.0), false, null,
			false); // Counteract the rotation of the VR gun model.

		// Uncomment the following line to turn motion controllers on by default:
		// bUsingMotionControllers = true;
	}

	override function BeginPlay() {
		// Call the base class
		super.BeginPlay();

		// Attach gun mesh component to Skeleton, doing it here because the skeleton is not yet created in the constructor
		// FP_Gun.AttachToComponent(Mesh1P, FAttachmentTransformRules(EAttachmentRule.SnapToTarget, true), TEXT("GripPoint"));
		FP_Gun.K2_AttachToComponent(Mesh1P, "GripPoint", EAttachmentRule.SnapToTarget, EAttachmentRule.SnapToTarget, EAttachmentRule.SnapToTarget, true);
		// Show or hide the two versions of the gun based on whether or not we're using motion controllers.
		if (bUsingMotionControllers) {
			VR_Gun.SetHiddenInGame(false, true);
			Mesh1P.SetHiddenInGame(true, true);
		} else {
			VR_Gun.SetHiddenInGame(true, true);
			Mesh1P.SetHiddenInGame(false, true);
		}
	}

	//////////////////////////////////////////////////////////////////////////
	// Input

	override function SetupPlayerInputComponent(PlayerInputComponent:UInputComponent) {
		// set up gameplay key bindings
		// check(PlayerInputComponent);

		// Bind jump events
		PlayerInputComponent.BindAction("Jump", IE_Pressed, this, MethodPointer.fromMethod(Jump));
		PlayerInputComponent.BindAction("Jump", IE_Released, this, MethodPointer.fromMethod(StopJumping));

		// Bind fire event
		PlayerInputComponent.BindAction("Fire", IE_Pressed, this, MethodPointer.fromMethod(OnFire));

		// Enable touchscreen input
		// EnableTouchscreenMovement(PlayerInputComponent);

		PlayerInputComponent.BindAction("ResetVR", IE_Pressed, this, MethodPointer.fromMethod(OnResetVR));

		// Bind movement events
		PlayerInputComponent.BindAxis("MoveForward", this, MoveForward);
		PlayerInputComponent.BindAxis("MoveRight", this, MoveRight);

		// We have 2 versions of the rotation bindings to handle different kinds of devices differently
		// "turn" handles devices that provide an absolute delta, such as a mouse.
		// "turnrate" is for devices that we choose to treat as a rate of change, such as an analog joystick
		PlayerInputComponent.BindAxis("Turn", this, AddControllerYawInput);
		PlayerInputComponent.BindAxis("TurnRate", this, TurnAtRate);
		PlayerInputComponent.BindAxis("LookUp", this, AddControllerPitchInput);
		PlayerInputComponent.BindAxis("LookUpRate", this, LookUpAtRate);
	}

	@:ufunction(Server, Reliable)
	public function ServerOnFire():Void;

	@:uexpose public function ServerOnFire_Implementation():Void {
		trace("ServerShootBullet_Implementation");
		OnFire();
	}

	@:uexpose function OnFire() {
		if (!HasAuthority()) {
			trace("OnFire");
			trace(FireSound);
			// try and play the sound if specified
			if (FireSound != null) {
				UGameplayStatics.PlaySoundAtLocation(this, FireSound, GetActorLocation(), GetActorRotation());
			}

			// try and play a firing animation if specified
			if (FireAnimation != null) {
				// Get the animation object for the arms mesh
				var AnimInstance:UAnimInstance = Mesh1P.GetAnimInstance();
				if (AnimInstance != null) {
					AnimInstance.Montage_Play(FireAnimation, 1.0);
				}
			}
			// we are not the server
			trace("we are not the server, 1");
			ServerOnFire();
			return;
		} else {
			trace("OnFire from server");
			// try and fire a projectile
			if (ProjectileClass == null) {
				trace("ProjectileClass hasn't been set, do this in BP_HaxeCharacter Blueprints");
			} else {
				var World:UWorld = GetWorld();
				if (World != null) {
					if (bUsingMotionControllers) {
						var SpawnRotation:FRotator = VR_MuzzleLocation.GetComponentRotation();
						var SpawnLocation:FVector = VR_MuzzleLocation.GetComponentLocation();
						var Params:FActorSpawnParameters = FActorSpawnParameters.create();
						World.SpawnActor(ProjectileClass, SpawnLocation, SpawnRotation, Params);
					} else {
						var SpawnRotation:FRotator = GetControlRotation();
						// MuzzleOffset is in camera space, so transform it to world space before offsetting from the character location to find the final muzzle position
						var SpawnLocation:FVector = ((FP_MuzzleLocation != null) ? FP_MuzzleLocation.GetComponentLocation() : GetActorLocation())
							+ SpawnRotation.RotateVector(GunOffset);

						// Set Spawn Collision Handling Override
						var ActorSpawnParams:FActorSpawnParameters = FActorSpawnParameters.create();
						ActorSpawnParams.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButDontSpawnIfColliding;
						ActorSpawnParams.Owner = this;

						// spawn the projectile at the muzzle
						// World.SpawnActor<AHaxeProjectile>(ProjectileClass, SpawnLocation, SpawnRotation, ActorSpawnParams);
						World.SpawnActor(ProjectileClass, SpawnLocation, SpawnRotation, ActorSpawnParams);
					}
				}
			}
		}
	}

	@:uexpose override public function Jump():Void {
		super.Jump();
	}

	@:uexpose override public function StopJumping():Void {
		super.StopJumping();
	}

	@:uexpose function OnResetVR() {
		UHeadMountedDisplayFunctionLibrary.ResetOrientationAndPosition();
	}

	/*function BeginTouch(FingerIndex:ETouchIndex, Location:FVector) {
		if (TouchItem.bIsPressed == true) {
			return;
		}
		if ((FingerIndex == TouchItem.FingerIndex) && (TouchItem.bMoved == false)) {
			OnFire();
		}
		TouchItem.bIsPressed = true;
		TouchItem.FingerIndex = FingerIndex;
		TouchItem.Location = Location;
		TouchItem.bMoved = false;
	}*/
	/*function EndTouch(FingerIndex:ETouchIndex, Location:FVector) {
		if (TouchItem.bIsPressed == false) {
			return;
		}
		TouchItem.bIsPressed = false;
	}*/
	@:uexpose function MoveForward(Value:Float32) {
		if (Value != 0.0) {
			// add movement in that direction
			AddMovementInput(GetActorForwardVector(), Value);
		}
	}

	@:uexpose function MoveRight(Value:Float32) {
		if (Value != 0.0) {
			// add movement in that direction
			AddMovementInput(GetActorRightVector(), Value);
		}
	}

	@:uexpose override public function AddControllerYawInput(Rate:Float32):Void {
		super.AddControllerYawInput(Rate);
	}

	@:uexpose function TurnAtRate(Rate:Float32) {
		// calculate delta for this frame from the rate information
		AddControllerYawInput(Rate * BaseTurnRate * GetWorld().GetDeltaSeconds());
	}

	@:uexpose override public function AddControllerPitchInput(Rate:Float32):Void {
		super.AddControllerPitchInput(Rate);
	}

	@:uexpose function LookUpAtRate(Rate:Float32) {
		// calculate delta for this frame from the rate information
		AddControllerPitchInput(Rate * BaseLookUpRate * GetWorld().GetDeltaSeconds());
	}

	/*function EnableTouchscreenMovement(PlayerInputComponent:UInputComponent):Bool {
		var DefUInputSettings = UInputSettings.StaticClass().GetDefaultObject(new TypeParam<UInputSettings>());

		//if (FPlatformMisc.SupportsTouchInput() || DefUInputSettings.bUseMouseForTouch) {
		if (DefUInputSettings.bUseMouseForTouch) {
				PlayerInputComponent.BindTouch(IE_Pressed, this, BeginTouch);
			PlayerInputComponent.BindTouch(IE_Released, this, EndTouch);

			// Commenting this out to be more consistent with FPS BP template.
			// PlayerInputComponent.BindTouch(EInputEvent.IE_Repeat, this, TouchUpdate);
			return true;
		}

		return false;
	}*/
	@:ufunction()
	public function OnRep_Killer() {
		var IsLocal = IsLocallyControlled();
		trace("OnRep_Killer: " + IsLocal);
		if (IsLocal) {
			// trace("IsLocallyControlled");
			ShowDeathScreen();
		}
		// trace(Killer);

		GetCapsuleComponent().SetCollisionEnabled(ECollisionEnabled.NoCollision);
		GetMesh().SetSimulatePhysics(true);
		GetMesh().SetCollisionEnabled(ECollisionEnabled.PhysicsOnly);
		GetMesh().SetCollisionResponseToAllChannels(ECR_Block);

		SetLifeSpan(10);
	}

	@:ufunction(BlueprintImplementableEvent)
	public function ShowDeathScreen();

	// override public function GetLifetimeReplicatedProps(outLifetimeProps:unreal.PRef<unreal.TArray<unreal.FLifetimeProperty>>):Void {
	//	super.GetLifetimeReplicatedProps(outLifetimeProps);
	// DOREPLIDETIME(AHaxeCharacter, Killer);
	// TODO: work out rep
	// }
}
