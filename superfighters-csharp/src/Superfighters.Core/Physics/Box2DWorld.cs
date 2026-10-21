using System.Numerics;
using Box2DSharp.Collision.Shapes;
using Box2DSharp.Common;
using Box2DSharp.Dynamics;
using Superfighters.Data.Maps;

namespace Superfighters.Core.Physics;

public class Box2DWorld
{
    // Ground truth: 30 pixels per meter in Flash Box2D
    public const float PtmRatio = 30.0f;

    // Ground truth: PlayerGravity = 0.6 from PlayerState.as
    public const float DefaultGravity = 0.6f;

    public World World { get; }

    public List<Body> StaticBodies { get; } = new();
    public List<Body> DynamicBodies { get; } = new();

    public Box2DWorld(Vector2 gravity)
    {
        World = new World(new System.Numerics.Vector2(gravity.X, gravity.Y));
    }

    public static float PixelsToMeters(float pixels) => pixels / PtmRatio;
    public static float MetersToPixels(float meters) => meters * PtmRatio;

    public static System.Numerics.Vector2 ToMeters(Vector2 pixels) => new(pixels.X / PtmRatio, pixels.Y / PtmRatio);
    public static Vector2 ToPixels(System.Numerics.Vector2 meters) => new(meters.X * PtmRatio, meters.Y * PtmRatio);

    public Body CreateGroundBox(float x, float y, float width, float height, float angle = 0f, bool isPlatform = false)
    {
        var bodyDef = new BodyDef
        {
            BodyType = BodyType.StaticBody,
            Position = new System.Numerics.Vector2(
                PixelsToMeters(x + width / 2f),
                PixelsToMeters(y + height / 2f)
            ),
            Angle = angle
        };

        var body = World.CreateBody(bodyDef);
        var shape = new PolygonShape();
        shape.SetAsBox(PixelsToMeters(width / 2f), PixelsToMeters(height / 2f));

        var fixtureDef = new FixtureDef
        {
            Shape = shape,
            Density = 0.0f,
            Friction = 0.5f,
            Restitution = 0.0f
        };

        if (isPlatform)
        {
            // One-way platform filter / sensor tag
            fixtureDef.IsSensor = false;
        }

        var fixture = body.CreateFixture(fixtureDef);
        fixture.UserData = isPlatform ? "PLATFORM" : "GROUND";

        StaticBodies.Add(body);
        return body;
    }

    public Body CreateDynamicBox(float x, float y, float width, float height, float mass = 0.7f, string tag = "CRATE")
    {
        var bodyDef = new BodyDef
        {
            BodyType = BodyType.DynamicBody,
            Position = new System.Numerics.Vector2(
                PixelsToMeters(x + width / 2f),
                PixelsToMeters(y + height / 2f)
            ),
            FixedRotation = false,
            LinearDamping = 0.4f,
            AngularDamping = 0.6f
        };

        var body = World.CreateBody(bodyDef);
        var shape = new PolygonShape();
        shape.SetAsBox(PixelsToMeters(width / 2f), PixelsToMeters(height / 2f));

        var fixtureDef = new FixtureDef
        {
            Shape = shape,
            Density = mass,
            Friction = 0.6f,
            Restitution = 0.1f
        };

        var fixture = body.CreateFixture(fixtureDef);
        fixture.UserData = tag;

        DynamicBodies.Add(body);
        return body;
    }

    public void Step(float timeStep = 1.0f / 60.0f, int velocityIterations = 8, int positionIterations = 3)
    {
        World.Step(timeStep, velocityIterations, positionIterations);
    }
}
