# Toastr Flutter Example

Este ejemplo demuestra todas las características del package `toastr_flutter`.

## Cómo ejecutar

```bash
cd example
flutter run
```

## Características demostradas

### 1. Métodos rápidos
- `ToastrHelper.success(context, 'mensaje')`
- `ToastrHelper.error(context, 'mensaje')`
- `ToastrHelper.warning(context, 'mensaje')`
- `ToastrHelper.info(context, 'mensaje')`

### 2. Configuración personalizada
- Posicionamiento (top/bottom + left/center/right)
- Animaciones de entrada y salida
- Duración personalizable
- Barras de progreso
- Botones de cierre
- Prevención de duplicados

### 3. Gestión de notificaciones
- Limpiar todas las notificaciones
- Limpiar solo la última notificación

## Uso básico

```dart
import 'package:flutter/material.dart';
import 'package:toastr_flutter/toastr.dart';

// Dentro de cualquier widget con BuildContext
ElevatedButton(
  onPressed: () => ToastrHelper.success(context, '¡Éxito!'),
  child: Text('Mostrar Éxito'),
)
```

## Sin inicialización requerida

A diferencia de otras versiones, **no necesitas inicializar nada**. Solo pasa el `context` como primer parámetro, igual que con `ScaffoldMessenger.of(context).showSnackBar()`.
