using System.Numerics;
using Superfighters.Data.Weapons;

namespace Superfighters.Core.Weapons;

public class WeaponInstance
{
    public WeaponDef Def { get; }
    public int Ammo { get; set; }
    public int CooldownTimer { get; set; }
    public int BurstIndex { get; set; }
    public int BurstDelayTimer { get; set; }
    public bool InBurst { get; set; }

    public WeaponInstance(WeaponDef def)
    {
        Def = def;
        Ammo = def.MaxAmmo;
        CooldownTimer = 0;
        BurstIndex = 0;
        BurstDelayTimer = 0;
        InBurst = false;
    }

    public bool CanShoot() => CooldownTimer <= 0 && Ammo > 0;

    public void Update()
    {
        if (CooldownTimer > 0) CooldownTimer--;
    }
}
