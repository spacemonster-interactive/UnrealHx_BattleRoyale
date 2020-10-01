// Copyright 1998-2019 Epic Games, Inc. All Rights Reserved.

#pragma once 

#include "CoreMinimal.h"
#include "GameFramework/HUD.h"
#include "BattleRoyaleHUD.generated.h"

UCLASS()
class ABattleRoyaleHUD : public AHUD
{
	GENERATED_BODY()

public:
	ABattleRoyaleHUD();

	/** Primary draw call for the HUD */
	virtual void DrawHUD() override;

private:
	/** Crosshair asset pointer */
	class UTexture2D* CrosshairTex;

};

