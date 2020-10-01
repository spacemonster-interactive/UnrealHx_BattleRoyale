package battleRoyale;

import unreal.*;

using unreal.CoreAPI;

@:uclass(Abstract)
class AHaxeProjectile extends AActor {
	/** Sphere collision component */
	@:uproperty(VisibleDefaultsOnly, Category = Projectile)
	var CollisionComp:USphereComponent;

	/** Projectile movement component */
	@:uproperty(VisibleAnywhere, BlueprintReadOnly, Category = Movement, meta = (AllowPrivateAccess = "true"))
	var ProjectileMovement:UProjectileMovementComponent;

	public function new(wrapped) {
		super(wrapped);

		var Init = FObjectInitializer.Get();

		// Use a sphere as a simple collision representation
		CollisionComp = Init.CreateDefaultSubobject(new TypeParam<USphereComponent>(), this, "SphereComp", USphereComponent.StaticClass());
		CollisionComp.InitSphereRadius(5.0);
		CollisionComp.SetCollisionProfileName("Projectile");
		CollisionComp.OnComponentHit.AddDynamic(this, OnHit); // set up a notification for when this component hits something blocking

		// Players can't walk on it
		// CollisionComp.SetWalkableSlopeOverride(FWalkableSlopeOverride(WalkableSlope_Unwalkable, 0.0));

		CollisionComp.CanCharacterStepUpOn = ECB_No;

		trace("AHaxeProjectile");
		/*
			var ScriptDelegate:FScriptDelegate = new FScriptDelegate();
			ScriptDelegate.BindUFunction(this, "OnHit");
			trace("FunctionName = " + ScriptDelegate.GetFunctionName());
			trace("UObject = " + ScriptDelegate.GetUObject());
			CollisionComp.OnComponentHit.Add(ScriptDelegate);
		 */

		// Set as root component
		RootComponent = CollisionComp;

		// Use a ProjectileMovementComponent to govern this projectile's movement
		ProjectileMovement = Init.CreateDefaultSubobject(new TypeParam<UProjectileMovementComponent>(), this, "ProjectileComp",
			UProjectileMovementComponent.StaticClass());
		ProjectileMovement.UpdatedComponent = CollisionComp;
		ProjectileMovement.InitialSpeed = 3000.0;
		ProjectileMovement.MaxSpeed = 3000.0;
		ProjectileMovement.bRotationFollowsVelocity = true;
		ProjectileMovement.bShouldBounce = true;

		// Die after 3 seconds by default
		InitialLifeSpan = 3.0;

		SetReplicates(true);
		SetReplicateMovement(true);
	}

	override function BeginPlay() {
		super.BeginPlay();

		// trace(CollisionComp);

		// CollisionComp.OnComponentHit.AddDynamic(this, OnHit); // set up a notification for when this component hits something blocking

		// trace("BeginPlay");
	}

	/** called when projectile hits something */
	@:ufunction()
	@:uexpose function OnHit(HitComp:UPrimitiveComponent, OtherActor:AActor, OtherComp:UPrimitiveComponent, NormalImpulse:FVector, Hit:FHitResult) {
		if (HasAuthority()) {
			var otherIsHaxeCharacter:Bool = Std.is(OtherActor, AHaxeCharacter);
			if (otherIsHaxeCharacter) {
				trace("OnHit: " + otherIsHaxeCharacter);

				trace("OtherActor is AHaxeCharacter");
				var HitPlayer:AHaxeCharacter = cast OtherActor;
				if (HitPlayer != null) {
					var AuthGameMode:AGameModeBase = GetWorld().GetAuthGameMode();
					if (Std.is(AuthGameMode, AHaxeGameMode)) {
						trace("AuthGameMode is AHaxeGameMode");
						var GM:AHaxeGameMode = cast AuthGameMode;
						if (GM != null) {
							var Killer:AHaxeCharacter = cast GetOwner();
							GM.PlayerDied(HitPlayer, Killer);

							trace(HitPlayer);
							HitPlayer.Killer = Killer;
							HitPlayer.OnRep_Killer();
						}
					}
				}
			}
		}

		// Only add impulse and destroy projectile if we hit a physics
		/*if ((OtherActor != null) && (OtherActor != this) && (OtherComp != null) && OtherComp.IsSimulatingPhysics()) {
			OtherComp.AddImpulseAtLocation(GetVelocity() * 100.0, GetActorLocation());

			Destroy();
		}*/
	}

	/** Returns CollisionComp subobject **/
	function GetCollisionComp():USphereComponent {
		return CollisionComp;
	}

	/** Returns ProjectileMovement subobject **/
	function GetProjectileMovement():UProjectileMovementComponent {
		return ProjectileMovement;
	}
}
