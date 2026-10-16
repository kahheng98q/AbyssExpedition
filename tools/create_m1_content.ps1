$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
function Save-Text($path, $content) {
    $target = Join-Path $projectRoot $path
    New-Item -ItemType Directory -Force (Split-Path $target -Parent) | Out-Null
    [IO.File]::WriteAllText($target, $content, [Text.UTF8Encoding]::new($false))
}
function Scene($path, $script, $type, $nodeName) {
    Save-Text $path @"
[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://$script" id="1"]
[node name="$nodeName" type="$type"]
script = ExtResource("1")
"@
}
Scene 'scenes/combat/projectile.tscn' 'scripts/combat/projectile.gd' 'Node2D' 'Projectile'
Scene 'scenes/combat/melee_arc.tscn' 'scripts/combat/melee_arc.gd' 'Node2D' 'MeleeArc'
Scene 'scenes/combat/telegraph.tscn' 'scripts/combat/telegraph.gd' 'Node2D' 'Telegraph'
Scene 'scenes/pickups/xp_gem.tscn' 'scripts/progression/xp_pickup.gd' 'Node2D' 'XPGem'
Scene 'scenes/world/coast_field.tscn' 'scripts/world/coast_field.gd' 'Node2D' 'CoastField'
foreach ($pair in @(@('main_menu','main_menu'), @('character_selection','character_selection'), @('combat_hud','combat_hud'), @('level_up','level_up'), @('pause_menu','pause_menu'), @('run_results','run_results'))) {
    Scene "scenes/ui/$($pair[0]).tscn" "scripts/ui/$($pair[1]).gd" 'Control' $pair[0]
}
foreach ($role in @('hero','enemy','boss')) {
Save-Text "scenes/actors/$role.tscn" @"
[gd_scene load_steps=4 format=3]
[ext_resource type="Script" path="res://scripts/combat/actor.gd" id="1"]
[ext_resource type="Script" path="res://scripts/combat/actor_presentation.gd" id="2"]
[sub_resource type="CircleShape2D" id="body"]
radius = 8.0
[node name="$role" type="CharacterBody2D"]
collision_layer = 0
collision_mask = 1
script = ExtResource("1")
[node name="Body" type="CollisionShape2D" parent="."]
shape = SubResource("body")
[node name="Presentation" type="Node2D" parent="."]
script = ExtResource("2")
"@
}
$heroes = @(
 @('aren','Aren','swordsman','arc',48,240,'sword','Color(0.35, 0.86, 0.85, 1)','Short sweeping arc. Close in to hit several enemies.',250),
 @('lia','Lia','archer','straight',160,240,'bow','Color(0.55, 0.9, 0.42, 1)','Straight arrows. Align your shots with moving enemies.',150),
 @('milo','Milo','mage','homing',160,180,'star','Color(0.74, 0.57, 1, 1)','Homing stars. Keep enemies within casting range.',150)
)
foreach ($h in $heroes) {
Save-Text "data/weapons/$($h[3]).tres" @"
[gd_resource type="Resource" script_class="WeaponDefinition" load_steps=3 format=3]
[ext_resource type="Script" path="res://scripts/data/weapon_definition.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/combat/projectile.tscn" id="2"]
[resource]
script = ExtResource("1")
id = &"$($h[3])"
mode = "$($h[3])"
reach = $($h[4]).0
speed = $($h[5]).0
projectile_scene = ExtResource("2")
"@
Save-Text "data/professions/$($h[2]).tres" @"
[gd_resource type="Resource" script_class="ProfessionDefinition" load_steps=7 format=3]
[ext_resource type="Script" path="res://scripts/characters/profession_definition.gd" id="1"]
[ext_resource type="Script" path="res://scripts/data/stat_block.gd" id="2"]
[ext_resource type="Script" path="res://scripts/data/visual_set.gd" id="3"]
[ext_resource type="Resource" path="res://data/weapons/$($h[3]).tres" id="4"]
[sub_resource type="Resource" id="stats"]
script = ExtResource("2")
reach = $($h[4]).0
damage = 36.0
frequency = 1.2
max_health = $($h[9]).0
[sub_resource type="Resource" id="visual"]
script = ExtResource("3")
id = &"$($h[2])_visual"
silhouette = "$($h[6])"
palette = $($h[7])
[resource]
script = ExtResource("1")
id = &"$($h[2])"
base_id = &"$($h[2])"
starting_stats = SubResource("stats")
weapon = ExtResource("4")
visual_set = SubResource("visual")
"@
Save-Text "data/characters/$($h[0]).tres" @"
[gd_resource type="Resource" script_class="CharacterDefinition" load_steps=3 format=3]
[ext_resource type="Script" path="res://scripts/characters/character_definition.gd" id="1"]
[ext_resource type="Resource" path="res://data/professions/$($h[2]).tres" id="2"]
[resource]
script = ExtResource("1")
id = &"$($h[0])"
display_name = "$($h[1])"
base_profession = ExtResource("2")
description = "$($h[8])"
"@
}
$enemies = @(
 @('saltbound_thrall','pursuit',35,3,30,'diamond','Color(0.55, 0.65, 0.63, 1)',1.0),
 @('skittering_brinejaw','rush',30,5,34,'crab','Color(1, 0.48, 0.32, 1)',1.0),
 @('lantern_cantor','ranged',30,3,28,'lantern','Color(1, 0.8, 0.36, 1)',1.0),
 @('shellbound_husk','armored',70,5,22,'shell','Color(0.48, 0.63, 0.83, 1)',0.65),
 @('reef_broodmother','summoner',70,4,20,'tentacles','Color(0.92, 0.48, 0.72, 1)',1.0),
 @('broodling','broodling',15,2,45,'triangle','Color(0.86, 0.62, 0.77, 1)',1.0)
)
foreach ($e in $enemies) {
Save-Text "data/enemies/$($e[0]).tres" @"
[gd_resource type="Resource" script_class="EnemyDefinition" load_steps=6 format=3]
[ext_resource type="Script" path="res://scripts/data/enemy_definition.gd" id="1"]
[ext_resource type="Script" path="res://scripts/data/stat_block.gd" id="2"]
[ext_resource type="Script" path="res://scripts/data/visual_set.gd" id="3"]
[sub_resource type="Resource" id="stats"]
script = ExtResource("2")
max_health = $($e[2]).0
damage = $($e[3]).0
speed = $($e[4]).0
[sub_resource type="Resource" id="visual"]
script = ExtResource("3")
id = &"$($e[0])_visual"
silhouette = "$($e[5])"
palette = $($e[6])
[resource]
script = ExtResource("1")
id = &"$($e[0])"
behavior_kind = "$($e[1])"
stats = SubResource("stats")
visual_set = SubResource("visual")
damage_reduction = $($e[7].ToString([Globalization.CultureInfo]::InvariantCulture))
summon_definition = &"broodling"
"@
}
$upgrades = @(
 @('might','Might','Damage +10% of starting damage.',0,'percent','damage',0.10,0),
 @('quick_hands','Quick Hands','Attack frequency +10%. Maximum 5.',5,'percent','frequency',0.10,0),
 @('reach','Reach','Attack and targeting range +15%. Maximum 5.',5,'percent','reach',0.15,0),
 @('echo_strike','Echo Strike','Extra shot, or a 50% follow-up arc. Maximum 2.',2,'echo','echo',1.0,0),
 @('ironhide','Ironhide','Incoming hits deal 1 less damage. Maximum 5.',5,'flat','defense',1.0,0),
 @('vitality','Vitality','Maximum HP +10% of starting HP. Heal that increase.',0,'percent','max_health',0.10,0),
 @('swift_boots','Swift Boots','Movement speed +10%. Maximum 3.',3,'percent','speed',0.10,0),
 @('magnet','Magnet','Gem pickup radius +25%. Maximum 5.',5,'percent','pickup_radius',0.25,0),
 @('force','Force','Knockback strength +20%. Maximum 3.',3,'percent','knockback',0.20,0),
 @('ember_touch','Ember Touch','Hits burn for 30% damage over 3 seconds. Refreshes.',1,'burn','burn',0.30,180),
 @('frost_mark','Frost Mark','Hits slow susceptible enemies 20% for 2 seconds.',1,'frost','frost',0.20,120),
 @('battle_mend','Battle Mend','Heal 20% maximum HP. Damage +5% of starting damage.',0,'heal','damage',0.05,0)
)
foreach ($u in $upgrades) {
    $fallback = if ($u[3] -eq 0) { 'true' } else { 'false' }
Save-Text "data/upgrades/$($u[0]).tres" @"
[gd_resource type="Resource" script_class="UpgradeDefinition" load_steps=4 format=3]
[ext_resource type="Script" path="res://scripts/data/upgrade_definition.gd" id="1"]
[ext_resource type="Script" path="res://scripts/data/effect_definition.gd" id="2"]
[sub_resource type="Resource" id="effect"]
script = ExtResource("2")
kind = &"$($u[4])"
stat_category = &"$($u[5])"
amount = $($u[6].ToString([Globalization.CultureInfo]::InvariantCulture))
duration_ticks = $($u[7])
[resource]
script = ExtResource("1")
id = &"$($u[0])"
label = "$($u[1])"
description = "$($u[2])"
max_stacks = $($u[3])
fallback = $fallback
effects = Array[ExtResource("2")]([SubResource("effect")])
"@
}
Save-Text 'data/encounters/coast_waves.tres' @'
[gd_resource type="Resource" script_class="WaveSchedule" load_steps=2 format=3]
[ext_resource type="Script" path="res://scripts/data/wave_schedule.gd" id="1"]
[resource]
script = ExtResource("1")
phases = Array[Dictionary]([
{"start": 0, "end": 7200, "count": 4, "ids": ["saltbound_thrall"], "weights": [100], "introduce": []},
{"start": 7200, "end": 14400, "count": 6, "ids": ["saltbound_thrall", "skittering_brinejaw"], "weights": [70, 30], "introduce": ["skittering_brinejaw"]},
{"start": 14400, "end": 21600, "count": 8, "ids": ["saltbound_thrall", "skittering_brinejaw", "lantern_cantor"], "weights": [50, 25, 25], "introduce": ["lantern_cantor"]},
{"start": 21600, "end": 28800, "count": 10, "ids": ["saltbound_thrall", "skittering_brinejaw", "lantern_cantor", "shellbound_husk"], "weights": [40, 20, 20, 20], "introduce": ["shellbound_husk"]},
{"start": 28800, "end": 32400, "count": 12, "ids": ["saltbound_thrall", "skittering_brinejaw", "lantern_cantor", "shellbound_husk", "reef_broodmother"], "weights": [30, 20, 20, 20, 10], "introduce": ["reef_broodmother"]}])
'@
Save-Text 'data/encounters/coast_field.tres' @'
[gd_resource type="Resource" script_class="FieldDefinition" load_steps=3 format=3]
[ext_resource type="Script" path="res://scripts/data/field_definition.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/world/coast_field.tscn" id="2"]
[resource]
script = ExtResource("1")
collision_scene = ExtResource("2")
'@
Save-Text 'data/encounters/tidebound_hierophant.tres' @'
[gd_resource type="Resource" script_class="BossDefinition" load_steps=10 format=3]
[ext_resource type="Script" path="res://scripts/data/boss_definition.gd" id="1"]
[ext_resource type="Script" path="res://scripts/data/stat_block.gd" id="2"]
[ext_resource type="Script" path="res://scripts/data/visual_set.gd" id="3"]
[ext_resource type="Script" path="res://scripts/data/boss_pattern.gd" id="4"]
[sub_resource type="Resource" id="stats"]
script = ExtResource("2")
max_health = 1200.0
damage = 20.0
speed = 18.0
[sub_resource type="Resource" id="visual"]
script = ExtResource("3")
id = &"hierophant_visual"
silhouette = "crown"
palette = Color(0.93, 0.36, 0.5, 1)
[sub_resource type="Resource" id="cone"]
script = ExtResource("4")
id = &"tide_cone"
geometry = "cone"
radius = 150.0
angle = 70.0
windup_ticks = 60
[sub_resource type="Resource" id="circle"]
script = ExtResource("4")
id = &"ground_eruption"
geometry = "circle"
radius = 48.0
windup_ticks = 75
[resource]
script = ExtResource("1")
stats = SubResource("stats")
visual_set = SubResource("visual")
patterns = Array[ExtResource("4")]([SubResource("cone"), SubResource("circle")])
'@
Write-Output 'Generated M1 content and leaf scenes.'
