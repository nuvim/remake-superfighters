namespace Superfighters.Core.Players;

// 1:1 Port of Code.Data.Players.BotState.as
public class BotState
{
    // Difficulties (Lines 9-13)
    public const int Easy = 1;
    public const int Medium = 2;
    public const int Hard = 3;
    public const bool FollowOnly = false;

    // FSM Phases (Lines 17-31)
    public const int Idle = 0;
    public const int Aim = 1;
    public const int Shoot = 2;
    public const int CancelAim = 3;
    public const int FollowPath = 4;
    public const int GrabWeapon = 5;
    public const int Melee = 6;
    public const int Interrupted = -1;

    // Tolerances (Lines 33-45)
    public const float DistanceLadderToleranceX = 2f;
    public const float DistanceLadderToleranceY = 5f;
    public const float DistanceWalkTolerance = 4f;
    public const float DistanceNodeToleranceX = 6f;
    public const float DistanceNodeToleranceYMin = 8f;
    public const float DistanceNodeToleranceYMax = -22f;
    public const int UnavailablePlayerTimer = 6;

    // Internal State
    public int Phase { get; set; } = Idle;
    public int PhaseDelay { get; set; } = 0;

    public bool TargetInAim { get; set; } = false;
    public bool TargetInSight { get; set; } = false;
    public int ActivateSprintCounter { get; set; } = 0;
    public int ResetTimer { get; set; } = 0;
    public bool DoFireCheck { get; set; } = false;
    public bool DodgeBullet { get; set; } = false;
    public bool RunAwayFromHazards { get; set; } = false;
    public bool OpponentExist { get; set; } = true;
    public bool PreferJumpOverObstacle { get; set; } = false;
    public bool ActionShotFired { get; set; } = true;
    public int IgnoreObjectCheckingTimer { get; set; } = 0;
    public bool CancelAimSoon { get; set; } = false;
    public bool FirstRocketTurnDone { get; set; } = false;

    public int Difficulty { get; set; } = Medium;
    public bool RunOften { get; set; } = true;
    public bool RandomFirePosition { get; set; } = true;
    public float RandomFireX { get; set; } = 0f;
    public float RandomFireY { get; set; } = 0f;

    public float FollowToAimMinimumDistance { get; set; } = 50f;
    public float MeleeToAimMinimumChance { get; set; } = 0.2f;
    public bool IgnoreDodgeBulletWhileAiming { get; set; } = false;

    // Timers (Tick intervals)
    public float TargetChooseTimer { get; set; } = 0.200f; // 200 ms
    public float TargetInSightTimer { get; set; } = 0.300f; // 300 ms
    public float RandomizeTimer { get; set; } = 4.000f;     // 4000 ms

    public Player? TargetPlayer { get; set; } = null;
}
