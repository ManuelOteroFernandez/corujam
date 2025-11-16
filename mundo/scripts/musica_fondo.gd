extends AudioStreamPlayer
func _ready():
	self.play()
	self.finished.connect(func():
			self.play()
	)
