# settings_menu.gd
class_name SettingsMenu
extends Control

signal back_requested

@onready var sfx_slider: HSlider = %SFXSlider

func _ready():
	sfx_slider.value = SettingsManager.sfx_volume / 10.0
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)

func _on_sfx_slider_value_changed(value: float):
	SettingsManager.sfx_volume = int(value) * 10

func _on_back_button_pressed():
	back_requested.emit()
