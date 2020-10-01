package battleRoyale;

import unreal.*;
import unreal.EBlendMode;

@:uclass
class AHaxeHUD extends AHUD {
	@:uproperty(EditAnywhere, Category = HUD)
	var CrosshairTexture:UTexture2D;

	public function new(wrapped) {
		super(wrapped);
	}

	override function DrawHUD() {
		super.DrawHUD();

		// Draw very simple crosshair

		// find center of the Canvas
		var Center:FVector2D = new FVector2D(Canvas.ClipX * 0.5, Canvas.ClipY * 0.5);

		// offset by half the texture's dimensions so that the center of the texture aligns with the center of the Canvas
		var ScreenPosition:FVector2D = new FVector2D(Center.X, Center.Y + 20.0);
		var ScreenSize:FVector2D = new FVector2D(25, 25);
		var CoordinatePosition:FVector2D = new FVector2D(0, 0);
		var CoordinateSize:FVector2D = new FVector2D(1, 1);

		// draw the crosshair
		Canvas.K2_DrawTexture(CrosshairTexture, ScreenPosition, ScreenSize, CoordinatePosition, CoordinateSize);
	}
}
