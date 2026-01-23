## CelebrationEffects - Confetti and particle effects for victories (Story 5.2)
## Adds "Candy Crush" style dopamine rush on puzzle completion
extends CanvasLayer


const CONFETTI_COLORS: Array[Color] = [
	Color("#FF6B6B"),  # Coral red
	Color("#4ECDC4"),  # Teal
	Color("#FFE66D"),  # Yellow
	Color("#95E1D3"),  # Mint
	Color("#F38181"),  # Pink
	Color("#AA96DA"),  # Lavender
	Color("#FCBAD3"),  # Light pink
	Color("#A8D8EA"),  # Light blue
]


@onready var confetti_particles: GPUParticles2D = $ConfettiParticles
@onready var star_burst: GPUParticles2D = $StarBurst
@onready var celebration_label: Label = $CelebrationLabel


func _ready() -> void:
	# Start hidden
	visible = false
	if celebration_label:
		celebration_label.visible = false


func play_victory_celebration() -> void:
	"""Full celebration for puzzle completion"""
	visible = true
	
	# Show celebration text with animation
	if celebration_label:
		celebration_label.visible = true
		celebration_label.text = "🎉 AMAZING! 🎉"
		celebration_label.modulate.a = 0
		
		var tween := create_tween()
		tween.tween_property(celebration_label, "modulate:a", 1.0, 0.3)
		tween.tween_property(celebration_label, "scale", Vector2(1.2, 1.2), 0.2)
		tween.tween_property(celebration_label, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Emit confetti particles
	if confetti_particles:
		confetti_particles.emitting = true
	
	# Emit star burst
	if star_burst:
		star_burst.emitting = true
	
	# Auto-hide after celebration
	await get_tree().create_timer(3.0).timeout
	_hide_celebration()


func play_star_earned(star_count: int) -> void:
	"""Quick star animation for 1-3 stars"""
	visible = true
	
	if celebration_label:
		celebration_label.visible = true
		celebration_label.text = "⭐".repeat(star_count)
		celebration_label.modulate.a = 0
		
		var tween := create_tween()
		tween.tween_property(celebration_label, "modulate:a", 1.0, 0.2)
		for i in range(star_count):
			tween.tween_interval(0.15)
			tween.tween_callback(func(): _pulse_label())
	
	await get_tree().create_timer(1.5).timeout
	_hide_celebration()


func play_level_up() -> void:
	"""Animation for player level up"""
	visible = true
	
	if celebration_label:
		celebration_label.visible = true
		celebration_label.text = "✨ LEVEL UP! ✨"
		celebration_label.modulate = Color("#FFD700")
		celebration_label.modulate.a = 0
		
		var tween := create_tween()
		tween.tween_property(celebration_label, "modulate:a", 1.0, 0.3)
		tween.tween_property(celebration_label, "scale", Vector2(1.3, 1.3), 0.2)
		tween.tween_property(celebration_label, "scale", Vector2(1.0, 1.0), 0.15)
	
	if star_burst:
		star_burst.emitting = true
	
	await get_tree().create_timer(2.0).timeout
	_hide_celebration()


func _pulse_label() -> void:
	if celebration_label:
		var tween := create_tween()
		tween.tween_property(celebration_label, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(celebration_label, "scale", Vector2(1.0, 1.0), 0.1)


func _hide_celebration() -> void:
	if celebration_label:
		var tween := create_tween()
		tween.tween_property(celebration_label, "modulate:a", 0.0, 0.3)
		await tween.finished
		celebration_label.visible = false
	
	visible = false
