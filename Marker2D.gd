extends Marker2D

const maxSpawns: int = 10
const maxActive: int = 3
var enemy_scene: PackedScene = preload("res://slime.tscn")
var spawnReady: bool = true

var activeMobs: int = 0
var spawnedMobs: int = 0


func spawnEnemy():
	# If timer elapsed, max active mobs and max spawns aren't exceeded
	if spawnReady && (activeMobs < maxActive) && (spawnedMobs < maxSpawns):
		# Add enemy instance to the scene
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		
		# Connect enemies death signal to _on_enemy_death function
		enemy.death.connect(_on_enemy_death)
		
		# Spawn enemy every random seconds (0 to 10 in increments of 2)
		$SpawnTimer.wait_time = (randi() % 10) + 2
		$SpawnTimer.start()
		
		# increase mob counter
		activeMobs += 1
		spawnedMobs += 1
		spawnReady = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	spawnEnemy()
	
func _on_enemy_death():
	# Decrease active mob counter on mob death
	activeMobs -= 1

func _on_spawn_timer_timeout():
	spawnReady = true
