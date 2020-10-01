// Copyright 1998-2019 Epic Games, Inc. All Rights Reserved.

#include "BattleRoyaleGameMode.h"
#include "BattleRoyaleHUD.h"
#include "BattleRoyaleCharacter.h"
#include "UObject/ConstructorHelpers.h"

ABattleRoyaleGameMode::ABattleRoyaleGameMode()
	: Super()
{
	// set default pawn class to our Blueprinted character
	static ConstructorHelpers::FClassFinder<APawn> PlayerPawnClassFinder(TEXT("/Game/FirstPersonCPP/Blueprints/FirstPersonCharacter"));
	DefaultPawnClass = PlayerPawnClassFinder.Class;

	// use our custom HUD class
	HUDClass = ABattleRoyaleHUD::StaticClass();
}
