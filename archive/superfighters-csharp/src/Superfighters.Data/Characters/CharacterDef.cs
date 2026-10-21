namespace Superfighters.Data.Characters;

public class CharacterDef
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string SkinTextureName { get; set; } = string.Empty;
    public uint PrimaryColorRgba { get; set; }
    public uint SecondaryColorRgba { get; set; }
    public uint SkinColorRgba { get; set; }
    public uint HairColorRgba { get; set; }
    public bool LockedByDefault { get; set; } = false;
}
