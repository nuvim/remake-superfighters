using System.Numerics;
using Superfighters.Data.Weapons;

namespace Superfighters.Core.Weapons;

public class ProjectileInstance
{
    public Vector2 Position { get; set; }
    public Vector2 PreviousPosition { get; set; }
    public Vector2 Velocity { get; set; }
    public WeaponDef WeaponDef { get; }
    public object Owner { get; }
    public bool IsDead { get; set; } = false;
    public int LifeTicks { get; set; } = 0;
    public int MaxLifeTicks { get; set; } = 120;
    public bool IsRocket => WeaponDef.IsRocket;

    public ProjectileInstance(Vector2 startPos, Vector2 velocity, WeaponDef weaponDef, object owner)
    {
        Position = startPos;
        PreviousPosition = startPos;
        Velocity = velocity;
        WeaponDef = weaponDef;
        Owner = owner;
    }

    public void Update()
    {
        LifeTicks++;
        if (LifeTicks > MaxLifeTicks)
        {
            IsDead = true;
            return;
        }

        PreviousPosition = Position;
        Position += Velocity;
    }
}
