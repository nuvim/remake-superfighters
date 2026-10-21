using System.Text.Json;
using Superfighters.Data.Weapons;
using Superfighters.Data.Maps;
using Superfighters.Data.Characters;

namespace Superfighters.Data;

public class ModRepository
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        PropertyNameCaseInsensitive = true
    };

    public Dictionary<string, WeaponDef> Weapons { get; } = new(StringComparer.OrdinalIgnoreCase);
    public Dictionary<int, MapDef> Maps { get; } = new();
    public Dictionary<int, CharacterDef> Characters { get; } = new();

    public void LoadOrCreateDefaults(string dataDirectory)
    {
        Directory.CreateDirectory(dataDirectory);
        string weaponsFile = Path.Combine(dataDirectory, "weapons.json");
        string mapsFile = Path.Combine(dataDirectory, "maps.json");
        string charactersFile = Path.Combine(dataDirectory, "characters.json");

        // Load or create Weapons
        var defaultWeapons = CreateDefaultWeapons();
        if (File.Exists(weaponsFile))
        {
            var list = JsonSerializer.Deserialize<List<WeaponDef>>(File.ReadAllText(weaponsFile), JsonOptions);
            if (list != null)
            {
                foreach (var w in list) Weapons[w.WeaponType] = w;
            }
        }
        foreach (var w in defaultWeapons)
        {
            if (!Weapons.ContainsKey(w.WeaponType)) Weapons[w.WeaponType] = w;
        }
        File.WriteAllText(weaponsFile, JsonSerializer.Serialize(Weapons.Values.ToList(), JsonOptions));

        // Load or create Characters
        var defaultCharacters = CreateDefaultCharacters();
        if (File.Exists(charactersFile))
        {
            var list = JsonSerializer.Deserialize<List<CharacterDef>>(File.ReadAllText(charactersFile), JsonOptions);
            if (list != null)
            {
                foreach (var c in list) Characters[c.Id] = c;
            }
        }
        foreach (var c in defaultCharacters)
        {
            if (!Characters.ContainsKey(c.Id)) Characters[c.Id] = c;
        }
        File.WriteAllText(charactersFile, JsonSerializer.Serialize(Characters.Values.ToList(), JsonOptions));

        // Load or create Maps
        var defaultMaps = CreateDefaultMaps();
        if (File.Exists(mapsFile))
        {
            var list = JsonSerializer.Deserialize<List<MapDef>>(File.ReadAllText(mapsFile), JsonOptions);
            if (list != null)
            {
                foreach (var m in list) Maps[m.Id] = m;
            }
        }
        foreach (var m in defaultMaps)
        {
            if (!Maps.ContainsKey(m.Id)) Maps[m.Id] = m;
        }
        File.WriteAllText(mapsFile, JsonSerializer.Serialize(Maps.Values.ToList(), JsonOptions));
    }

    // 100% Exact Ground Truth extracted from Weapons.as & Projectiles.as
    public static List<WeaponDef> CreateDefaultWeapons()
    {
        return new List<WeaponDef>
        {
            new()
            {
                WeaponType = "PISTOL",
                Name = "Pistol",
                AnimType = "PISTOL",
                MaxAmmo = 12,
                WeaponCooldown = 6,
                AccuracyDeflection = 1.0f,
                AimSound = "PISTOL_AIM",
                EmptySound = "NOAMMO_LIGHT",
                PickupSound = "PISTOL_AIM",
                BulletType = "PISTOL_BULLET",
                PickupRadius = 10f,
                ShootRange = 300f,
                BulletSpeed = 30f,
                Damage = 10f,
                CriticalChance = 0.05f,
                CriticalDamage = 15f,
                PushbackPower = 15f,
                TotalPenetrationDepth = 12f,
                SinglePenetrationDepth = 5f,
                Strength = 5f,
                ImpulseForce = 0.6f,
                FireSequence = new()
                {
                    new(1, true, true, "PISTOL_FIRE", 2),
                    new(0, false, false, "NONE", 1, true)
                }
            },
            new()
            {
                WeaponType = "RIFLE",
                Name = "Assault Rifle",
                AnimType = "RIFLE",
                MaxAmmo = 25, // 5 * 5 in Weapons.as line 192
                WeaponCooldown = 6,
                AccuracyDeflection = 3.0f,
                AimSound = "RIFLE_AIM",
                EmptySound = "NOAMMO_HEAVY",
                PickupSound = "RIFLE_AIM",
                BulletType = "RIFLE_BULLET",
                PickupRadius = 16f,
                ShootRange = 300f,
                BulletSpeed = 35f,
                Damage = 8f,
                CriticalChance = 0.06f,
                CriticalDamage = 10f,
                PushbackPower = 20f,
                TotalPenetrationDepth = 12f,
                SinglePenetrationDepth = 5f,
                Strength = 5f,
                ImpulseForce = 0.45f,
                FireSequence = new()
                {
                    new(1, true, true, "RIFLE_FIRE", 2),
                    new(0, false, false, "NONE", 1),
                    new(1, true, true, "RIFLE_FIRE", 2),
                    new(0, false, false, "NONE", 1),
                    new(1, true, true, "RIFLE_FIRE", 2),
                    new(0, false, false, "NONE", 1),
                    new(1, true, true, "RIFLE_FIRE", 2),
                    new(0, false, false, "NONE", 1),
                    new(1, true, true, "RIFLE_FIRE", 2),
                    new(0, false, false, "NONE", 1, true)
                }
            },
            new()
            {
                WeaponType = "UZI",
                Name = "Uzi",
                AnimType = "UZI",
                MaxAmmo = 25, // 5 * 5 in Weapons.as line 217
                WeaponCooldown = 6,
                AccuracyDeflection = 6.0f,
                AimSound = "UZI_AIM",
                EmptySound = "NOAMMO_LIGHT",
                PickupSound = "UZI_AIM",
                BulletType = "UZI_BULLET",
                PickupRadius = 16f,
                ShootRange = 200f,
                BulletSpeed = 30f,
                Damage = 7f,
                CriticalChance = 0.04f,
                CriticalDamage = 10f,
                PushbackPower = 10f,
                TotalPenetrationDepth = 12f,
                SinglePenetrationDepth = 5f,
                Strength = 5f,
                ImpulseForce = 0.3f,
                FireSequence = new()
                {
                    new(1, true, true, "UZI_FIRE", 2),
                    new(0, false, false, "NONE", 1),
                    new(1, true, true, "UZI_FIRE", 2),
                    new(0, false, false, "NONE", 1),
                    new(1, true, true, "UZI_FIRE", 2),
                    new(0, false, false, "NONE", 1),
                    new(1, true, true, "UZI_FIRE", 2),
                    new(0, false, false, "NONE", 1),
                    new(1, true, true, "UZI_FIRE", 2),
                    new(0, false, false, "NONE", 1, true)
                }
            },
            new()
            {
                WeaponType = "SHOTGUN",
                Name = "Shotgun",
                AnimType = "SHOTGUN",
                MaxAmmo = 32, // 8 * 4 in Weapons.as line 243
                WeaponCooldown = 3,
                AccuracyDeflection = 4.3f,
                AimSound = "SHOTGUN_AIM",
                EmptySound = "NOAMMO_HEAVY",
                PickupSound = "SHOTGUN_AIM",
                BulletType = "SHOTGUN_BULLET",
                PickupRadius = 14f,
                ShootRange = 200f,
                BulletSpeed = 30f,
                Damage = 6f, // 4 pellets * 6 = 24
                CriticalChance = 0f,
                CriticalDamage = 6f,
                PushbackPower = 33f,
                TotalPenetrationDepth = 12f,
                SinglePenetrationDepth = 5f,
                Strength = 5f,
                ImpulseForce = 0.35f,
                FireSequence = new()
                {
                    new(4, true, false, "SHOTGUN_FIRE", 2),
                    new(0, false, false, "NONE", 2),
                    new(0, false, false, "NONE", 1),
                    new(0, false, false, "NONE", 1),
                    new(0, false, false, "NONE", 1),
                    new(0, false, true, "SHOTGUN_PUMP_P1", 3),
                    new(0, false, false, "NONE", 3),
                    new(0, false, false, "NONE", 3),
                    new(0, false, false, "NONE", 3),
                    new(0, false, false, "NONE", 1),
                    new(0, false, false, "SHOTGUN_PUMP_P2", 1, true)
                }
            },
            new()
            {
                WeaponType = "BAZOOKA",
                Name = "Bazooka",
                AnimType = "BAZOOKA",
                MaxAmmo = 2,
                WeaponCooldown = 10,
                AccuracyDeflection = 0.5f,
                AimSound = "BAZOOKA_AIM",
                EmptySound = "NOAMMO_HEAVY",
                PickupSound = "BAZOOKA_AIM",
                BulletType = "BAZOOKA_ROCKET",
                PickupRadius = 16f,
                ShootRange = 400f,
                BulletSpeed = 18f,
                Damage = 100f,
                CriticalChance = 0f,
                CriticalDamage = 0f,
                PushbackPower = 0f,
                TotalPenetrationDepth = 0f,
                SinglePenetrationDepth = 0f,
                Strength = 1f,
                ImpulseForce = 3.0f,
                IsRocket = true,
                FireSequence = new()
                {
                    new(1, true, false, "BAZOOKA_FIRE", 5),
                    new(0, false, false, "NONE", 1, true)
                }
            },
            new()
            {
                WeaponType = "MAGNUM",
                Name = "Magnum",
                AnimType = "MAGNUM",
                MaxAmmo = 6,
                WeaponCooldown = 8,
                AccuracyDeflection = 0.5f,
                AimSound = "MAGNUM_AIM",
                EmptySound = "NOAMMO_HEAVY",
                PickupSound = "MAGNUM_AIM",
                BulletType = "MAGNUM_BULLET",
                PickupRadius = 10f,
                ShootRange = 300f,
                BulletSpeed = 40f,
                Damage = 25f,
                CriticalChance = 0.40f,
                CriticalDamage = 35f,
                PushbackPower = 50f,
                TotalPenetrationDepth = 12f,
                SinglePenetrationDepth = 5f,
                Strength = 15f,
                ImpulseForce = 1.05f,
                FireSequence = new()
                {
                    new(1, true, false, "MAGNUM_FIRE", 2),
                    new(0, false, false, "NONE", 1, true)
                }
            },
            new()
            {
                WeaponType = "SNIPER",
                Name = "Sniper Rifle",
                AnimType = "SNIPER",
                MaxAmmo = 5,
                WeaponCooldown = 18,
                AccuracyDeflection = 0f,
                AimSound = "SNIPER_AIM",
                EmptySound = "NOAMMO_HEAVY",
                PickupSound = "SNIPER_AIM",
                BulletType = "SNIPER_BULLET",
                PickupRadius = 16f,
                LaserSight = true,
                ShootRange = 900f,
                BulletSpeed = 40f,
                Damage = 30f,
                CriticalChance = 0.75f,
                CriticalDamage = 60f,
                PushbackPower = 50f,
                TotalPenetrationDepth = 12f,
                SinglePenetrationDepth = 5f,
                Strength = 30f,
                ImpulseForce = 1.25f,
                FireSequence = new()
                {
                    new(1, true, true, "SNIPER_FIRE", 2),
                    new(0, false, false, "NONE", 2),
                    new(0, false, false, "NONE", 1, true)
                }
            },
            new()
            {
                WeaponType = "FLAMETHROWER",
                Name = "Flamethrower",
                AnimType = "FLAMETHROWER",
                MaxAmmo = 60,
                WeaponCooldown = 10,
                AccuracyDeflection = 6.0f,
                AimSound = "FLAMETHROWER_AIM",
                EmptySound = "NOAMMO_LIGHT",
                PickupSound = "FLAMETHROWER_AIM",
                BulletType = "FLAME",
                PickupRadius = 16f,
                ShootRange = 140f,
                BulletSpeed = 15f,
                Damage = 4f,
                PushbackPower = 2f,
                Strength = 1f,
                ImpulseForce = 0.1f,
                FireSequence = new()
                {
                    new(1, false, false, "FLAMETHROWER_FIRE", 1),
                    new(0, false, false, "NONE", 1, true)
                }
            },
            // Melee Weapons
            new()
            {
                WeaponType = "FISTS",
                Name = "Fists",
                AnimType = "PUNCH",
                Category = "MELEE",
                MaxAmmo = 0,
                PickupRadius = 0f,
                HitSound = "MELEE_HIT",
                SwingSound = "MELEE_SWING",
                MeleeDamage = new() { 6, 7, 8 },
                MeleeRange = new() { 10, 11, 13 }
            },
            new()
            {
                WeaponType = "MACHETE",
                Name = "Machete",
                AnimType = "MACHETE",
                Category = "MELEE",
                MaxAmmo = 0,
                PickupRadius = 10f,
                HitSound = "KATANA_HIT",
                SwingSound = "MELEE_SWING",
                PickupSound = "MELEE_GRAB",
                MeleeDamage = new() { 8, 9, 10 },
                MeleeRange = new() { 13, 13, 19 }
            },
            new()
            {
                WeaponType = "AXE",
                Name = "Axe",
                AnimType = "AXE",
                Category = "MELEE",
                MaxAmmo = 0,
                PickupRadius = 10f,
                HitSound = "KATANA_HIT",
                SwingSound = "MELEE_SWING",
                PickupSound = "MELEE_GRAB",
                MeleeDamage = new() { 11, 12, 13 },
                MeleeRange = new() { 18, 18, 20 }
            },
            new()
            {
                WeaponType = "SWORD",
                Name = "Sword",
                AnimType = "SWORD",
                Category = "MELEE",
                MaxAmmo = 0,
                PickupRadius = 10f,
                HitSound = "KATANA_HIT",
                SwingSound = "MELEE_SWING",
                PickupSound = "MELEE_GRAB",
                MeleeDamage = new() { 13, 14, 15 },
                MeleeRange = new() { 18, 18, 23 }
            },
            // Throwables
            new()
            {
                WeaponType = "GRENADE",
                Name = "Grenade",
                AnimType = "GRENADE",
                Category = "THROWABLE",
                MaxAmmo = 3,
                ThrowTimer = 72,
                PickupRadius = 10f,
                AimSound = "GRENADE_SAFE",
                PickupSound = "GRENADE_SAFE"
            },
            new()
            {
                WeaponType = "MOLOTOV",
                Name = "Molotov",
                AnimType = "MOLOTOV",
                Category = "THROWABLE",
                MaxAmmo = 3,
                ThrowTimer = 0,
                PickupRadius = 10f,
                PickupSound = "GRENADE_SAFE"
            },
            // Powerups
            new()
            {
                WeaponType = "PILLS",
                Name = "Pills (+25 HP)",
                Category = "POWERUP",
                HealAmount = 25f,
                PickupRadius = 12f,
                PickupSound = "GET_HEALTH"
            },
            new()
            {
                WeaponType = "MEDKIT",
                Name = "Medkit (+50 HP)",
                Category = "POWERUP",
                HealAmount = 50f,
                PickupRadius = 12f,
                PickupSound = "GET_HEALTH"
            },
            new()
            {
                WeaponType = "SLOMO05",
                Name = "Slowmo 5s",
                Category = "POWERUP",
                SlowmoDuration = 5f,
                PickupRadius = 12f
            },
            new()
            {
                WeaponType = "SLOMO10",
                Name = "Slowmo 10s",
                Category = "POWERUP",
                SlowmoDuration = 10f,
                PickupRadius = 12f
            }
        };
    }

    // 100% Exact Ground Truth from PlayerCharacter.as
    public static List<CharacterDef> CreateDefaultCharacters()
    {
        return new List<CharacterDef>
        {
            new() { Id = 1, Name = "Johnny", SkinTextureName = "player_johnny", PrimaryColorRgba = 0x2244AAFF, SecondaryColorRgba = 0x111111FF, SkinColorRgba = 0xF5CBA7FF, HairColorRgba = 0x553311FF },
            new() { Id = 2, Name = "Boris", SkinTextureName = "player_boris", PrimaryColorRgba = 0x882222FF, SecondaryColorRgba = 0x222222FF, SkinColorRgba = 0xF5CBA7FF, HairColorRgba = 0x111111FF },
            new() { Id = 3, Name = "Agent", SkinTextureName = "player_agent", PrimaryColorRgba = 0x111111FF, SecondaryColorRgba = 0xFFFFFFFF, SkinColorRgba = 0xF5CBA7FF, HairColorRgba = 0x222222FF },
            new() { Id = 4, Name = "Billy", SkinTextureName = "player_billy", PrimaryColorRgba = 0x228833FF, SecondaryColorRgba = 0x333333FF, SkinColorRgba = 0xF5CBA7FF, HairColorRgba = 0xEEDD44FF },
            new() { Id = 5, Name = "Scott", SkinTextureName = "player_scott", PrimaryColorRgba = 0xAA6622FF, SecondaryColorRgba = 0x222222FF, SkinColorRgba = 0xF5CBA7FF, HairColorRgba = 0x773311FF },
            new() { Id = 6, Name = "Funnyman", SkinTextureName = "player_funnyman", PrimaryColorRgba = 0xEE8811FF, SecondaryColorRgba = 0x111111FF, SkinColorRgba = 0xF5CBA7FF, HairColorRgba = 0x00FF00FF, LockedByDefault = true },
            new() { Id = 7, Name = "Mac", SkinTextureName = "player_mac", PrimaryColorRgba = 0x555555FF, SecondaryColorRgba = 0x111111FF, SkinColorRgba = 0xF5CBA7FF, HairColorRgba = 0x333333FF },
            new() { Id = 8, Name = "Jeff", SkinTextureName = "player_jeff", PrimaryColorRgba = 0x334466FF, SecondaryColorRgba = 0x222222FF, SkinColorRgba = 0xF5CBA7FF, HairColorRgba = 0x664422FF }
        };
    }

    // Exact 8 Maps from Maps.as (Lines 3587-3608)
    public static List<MapDef> CreateDefaultMaps()
    {
        var maps = new List<MapDef>();

        // Map 0: Tutorial (Maps.as line 157 & 3587, BG 230.png)
        maps.Add(new MapDef
        {
            Id = 0,
            Name = "Tutorial",
            BackgroundTextureName = "230.png",
            BoundsMinX = 0f, BoundsMinY = 0f, BoundsWidth = 800f, BoundsHeight = 450f,
            GroundBoxes = new()
            {
                new() { X = 0, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 780, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 0, Y = 0, Width = 800, Height = 20, Material = "GROUND" },
                new() { X = 0, Y = 400, Width = 800, Height = 50, Material = "GROUND" },
                new() { X = 200, Y = 320, Width = 160, Height = 8, IsPlatform = true, Material = "METAL" },
                new() { X = 440, Y = 320, Width = 160, Height = 8, IsPlatform = true, Material = "METAL" },
                new() { X = 320, Y = 240, Width = 160, Height = 8, IsPlatform = true, Material = "METAL" }
            },
            PlayerSpawns = new() { new(160, 360), new(640, 360) },
            WeaponSpawns = new() { new(400, 210), new(280, 290), new(520, 290) }
        });

        // Map 1: Storage (Maps.as line 2321 & 3590, BG 1022.png)
        maps.Add(new MapDef
        {
            Id = 1,
            Name = "Storage",
            BackgroundTextureName = "1022.png",
            BoundsMinX = 0f, BoundsMinY = 0f, BoundsWidth = 800f, BoundsHeight = 450f,
            GroundBoxes = new()
            {
                new() { X = 0, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 780, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 0, Y = 0, Width = 800, Height = 20, Material = "GROUND" },
                new() { X = 0, Y = 415, Width = 800, Height = 35, Material = "GROUND" },
                new() { X = 120, Y = 290, Width = 80, Height = 125, Material = "CONCRETE" },
                new() { X = 600, Y = 290, Width = 80, Height = 125, Material = "CONCRETE" },
                new() { X = 200, Y = 290, Width = 180, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 420, Y = 290, Width = 180, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 280, Y = 190, Width = 240, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 40, Y = 210, Width = 140, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 620, Y = 210, Width = 140, Height = 10, IsPlatform = true, Material = "METAL" }
            },
            PlayerSpawns = new() { new(160, 240), new(640, 240) },
            WeaponSpawns = new() { new(400, 170), new(250, 270), new(550, 270) }
        });

        // Map 2: Rooftops (Maps.as line 596 & 3593, BG 1828.png)
        maps.Add(new MapDef
        {
            Id = 2,
            Name = "Rooftops",
            BackgroundTextureName = "1828.png",
            BoundsMinX = 0f, BoundsMinY = 0f, BoundsWidth = 800f, BoundsHeight = 450f,
            GroundBoxes = new()
            {
                new() { X = 0, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 780, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 0, Y = 400, Width = 800, Height = 50, Material = "GROUND" },
                new() { X = 40, Y = 320, Width = 180, Height = 80, Material = "GROUND" },
                new() { X = 580, Y = 320, Width = 180, Height = 80, Material = "GROUND" },
                new() { X = 260, Y = 350, Width = 280, Height = 50, Material = "GROUND" },
                new() { X = 160, Y = 240, Width = 140, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 500, Y = 240, Width = 140, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 320, Y = 170, Width = 160, Height = 10, IsPlatform = true, Material = "METAL" }
            },
            PlayerSpawns = new() { new(120, 270), new(680, 270) },
            WeaponSpawns = new() { new(400, 140), new(220, 210), new(580, 210) }
        });

        // Map 3: Police Station (Maps.as line 900 & 3596, BG 1546.png)
        maps.Add(new MapDef
        {
            Id = 3,
            Name = "Police Station",
            BackgroundTextureName = "1546.png",
            BoundsMinX = 0f, BoundsMinY = 0f, BoundsWidth = 800f, BoundsHeight = 450f,
            GroundBoxes = new()
            {
                new() { X = 0, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 780, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 0, Y = 410, Width = 800, Height = 40, Material = "GROUND" },
                new() { X = 100, Y = 310, Width = 200, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 500, Y = 310, Width = 200, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 250, Y = 220, Width = 300, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 40, Y = 180, Width = 150, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 610, Y = 180, Width = 150, Height = 10, IsPlatform = true, Material = "METAL" }
            },
            PlayerSpawns = new() { new(150, 360), new(650, 360) },
            WeaponSpawns = new() { new(400, 190), new(200, 280), new(600, 280) }
        });

        // Map 4: Hazardous (Maps.as line 1309 & 3599, BG 1687.png)
        maps.Add(new MapDef
        {
            Id = 4,
            Name = "Hazardous",
            BackgroundTextureName = "1687.png",
            BoundsMinX = 0f, BoundsMinY = 0f, BoundsWidth = 800f, BoundsHeight = 450f,
            GroundBoxes = new()
            {
                new() { X = 0, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 780, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 0, Y = 410, Width = 800, Height = 40, Material = "GROUND" },
                new() { X = 180, Y = 330, Width = 140, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 480, Y = 330, Width = 140, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 320, Y = 250, Width = 160, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 100, Y = 200, Width = 160, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 540, Y = 200, Width = 160, Height = 10, IsPlatform = true, Material = "METAL" }
            },
            PlayerSpawns = new() { new(140, 360), new(660, 360) },
            WeaponSpawns = new() { new(400, 220), new(240, 300), new(560, 300) }
        });

        // Map 5: Backstreets (Maps.as line 3278 & 3602, BG 1373.png)
        maps.Add(new MapDef
        {
            Id = 5,
            Name = "Backstreets",
            BackgroundTextureName = "1373.png",
            BoundsMinX = 0f, BoundsMinY = 0f, BoundsWidth = 800f, BoundsHeight = 450f,
            GroundBoxes = new()
            {
                new() { X = 0, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 780, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 0, Y = 405, Width = 800, Height = 45, Material = "GROUND" },
                new() { X = 80, Y = 310, Width = 160, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 560, Y = 310, Width = 160, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 280, Y = 240, Width = 240, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 140, Y = 170, Width = 180, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 480, Y = 170, Width = 180, Height = 10, IsPlatform = true, Material = "METAL" }
            },
            PlayerSpawns = new() { new(160, 360), new(640, 360) },
            WeaponSpawns = new() { new(400, 210), new(160, 280), new(640, 280) }
        });

        // Map 6: Testing Floor (Maps.as line 2828 & 3605, BG 1232.png)
        maps.Add(new MapDef
        {
            Id = 6,
            Name = "Testing Floor",
            BackgroundTextureName = "1232.png",
            BoundsMinX = 0f, BoundsMinY = 0f, BoundsWidth = 800f, BoundsHeight = 450f,
            GroundBoxes = new()
            {
                new() { X = 0, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 780, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 0, Y = 410, Width = 800, Height = 40, Material = "GROUND" },
                new() { X = 150, Y = 320, Width = 180, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 470, Y = 320, Width = 180, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 300, Y = 210, Width = 200, Height = 10, IsPlatform = true, Material = "METAL" }
            },
            PlayerSpawns = new() { new(180, 360), new(620, 360) },
            WeaponSpawns = new() { new(400, 180), new(240, 290), new(560, 290) }
        });

        // Map 7: Survival 01 (Maps.as line 1773 & 3608, BG 509.png)
        maps.Add(new MapDef
        {
            Id = 7,
            Name = "Survival",
            BackgroundTextureName = "509.png",
            BoundsMinX = 0f, BoundsMinY = 0f, BoundsWidth = 800f, BoundsHeight = 450f,
            GroundBoxes = new()
            {
                new() { X = 0, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 780, Y = 0, Width = 20, Height = 450, Material = "GROUND" },
                new() { X = 0, Y = 415, Width = 800, Height = 35, Material = "GROUND" },
                new() { X = 100, Y = 330, Width = 160, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 540, Y = 330, Width = 160, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 260, Y = 250, Width = 280, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 160, Y = 170, Width = 160, Height = 10, IsPlatform = true, Material = "METAL" },
                new() { X = 480, Y = 170, Width = 160, Height = 10, IsPlatform = true, Material = "METAL" }
            },
            PlayerSpawns = new() { new(140, 360), new(660, 360) },
            WeaponSpawns = new() { new(400, 220), new(180, 300), new(620, 300) }
        });

        return maps;
    }
}
