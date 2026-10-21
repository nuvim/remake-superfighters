namespace Superfighters.Data.Weapons;

public class WeaponSequencePartDef
{
    public int BulletsCount { get; set; } = 0;
    public bool PlaySound { get; set; } = false;
    public bool EjectShell { get; set; } = false;
    public string SoundName { get; set; } = "NONE";
    public int FrameDelay { get; set; } = 1;
    public bool EndLoop { get; set; } = false;

    public WeaponSequencePartDef() { }

    public WeaponSequencePartDef(int bullets, bool playSound, bool ejectShell, string soundName, int frameDelay, bool endLoop = false)
    {
        BulletsCount = bullets;
        PlaySound = playSound;
        EjectShell = ejectShell;
        SoundName = soundName;
        FrameDelay = frameDelay;
        EndLoop = endLoop;
    }
}

public class WeaponDef
{
    public string WeaponType { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string AnimType { get; set; } = string.Empty;
    public int MaxAmmo { get; set; }
    public int WeaponCooldown { get; set; }
    public float AccuracyDeflection { get; set; }
    public string AimSound { get; set; } = string.Empty;
    public string EmptySound { get; set; } = string.Empty;
    public string PickupSound { get; set; } = string.Empty;
    public string BulletType { get; set; } = string.Empty;
    public float PickupRadius { get; set; }
    public bool LaserSight { get; set; }
    public string MuzzleFlashEffect { get; set; } = string.Empty;
    public string ShellEffect { get; set; } = string.Empty;
    public float ShootRange { get; set; }

    // Projectile Stats from Projectiles.as
    public float BulletSpeed { get; set; }
    public float Damage { get; set; }
    public float CriticalChance { get; set; }
    public float CriticalDamage { get; set; }
    public float PushbackPower { get; set; }
    public float TotalPenetrationDepth { get; set; }
    public float SinglePenetrationDepth { get; set; }
    public float Strength { get; set; }
    public float ImpulseForce { get; set; }
    public bool IsRocket { get; set; } = false;

    // Weapon Category & Extended Stats from Weapons.as
    public string Category { get; set; } = "FIREARM"; // FIREARM, MELEE, THROWABLE, POWERUP
    public List<int> MeleeDamage { get; set; } = new();
    public List<int> MeleeRange { get; set; } = new();
    public string HitSound { get; set; } = string.Empty;
    public string SwingSound { get; set; } = string.Empty;
    public int ThrowTimer { get; set; } = 0;
    public float HealAmount { get; set; } = 0f;
    public float SlowmoDuration { get; set; } = 0f;

    public List<WeaponSequencePartDef> FireSequence { get; set; } = new();
}
