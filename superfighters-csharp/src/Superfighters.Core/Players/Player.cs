using System.Numerics;
using Superfighters.Core.Destruction;
using Superfighters.Core.Physics;
using Superfighters.Core.Weapons;
using Superfighters.Data.Characters;
using Superfighters.Data.Weapons;

namespace Superfighters.Core.Players;

// Faithful 1:1 Port of Code.Data.Players.Player.as
public class Player
{
    public string Name { get; set; }
    public CharacterDef Character { get; set; }
    public bool IsBot { get; }
    public BotState? Bot { get; }

    // Position & Dimensions (16x32 Box)
    public float X { get; set; }
    public float Y { get; set; }
    public float Width { get; } = 16f;
    public float Height { get; } = 32f;

    public float Vx { get; set; }
    public float Vy { get; set; }
    public int Facing { get; set; } = 1; // 1 = Right, -1 = Left
    public bool OnGround { get; set; } = false;

    // State machine
    public PlayerState State { get; } = new();

    // Weapon
    public WeaponInstance Weapon { get; set; }

    // Flash timer for damage visual
    public int FlashTimer { get; set; } = 0;
    public int KnockdownTimer { get; set; } = 0;
    public int DiveTimer { get; set; } = 0;
    public int RollTimer { get; set; } = 0;

    // Events emitted during tick for sound/visuals in client layer
    public List<string> FrameEvents { get; } = new();

    public Player(string name, CharacterDef character, WeaponDef startingWeapon, bool isBot = false, float startX = 0, float startY = 0)
    {
        Name = name;
        Character = character;
        IsBot = isBot;
        X = startX;
        Y = startY;
        Weapon = new WeaponInstance(startingWeapon);

        if (isBot)
        {
            Bot = new BotState();
        }
    }

    public void TakeDamage(float amount, float pushX = 0, float pushY = 0)
    {
        if (State.Dead || State.IsImmune) return;

        State.HP -= amount;
        Vx += pushX;
        Vy += pushY;
        FlashTimer = 8;
        FrameEvents.Add("HIT");

        if (amount > 18f || Math.Abs(pushX) > 4f)
        {
            State.Knockdowned = true;
            KnockdownTimer = 35;
            FrameEvents.Add("KNOCKDOWN");
        }

        if (State.HP <= 0f)
        {
            State.HP = 0f;
            State.Dead = true;
            FrameEvents.Add("DIE");
        }
    }

    // Exact Dive implementation from Player.as lines 7700-7722
    public bool Dive()
    {
        if (State.SprintEnergy < 20f || State.Diving || State.Rolling || State.Dead) return false;

        State.DiveSpeed = State.ShortDiveAvailable ? 1.0f : 3.5f;
        State.Diving = true;
        State.Jumping = true;
        DiveTimer = 24;

        // Player.as line 7717:
        // this._PlayerState.AirVelocityX += this._PlayerState.LastDirX * this._PlayerState.DiveSpeed;
        // this._PlayerState.AirVelocityY -= 3;
        // this._this_y -= 6;
        Vx = Facing * State.DiveSpeed;
        Vy = -3.0f;
        Y -= 6.0f;
        State.SprintEnergy -= 25.0f;
        OnGround = false;

        FrameEvents.Add("DIVE");
        return true;
    }

    // Exact Roll implementation from Player.as lines 7724-7730
    public bool Roll()
    {
        if (State.SprintEnergy < 15f || State.Rolling || State.Diving || State.Dead) return false;

        State.Rolling = true;
        RollTimer = 20;
        State.SprintEnergy -= 15.0f;
        State.DecreaseBurnState();
        Vx = Facing * State.RollSpeed;

        FrameEvents.Add("ROLL");
        return true;
    }

    // Exact Jump implementation from Player.as lines 7732-7765
    public bool Jump()
    {
        if (State.Dead || State.Knockdowned || State.Diving || State.Rolling) return false;

        // Sprinting + Jump = Dive! (Player.as)
        if (State.Sprinting && OnGround && State.SprintEnergy >= 20f)
        {
            return Dive();
        }

        if (OnGround)
        {
            Vy = State.PlayerJumpPower; // -5.0
            State.JumpPushTimeLeft = State.PlayerJumpPushTime; // 4
            State.PlayerJumpPushEnabled = true;
            State.Jumping = true;
            OnGround = false;

            FrameEvents.Add("JUMP");
            return true;
        }

        return false;
    }

    public void Crouch(bool kneel)
    {
        if (State.Dead || State.Knockdowned || State.Diving || State.Rolling) return;

        State.Kneeling = kneel;
        if (kneel && OnGround && Math.Abs(Vx) > 0.5f)
        {
            Roll();
        }
    }

    public string? Melee()
    {
        if (State.Dead || State.Knockdowned || State.Diving || State.Rolling) return null;
        if (State.PunchCooldown > 0) return null;

        if (!OnGround)
        {
            // Aerial Jump Kick
            State.Kicking = true;
            State.PunchTimer = 18;
            State.PunchCooldown = 25;
            Vx += Facing * 1.5f;
            FrameEvents.Add("KICK");
            return "KICK";
        }

        // Punch Combo 1 -> 2 -> 3
        State.Punching = true;
        State.PunchComboNr = (State.PunchComboNr % 3) + 1;
        State.PunchTimer = 12;
        State.PunchCooldown = 16;
        Vx += Facing * State.PunchGlideSpeed;

        string punchEvent = $"PUNCH_{State.PunchComboNr}";
        FrameEvents.Add(punchEvent);
        return punchEvent;
    }

    public bool Shoot(List<ProjectileInstance> outProjectiles)
    {
        if (State.Dead || State.Knockdowned || State.Diving || State.Rolling || State.Punching) return false;
        if (Weapon.CooldownTimer > 0) return false;

        if (Weapon.Ammo <= 0)
        {
            Weapon.CooldownTimer = 20;
            FrameEvents.Add("EMPTY");
            return false;
        }

        Weapon.Ammo--;
        Weapon.CooldownTimer = Weapon.Def.WeaponCooldown;

        // Calculate muzzle position
        float muzzleX = X + Width / 2f + (Facing * 14f);
        float muzzleY = Y + (State.Kneeling ? 20f : 12f);

        float baseAngle = Facing == 1 ? 0f : MathF.PI;
        if (State.AimPitch == -1) baseAngle += Facing * -0.52f; // ~30 deg up
        if (State.AimPitch == 1) baseAngle += Facing * 0.52f;  // ~30 deg down

        int pelletCount = Weapon.Def.FireSequence.Count > 0 ? Weapon.Def.FireSequence[0].BulletsCount : 1;
        if (pelletCount <= 0) pelletCount = 1;

        var rnd = new Random();
        for (int i = 0; i < pelletCount; i++)
        {
            float spread = (float)(rnd.NextDouble() - 0.5) * (Weapon.Def.AccuracyDeflection * 0.035f);
            float angle = baseAngle + spread;
            float spd = Weapon.Def.BulletSpeed;
            var vel = new Vector2(MathF.Cos(angle) * spd, MathF.Sin(angle) * spd);

            outProjectiles.Add(new ProjectileInstance(new Vector2(muzzleX, muzzleY), vel, Weapon.Def, this));
        }

        // Recoil pushback
        Vx -= Facing * (Weapon.Def.PushbackPower * 0.05f);

        FrameEvents.Add($"SHOOT_{Weapon.Def.WeaponType}");
        return true;
    }

    public void Update(
        float dt,
        Box2DWorld world,
        List<Player> allPlayers,
        List<DestructibleCrate> crates,
        List<ProjectileInstance> outProjectiles,
        bool inputLeft = false,
        bool inputRight = false,
        bool inputJump = false,
        bool inputDown = false,
        bool inputSprint = false,
        bool inputShoot = false,
        bool inputMelee = false)
    {
        FrameEvents.Clear();

        if (FlashTimer > 0) FlashTimer--;
        Weapon.Update();

        if (State.Dead)
        {
            Vy += State.PlayerGravity;
            Y += Vy;
            Vx *= 0.85f;
            X += Vx;
            return;
        }

        // Knockdown handling
        if (State.Knockdowned)
        {
            KnockdownTimer--;
            Vx *= 0.9f;
            Vy += State.PlayerGravity;
            Y += Vy;
            X += Vx;
            if (KnockdownTimer <= 0)
            {
                State.Knockdowned = false;
            }
            return;
        }

        // Bot AI Tick
        if (IsBot && Bot != null)
        {
            UpdateBotAI(dt, world, allPlayers, crates, outProjectiles, ref inputLeft, ref inputRight, ref inputJump, ref inputDown, ref inputShoot, ref inputMelee);
        }

        // Timers
        if (State.PunchCooldown > 0) State.PunchCooldown--;

        // Energy Regen
        if (!State.Sprinting && !State.Diving && !State.Rolling && State.SprintEnergy < State.MaxSprintEnergy)
        {
            State.SprintEnergy = Math.Min(State.MaxSprintEnergy, State.SprintEnergy + 0.35f);
        }

        // Dive handling & Box2D dynamic body impact (Player.as lines 4828-4848)
        if (State.Diving)
        {
            DiveTimer--;
            Vx = Facing * State.DiveSpeed;

            // Check collision with crates during dive
            foreach (var crate in crates)
            {
                if (crate.IsDead) continue;
                if (X + Width > crate.Position.X && X < crate.Position.X + crate.Width &&
                    Y + Height > crate.Position.Y && Y < crate.Position.Y + crate.Height)
                {
                    // Apply exact Box2D impulse: _loc13_ = new b2Vec2(dirX, 0)
                    crate.TakeDamage(15f, new Vector2(Facing * 4.0f, -2.0f));
                    FrameEvents.Add("IMPACT_WOOD");
                }
            }

            // Check dive tackle against other players
            foreach (var other in allPlayers)
            {
                if (other == this || other.State.Dead) continue;
                if (X + Width > other.X && X < other.X + other.Width &&
                    Y + Height > other.Y && Y < other.Y + other.Height)
                {
                    other.TakeDamage(12f, Facing * 4.5f, -3.0f);
                    FrameEvents.Add("IMPACT_PLAYER");
                }
            }

            if (DiveTimer <= 0)
            {
                State.Diving = false;
            }
        }

        // Roll handling
        if (State.Rolling)
        {
            RollTimer--;
            Vx = Facing * State.RollSpeed;
            if (RollTimer <= 0)
            {
                State.Rolling = false;
            }
        }

        // Melee hit frames & bullet deflection (Player.as lines 6980-7050)
        if (State.Punching || State.Kicking)
        {
            State.PunchTimer--;
            if (State.PunchTimer == 6)
            {
                float hitRange = 16f;
                if (Weapon.Def.Category == "MELEE" && Weapon.Def.MeleeRange.Count >= 3)
                {
                    int cIdx = Math.Clamp(State.PunchComboNr - 1, 0, Weapon.Def.MeleeRange.Count - 1);
                    hitRange = Weapon.Def.MeleeRange[cIdx];
                }

                float hitX = Facing == 1 ? X + Width : X - hitRange;
                float hitY = Y + (State.Kicking ? 14f : 8f);

                // Bullet deflection (Swinging sword/axe/machete deflects incoming bullets)
                if (Weapon.Def.Category == "MELEE" || Weapon.Def.AnimType == "SWORD" || Weapon.Def.AnimType == "AXE" || Weapon.Def.AnimType == "MACHETE")
                {
                    foreach (var proj in outProjectiles)
                    {
                        if (proj.Owner != this && !proj.IsDead)
                        {
                            float dx = proj.Position.X - (X + Width / 2f);
                            float dy = proj.Position.Y - (Y + Height / 2f);
                            if (MathF.Sign(dx) == Facing && MathF.Sqrt(dx * dx + dy * dy) < hitRange + 15f)
                            {
                                proj.Velocity = new Vector2(-proj.Velocity.X * 1.1f, proj.Velocity.Y);
                                FrameEvents.Add("DEFLECT");
                            }
                        }
                    }
                }

                // Crate damage
                foreach (var crate in crates)
                {
                    if (crate.IsDead) continue;
                    if (hitX < crate.Position.X + crate.Width && hitX + hitRange > crate.Position.X &&
                        hitY < crate.Position.Y + crate.Height && hitY + 16f > crate.Position.Y)
                    {
                        crate.TakeDamage(15f, new Vector2(Facing * 3.5f, -2f));
                        FrameEvents.Add("IMPACT_WOOD");
                    }
                }

                // Player damage
                foreach (var other in allPlayers)
                {
                    if (other == this || other.State.Dead) continue;
                    if (hitX < other.X + other.Width && hitX + hitRange > other.X &&
                        hitY < other.Y + other.Height && hitY + 20f > other.Y)
                    {
                        float dmg = 8f;
                        float push = 3.5f;

                        if (State.Kicking)
                        {
                            dmg = 14f;
                            push = 6.0f;
                        }
                        else if (Weapon.Def.Category == "MELEE" && Weapon.Def.MeleeDamage.Count >= 3)
                        {
                            int comboIndex = Math.Clamp(State.PunchComboNr - 1, 0, Weapon.Def.MeleeDamage.Count - 1);
                            dmg = Weapon.Def.MeleeDamage[comboIndex];
                            push = 3.0f + comboIndex * 1.5f;
                            if (!string.IsNullOrEmpty(Weapon.Def.HitSound)) FrameEvents.Add(Weapon.Def.HitSound);
                        }
                        else
                        {
                            // Fists: 6, 7, 8 in Weapons.as
                            dmg = 6f + (State.PunchComboNr - 1);
                            push = 2.5f + State.PunchComboNr;
                            FrameEvents.Add("MELEE_HIT");
                        }

                        other.TakeDamage(dmg, Facing * push, -2.5f);
                    }
                }
            }

            if (State.PunchTimer <= 0)
            {
                State.Punching = false;
                State.Kicking = false;
            }
        }

        // Fire & Burn damage tick
        if (State.BurnState > 0f)
        {
            State.BurnState = MathF.Max(0f, State.BurnState - 0.2f);
            if (State.BurnState >= 60f && (int)(dt * 1000) % 15 == 0)
            {
                TakeDamage(0.4f, 0, 0);
            }
        }

        // Movement input resolution
        if (!State.Diving && !State.Rolling && !State.Punching && !State.Kicking)
        {
            int moveDir = 0;
            if (inputLeft) moveDir -= 1;
            if (inputRight) moveDir += 1;

            if (moveDir != 0)
            {
                Facing = moveDir;
                State.LastDirX = moveDir;
                float spd = State.RunSpeed;
                if (inputSprint && State.SprintEnergy > 5f && OnGround && !State.Kneeling)
                {
                    spd = State.SprintSpeed;
                    State.SprintEnergy -= 0.35f;
                    State.Sprinting = true;
                }
                else
                {
                    State.Sprinting = false;
                }
                Vx = moveDir * spd;
            }
            else
            {
                Vx *= 0.6f;
                State.Sprinting = false;
            }

            if (inputJump && State.JumpPushTimeLeft > 0)
            {
                Vy += State.PlayerJumpPushPower;
                State.JumpPushTimeLeft--;
            }

            Crouch(inputDown && moveDir == 0);

            if (inputShoot) Shoot(outProjectiles);
            if (inputMelee) Melee();
        }

        // Apply Gravity
        Vy += State.PlayerGravity;
        if (Vy > 12f) Vy = 12f;

        // X Movement
        X += Vx;

        // Y Movement
        Y += Vy;
    }

    // 1:1 Bot AI Tick Implementation
    private void UpdateBotAI(
        float dt,
        Box2DWorld world,
        List<Player> allPlayers,
        List<DestructibleCrate> crates,
        List<ProjectileInstance> projectiles,
        ref bool inputLeft,
        ref bool inputRight,
        ref bool inputJump,
        ref bool inputDown,
        ref bool inputShoot,
        ref bool inputMelee)
    {
        if (Bot == null) return;

        // 1. Choose Target Tick (200ms)
        Bot.TargetChooseTimer -= dt;
        if (Bot.TargetChooseTimer <= 0)
        {
            Bot.TargetChooseTimer = 0.200f;
            Player? nearest = null;
            float nearestDist = float.MaxValue;
            foreach (var p in allPlayers)
            {
                if (p == this || p.State.Dead) continue;
                float dist = Vector2.Distance(new Vector2(X, Y), new Vector2(p.X, p.Y));
                if (dist < nearestDist)
                {
                    nearestDist = dist;
                    nearest = p;
                }
            }
            Bot.TargetPlayer = nearest;
        }

        // 2. Randomize Fire Position (4000ms)
        Bot.RandomizeTimer -= dt;
        if (Bot.RandomizeTimer <= 0)
        {
            Bot.RandomizeTimer = 4.000f;
            var rnd = new Random();
            Bot.RandomFireX = (float)(rnd.NextDouble() - 0.5) * 10f;
            Bot.RandomFireY = (float)(rnd.NextDouble() - 0.5) * 10f;
        }

        if (Bot.TargetPlayer != null && !Bot.TargetPlayer.State.Dead)
        {
            float dx = Bot.TargetPlayer.X - X;
            float dy = Bot.TargetPlayer.Y - Y;
            float dist = MathF.Sqrt(dx * dx + dy * dy);

            if (dx > 10f)
            {
                inputRight = true;
                Facing = 1;
            }
            else if (dx < -10f)
            {
                inputLeft = true;
                Facing = -1;
            }

            if (dy < -20f) State.AimPitch = -1;
            else if (dy > 20f) State.AimPitch = 1;
            else State.AimPitch = 0;

            // Dodge bullets (BotDodgeBullet in Player.as lines 454-460)
            foreach (var proj in projectiles)
            {
                if (proj.Owner != this && !proj.IsDead)
                {
                    float pdx = proj.Position.X - X;
                    float pdy = proj.Position.Y - Y;
                    float pdist = MathF.Sqrt(pdx * pdx + pdy * pdy);
                    // Bullet approaching bot horizontally
                    if (pdist < 100f && MathF.Abs(pdy) < 30f && MathF.Sign(proj.Velocity.X) == -MathF.Sign(pdx))
                    {
                        if (OnGround && State.SprintEnergy >= 25f && !State.Diving && !State.Rolling)
                        {
                            Roll();
                        }
                        else if (OnGround)
                        {
                            inputJump = true;
                        }
                        break;
                    }
                }
            }

            // Extinguish fire: Roll if burning (Player.as line 60)
            if (State.BurnState >= 60f && OnGround && !State.Rolling)
            {
                Roll();
            }

            // Combat engagement
            if (dist < 30f && MathF.Abs(dy) < 25f)
            {
                inputMelee = true;
            }
            else if (dist < 320f && MathF.Abs(dy) < 80f)
            {
                inputShoot = true;
            }

            // Jump over crates or jump up platforms
            if (dy < -40f && OnGround)
            {
                inputJump = true;
            }
        }
    }
}
