using System.Numerics;
using Box2DSharp.Dynamics;
using Superfighters.Core.Physics;

namespace Superfighters.Core.Destruction;

public class DestructibleCrate
{
    public Body Body { get; }
    public string Type { get; }
    public float Width { get; }
    public float Height { get; }
    public float HP { get; set; } = 40f;
    public float MaxHP { get; } = 40f;
    public bool IsDead { get; set; } = false;
    public bool IsExplosive { get; } = false;

    public Vector2 Position
    {
        get
        {
            var p = Body.GetPosition();
            return new Vector2(Box2DWorld.MetersToPixels(p.X) - Width / 2f, Box2DWorld.MetersToPixels(p.Y) - Height / 2f);
        }
    }

    public float Angle => Body.GetAngle();

    public DestructibleCrate(Box2DWorld world, float x, float y, string type = "CRATE", float width = 28f, float height = 28f, float hp = 40f)
    {
        Type = type.ToUpperInvariant();
        Width = width;
        Height = height;
        HP = hp;
        MaxHP = hp;
        IsExplosive = Type == "BARREL_EXPLOSIVE";

        float mass = Type.Contains("BARREL") ? 1.0f : 0.7f;
        Body = world.CreateDynamicBox(x, y, width, height, mass: mass, tag: Type);
        Body.UserData = this;
    }

    public void TakeDamage(float amount, Vector2 impulse)
    {
        if (IsDead) return;
        HP -= amount;

        // Apply Box2D impulse (divided by 30)
        var b2Impulse = new System.Numerics.Vector2(impulse.X / Box2DWorld.PtmRatio, impulse.Y / Box2DWorld.PtmRatio);
        Body.ApplyLinearImpulseToCenter(b2Impulse, true);

        if (HP <= 0)
        {
            HP = 0;
            IsDead = true;
        }
    }
}
