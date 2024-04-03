extends Node


var ground_rapture = preload('res://ground_rapture.tscn')
var air_rapture = preload('res://air_rapture.tscn')
var rapture_type = [ground_rapture,ground_rapture,ground_rapture,air_rapture,air_rapture]
var obstacles : Array
var air_heights := [400, 780]

const PLAYER_START_POS := Vector2(70, 568)
const CAM_START_POS := Vector2(576,324)
 
var difficulty := 0
const MAX_DIFFICULTY : int = 3

@onready var start_sounds = [$lie_start1,$lie_start2,$lie_start3,$lie_start4]

var score : int
const SCORE_MODIFIER := 7
var speed : float
const SPEED_MODIFIER := 5000
const START_SPEED : float = 10
const MAX_SPEED : int = 20
var screen_size : Vector2i
var game_running = true
var last_obs


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	$GameOver.get_node("Button").pressed.connect(new_game)
	$GameOver.hide()
	new_game()


func new_game():
	$AudioStreamPlayer.playing = false
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	#delete all obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	#reset the nodes
	$Player.position = PLAYER_START_POS
	$Player.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$ground.position = Vector2i(0, 0)
	
	#reset hud and game over screen
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
			
		adjust_difficulty()
		generate_obs()
		
		$Player.position.x += speed
		$Camera2D.position.x += speed
	
		
		score += speed
		show_score()
		
		#update ground position
		if $Camera2D.position.x - $ground.position.x > 1152 * 1.5:
			$ground.position.x += 1152
		#remove obstacles
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - 1152):
				remove_obs(obs)
					
	else:
		if Input.is_action_pressed("ui_accept"):
			$AudioStreamPlayer.playing = true
			var rando = randi_range(0,3)
			start_sounds[rando].playing = true
			game_running = true
			$HUD.get_node("StartLabel").hide()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score/SCORE_MODIFIER)

func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(150, 500):
		var obs_type = rapture_type[randi() % rapture_type.size()]
		var max_obs = difficulty + 1
		var obs
		for i in range(randi() % max_obs + 1): 
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var ground_height = $BG/ParallaxLayer5.get_node("Sprite2D").texture.get_height()
			var obs_x : int = 1152 + score + 100 + (i * 100) + randi_range(0, 400)
			var obs_y : int = 648 - ground_height*2 - (obs_height * obs_scale.y) 
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				#generate bird obstacles
				obs = air_rapture.instantiate()
				var obs_x : int = 1152 + score + 100
				var obs_y : int = air_heights[randi() % air_heights.size()]
				add_obs(obs, obs_x, obs_y)
		
func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	#trigger 
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
	
func hit_obs(body):
	if body.name == "Player":
		game_over()
		

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func adjust_difficulty():
	difficulty = score / (SPEED_MODIFIER * (difficulty + 1))
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY
	
	
func game_over():
	$deathsfx.playing = true
	$liedeath.playing = true
	get_tree().paused = true
	game_running = false
	$GameOver.show()
	$GameOver.get_node("finalScore").text  = "SCORE: " + str(score/SCORE_MODIFIER)
	
