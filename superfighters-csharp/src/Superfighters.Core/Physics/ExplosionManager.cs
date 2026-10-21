using System.Numerics;
using Box2DSharp.Dynamics;
using Superfighters.Core.Destruction;
using Superfighters.Core.Players;

namespace Superfighters.Core.Physics;

// 1:1 Ground-truth Port of Code.Handler.Explosions.as
public class ExplosionInstance
{
    public Vector2 Position { get; set; }
    public float Radius { get; set; } = 75f;
    public float DamageToPlayers { get; set; } = 20f;  // Explosions.as line 66
    public float DamageToObjects { get; set; } = 25f;  // Explosions.as line 64
    public float ImpulsePower { get; set; } = 5f;      // Explosions.as lines 60, 62
    public int LifeTicks { get; set; } = 0;
    public int MaxLifeTicks { get; set; } = 20;
    public bool IsDead => LifeTicks >= MaxLifeTicks;
}

public static class ExplosionManager
{
    public static ExplosionInstance TriggerExplosion(
        Vector2 position,
        List<Player> players,
        List<DestructibleCrate> crates,
        List<ExplosionInstance> outExplosions,
        List<string> outSoundEvents)
    {
        var explosion = new ExplosionInstance { Position = position };
        outExplosions.Add(explosion);
        outSoundEvents.Add("EXPLOSION");

        // 1. Affect Players
        foreach (var player in players)
        {
            if (player.State.Dead) continue;
            float midX = player.X + player.Width / 2f;
            float midY = player.Y + player.Height / 2f;
            float dx = midX - position.X;
            float dy = midY - position.Y;
            float dist = MathF.Sqrt(dx * dx + dy * dy);

            if (dist < explosion.Radius)
            {
                float factor = 1f - (dist / explosion.Radius);
                float damage = explosion.DamageToPlayers * factor;
                float pushMagnitude = explosion.ImpulsePower * (factor + 0.5f);
                float angle = MathF.Atan2(dy, dx);
                float pushX = MathF.Cos(angle) * pushMagnitude;
                float pushY = MathF.Sin(angle) * pushMagnitude - 2.5f; // Slight upward pop

                player.TakeDamage(damage, pushX, pushY);
                player.State.BurnState = MathF.Min(100f, player.State.BurnState + 40f);
            }
        }

        // 2. Affect Destructible Crates / Dynamic Objects
        foreach (var crate in crates)
        {
            if (crate.IsDead) continue;
            var crateMid = crate.Position + new Vector2(crate.Width / 2f, crate.Height / 2f);
            float dx = crateMid.X - position.X;
            float dy = crateMid.Y - position.Y;
            float dist = MathF.Sqrt(dx * dx + dy * dy);

            if (dist < explosion.Radius)
            {
                float factor = 1f - (dist / explosion.Radius);
                float damage = explosion.DamageToObjects * factor;
                float pushMagnitude = explosion.ImpulsePower * factor * 2.5f;
                float angle = MathF.Atan2(dy, dx);
                var impulse = new Vector2(MathF.Cos(angle) * pushMagnitude, MathF.Sin(angle) * pushMagnitude - 2f);

                crate.TakeDamage(damage, impulse);
            }
        }

        return explosion;
    }
}
