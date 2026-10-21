namespace Superfighters.Core.Players;

// 1:1 Port of Code.Data.Players.PlayerState.as
public class PlayerState
{
    public const float KnockdownImmunityTime = 10f;

    // Movement & Physics Constants (Lines 12-43 of PlayerState.as)
    public float PlayerGravity { get; set; } = 0.6f;
    public float UpdateYAxisDistance { get; set; } = 3.0f;
    public float PlayerEdgeDistance { get; set; } = 4.0f;
    public float PlayerFeetSize { get; set; } = 4.0f;
    public float PlayerJumpPower { get; set; } = -5.0f;
    public bool PlayerJumpPushActivated { get; set; } = false;
    public float PlayerJumpPushPower { get; set; } = -0.7f;
    public bool PlayerJumpPushLevelOut { get; set; } = false;
    public bool PlayerJumpPushEnabled { get; set; } = false;
    public float PlayerJumpPushTime { get; set; } = 4.0f;
    public float JumpPushTimeLeft { get; set; } = 0f;
    public float PlayerWallJumpPower { get; set; } = -5.0f;
    public float FallTriggerSpeed { get; set; } = 8.5f;
    public float StaggerSpeed { get; set; } = 1.0f;
    public float RollSpeed { get; set; } = 2.0f;
    public float DiveSpeed { get; set; } = 3.5f;
    public bool ShortDiveAvailable { get; set; } = false;
    public float Mass { get; set; } = 0.7f;
    public float KickPower { get; set; } = 1.6f;
    public float PunchGlideSpeed { get; set; } = 2.0f;
    public float RunSpeed { get; set; } = 1.7f;
    public float SprintSpeed { get; set; } = 2.4f;
    public float ClimbSpeed { get; set; } = 1.5f;
    public float SlideSpeed { get; set; } = 3.0f;

    // Health & Stamina
    public float HP { get; set; } = 100f;
    public float MaxHP { get; set; } = 100f;
    public float SprintEnergy { get; set; } = 100f;
    public float MaxSprintEnergy { get; set; } = 100f;

    // Velocities & Positions
    public float AirVelocityX { get; set; } = 0f;
    public float AirVelocityY { get; set; } = 0f;
    public int LastDirX { get; set; } = 1; // 1 = Right, -1 = Left
    public int MovingDirectionX { get; set; } = 0;

    // States & Flags
    public bool Controllable { get; set; } = true;
    public bool Sprinting { get; set; } = false;
    public bool Jumping { get; set; } = false;
    public bool Diving { get; set; } = false;
    public bool Rolling { get; set; } = false;
    public bool Kneeling { get; set; } = false;
    public bool Punching { get; set; } = false;
    public bool Kicking { get; set; } = false;
    public bool Knockdowned { get; set; } = false;
    public bool Falling { get; set; } = false;
    public bool Staggering { get; set; } = false;
    public bool IsStunned { get; set; } = false;
    public bool GrabbedByPlayer { get; set; } = false;
    public bool DeathKneel { get; set; } = false;
    public bool Dead { get; set; } = false;

    // Melee combo
    public int PunchComboNr { get; set; } = 0;
    public float PunchTimer { get; set; } = 0;
    public float PunchCooldown { get; set; } = 0;

    // Aiming & Weapons
    public bool Aiming { get; set; } = false;
    public int AimPitch { get; set; } = 0; // -1: up, 0: straight, 1: down
    public int AimMode { get; set; } = 0; // 0: firearm, 1: throwable
    public float CurrentWeaponCooldown { get; set; } = 0f;

    // Fire & Burning
    public float BurnState { get; set; } = 0f;
    public bool InWorldFire { get; set; } = false;
    public bool FireRank1Attached { get; set; } = false;
    public bool FireRank2Attached { get; set; } = false;

    // Immunity
    public float ImmunityTimer { get; set; } = 0f;
    public bool IsImmune => ImmunityTimer > 0;

    public void DecreaseBurnState()
    {
        BurnState = Math.Max(0f, BurnState - 30f);
        if (BurnState <= 0)
        {
            FireRank1Attached = false;
            FireRank2Attached = false;
        }
    }
}
