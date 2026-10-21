using System.Numerics;
using Superfighters.Core.Destruction;
using Superfighters.Core.Physics;
using Superfighters.Core.Players;
using Superfighters.Core.Weapons;
using Superfighters.Data.Maps;

namespace Superfighters.Core.Stage;

public class MapManager
{
    public MapDef Def { get; }
    public Box2DWorld Physics { get; }
    public List<DestructibleCrate> Crates { get; } = new();

    public MapManager(MapDef mapDef)
    {
        Def = mapDef;
        Physics = new Box2DWorld(new Vector2(0f, Box2DWorld.DefaultGravity));
        BuildStage();
    }

    private void BuildStage()
    {
        // Add static boxes
        foreach (var b in Def.GroundBoxes)
        {
            Physics.CreateGroundBox(b.X, b.Y, b.Width, b.Height, b.Angle, b.IsPlatform);
        }

        // Spawn crates & explosive barrels across maps
        switch (Def.Id)
        {
            case 0: // Tutorial
                Crates.Add(new DestructibleCrate(Physics, 300, 360, "CRATE", 28, 28, 40));
                Crates.Add(new DestructibleCrate(Physics, 500, 360, "BARREL_EXPLOSIVE", 18, 26, 50));
                break;
            case 1: // Storage
                Crates.Add(new DestructibleCrate(Physics, 230, 260, "CRATE", 28, 28, 40));
                Crates.Add(new DestructibleCrate(Physics, 260, 260, "CRATE", 28, 28, 40));
                Crates.Add(new DestructibleCrate(Physics, 245, 230, "CRATE", 28, 28, 40));
                Crates.Add(new DestructibleCrate(Physics, 500, 260, "CRATE", 28, 28, 40));
                Crates.Add(new DestructibleCrate(Physics, 530, 260, "BARREL_EXPLOSIVE", 18, 26, 50));
                Crates.Add(new DestructibleCrate(Physics, 380, 380, "CRATE", 28, 28, 40));
                Crates.Add(new DestructibleCrate(Physics, 410, 380, "BARREL_EXPLOSIVE", 18, 26, 50));
                Crates.Add(new DestructibleCrate(Physics, 390, 160, "CRATE", 28, 28, 40));
                break;
            case 2: // Rooftops
                Crates.Add(new DestructibleCrate(Physics, 200, 210, "CRATE", 28, 28, 40));
                Crates.Add(new DestructibleCrate(Physics, 540, 210, "BARREL_EXPLOSIVE", 18, 26, 50));
                Crates.Add(new DestructibleCrate(Physics, 360, 310, "CRATE", 28, 28, 40));
                Crates.Add(new DestructibleCrate(Physics, 440, 310, "BARREL_EXPLOSIVE", 18, 26, 50));
                break;
            case 3: // Police Station
                Crates.Add(new DestructibleCrate(Physics, 220, 280, "CRATE", 28, 28, 40));
                Crates.Add(new DestructibleCrate(Physics, 580, 280, "CRATE", 28, 28, 40));
                Crates.Add(new DestructibleCrate(Physics, 400, 370, "BARREL_EXPLOSIVE", 18, 26, 50));
                break;
            case 4: // Hazardous
                Crates.Add(new DestructibleCrate(Physics, 250, 370, "BARREL_EXPLOSIVE", 18, 26, 50));
                Crates.Add(new DestructibleCrate(Physics, 350, 370, "BARREL_EXPLOSIVE", 18, 26, 50));
                Crates.Add(new DestructibleCrate(Physics, 550, 370, "BARREL_EXPLOSIVE", 18, 26, 50));
                Crates.Add(new DestructibleCrate(Physics, 220, 300, "CRATE", 28, 28, 40));
                Crates.Add(new DestructibleCrate(Physics, 520, 300, "CRATE", 28, 28, 40));
                break;
            default:
                Crates.Add(new DestructibleCrate(Physics, 300, 370, "CRATE", 28, 28, 40));
                Crates.Add(new DestructibleCrate(Physics, 500, 370, "BARREL_EXPLOSIVE", 18, 26, 50));
                break;
        }
    }

    public void ResolvePlayerCollisions(Player player)
    {
        if (player.State.Dead) return;

        // Collision against static tiles
        player.OnGround = false;

        foreach (var body in Physics.StaticBodies)
        {
            var pos = body.GetPosition();
            foreach (var fixture in body.FixtureList)
            {
                if (fixture.Shape is Box2DSharp.Collision.Shapes.PolygonShape poly)
                {
                    float w = poly.Vertices[1].X * 2f * Box2DWorld.PtmRatio;
                    float h = poly.Vertices[2].Y * 2f * Box2DWorld.PtmRatio;
                    float bx = pos.X * Box2DWorld.PtmRatio - w / 2f;
                    float by = pos.Y * Box2DWorld.PtmRatio - h / 2f;
                    bool isPlatform = (string?)fixture.UserData == "PLATFORM";

                    if (isPlatform)
                    {
                        // One-way drop through platform
                        if (player.Vy > 0f && player.X + player.Width > bx && player.X < bx + w)
                        {
                            float prevBottom = player.Y + player.Height - player.Vy;
                            if (prevBottom <= by + 4f && player.Y + player.Height >= by)
                            {
                                player.Y = by - player.Height;
                                player.Vy = 0f;
                                player.OnGround = true;
                                if (player.State.Diving)
                                {
                                    player.State.Diving = false;
                                    player.Roll();
                                }
                            }
                        }
                    }
                    else
                    {
                        // Solid ground/wall
                        if (player.X + player.Width > bx && player.X < bx + w &&
                            player.Y + player.Height > by && player.Y < by + h)
                        {
                            // Check vertical collision
                            if (player.Vy > 0f && player.Y + player.Height - player.Vy <= by + 6f)
                            {
                                player.Y = by - player.Height;
                                player.Vy = 0f;
                                player.OnGround = true;
                                if (player.State.Diving)
                                {
                                    player.State.Diving = false;
                                    player.Roll();
                                }
                            }
                            else if (player.Vy < 0f && player.Y - player.Vy >= by + h - 6f)
                            {
                                player.Y = by + h;
                                player.Vy = 0f;
                            }
                            // Check horizontal collision
                            else if (player.Vx > 0f)
                            {
                                player.X = bx - player.Width;
                                player.Vx = 0f;
                            }
                            else if (player.Vx < 0f)
                            {
                                player.X = bx + w;
                                player.Vx = 0f;
                            }
                        }
                    }
                }
            }
        }
    }

    public void StepPhysics(float dt)
    {
        Physics.Step(dt);

        // Remove dead crates
        for (int i = Crates.Count - 1; i >= 0; i--)
        {
            if (Crates[i].IsDead)
            {
                Physics.World.DestroyBody(Crates[i].Body);
                Crates.RemoveAt(i);
            }
        }
    }
}
