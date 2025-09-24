class_name BarraSalud
extends ProgressBar

func actualizar_barra(maximo: float, actual: float):
	self.max_value = maximo
	self.value = actual
