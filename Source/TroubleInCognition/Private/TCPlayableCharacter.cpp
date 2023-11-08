// Copyright 2023 Nathan Ford. All Right Reserved


#include "TCPlayableCharacter.h"

// Sets default values
ATCPlayableCharacter::ATCPlayableCharacter()
{
 	// Set this character to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;

	// Setup the spring arm
	SpringArmComponent = CreateDefaultSubobject<USpringArmComponent>(TEXT("SpringArm"));
	SpringArmComponent->SetupAttachment(RootComponent);
	SpringArmComponent->TargetArmLength = 300.0f;
	SpringArmComponent->SetRelativeLocation(GetActorLocation() + FVector(0.f, 0.f, BaseEyeHeight));
	SpringArmComponent->SetRelativeRotation(FRotator(-30.f, 0.f, 0.f));
	SpringArmComponent->bUsePawnControlRotation = true;

	// Setup the camera
	CameraComponent = CreateDefaultSubobject<UCameraComponent>(TEXT("Camera"));
	CameraComponent->SetupAttachment(SpringArmComponent);

}

void ATCPlayableCharacter::MoveForward(float Input)
{
	AddMovementInput(GetActorForwardVector(), Input);
}

void ATCPlayableCharacter::MoveRight(float Input)
{
	AddMovementInput(GetActorRightVector(), Input);
}

// Called when the game starts or when spawned
void ATCPlayableCharacter::BeginPlay()
{
	Super::BeginPlay();
	
}

// Called every frame
void ATCPlayableCharacter::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

}

// Called to bind functionality to input
void ATCPlayableCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);

	// Bind Axis
	PlayerInputComponent->BindAxis("MoveForward", this, &ATCPlayableCharacter::MoveForward);
	PlayerInputComponent->BindAxis("MoveRight", this, &ATCPlayableCharacter::MoveRight);
	PlayerInputComponent->BindAxis("YawCamera", this, &ACharacter::AddControllerYawInput);
	PlayerInputComponent->BindAxis("PitchCamera", this, &ACharacter::AddControllerPitchInput);

	// Bind Action
	PlayerInputComponent->BindAction("Jump", IE_Pressed, this, &ACharacter::Jump);

}

