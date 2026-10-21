namespace Superfighters.Data.Maps;

public class GroundBoxDef
{
    public float X { get; set; }
    public float Y { get; set; }
    public float Width { get; set; }
    public float Height { get; set; }
    public float Angle { get; set; } = 0f;
    public bool IsPlatform { get; set; } = false; // One-way drop-through platform
    public string Material { get; set; } = "GROUND"; // GROUND, WOOD, METAL
}

public class SpawnPointDef
{
    public float X { get; set; }
    public float Y { get; set; }
    public SpawnPointDef() { }
    public SpawnPointDef(float x, float y) { X = x; Y = y; }
}

public class WeaponSpawnDef
{
    public float X { get; set; }
    public float Y { get; set; }
    public List<int> WeaponPool { get; set; } = new();
    public WeaponSpawnDef() { }
    public WeaponSpawnDef(float x, float y) { X = x; Y = y; }
}

public class MapDef
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public float BoundsMinX { get; set; } = -3000f;
    public float BoundsMinY { get; set; } = -3000f;
    public float BoundsWidth { get; set; } = 9000f;
    public float BoundsHeight { get; set; } = 9000f;
    public string BackgroundTextureName { get; set; } = "1022.png";

    public List<GroundBoxDef> GroundBoxes { get; set; } = new();
    public List<SpawnPointDef> PlayerSpawns { get; set; } = new();
    public List<WeaponSpawnDef> WeaponSpawns { get; set; } = new();
}
