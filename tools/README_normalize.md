Normalize historias_clinicas
===========================

Este directorio contiene un script Dart para normalizar el campo `paciente_id` en la colección `historias_clinicas` de la base de datos Realtime Database de Firebase.

Cómo usar
---------

1) Exporta las variables de entorno en PowerShell (ejemplo):

```powershell
$env:FIREBASE_DB_URL = 'https://<tu-proyecto>.firebaseio.com'
# si necesitas autenticación (token):
$env:FIREBASE_AUTH = '<database-secret-or-auth-token>'
```

2) Dry-run (muestra los cambios propuestos, no aplica):

```powershell
# Desde la raíz del repo
# Requiere Dart SDK disponible (viene con Flutter)
dart run tools/normalize_historias.dart
```

3) Aplicar cambios (PATCH) — se crea un backup local antes de aplicar:

```powershell
dart run tools/normalize_historias.dart --apply
```

Notas de seguridad
------------------
- El script no contiene credenciales; debes proveer `FIREBASE_DB_URL` y opcionalmente `FIREBASE_AUTH` en variables de entorno.
- El script crea un archivo de backup con las historias actuales antes de enviar patches.
- Revisa el dry-run y el backup antes de aplicar.

Soporte y riesgos
------------------
- Si tienes reglas de seguridad en Realtime Database que requieren autenticación, provee `FIREBASE_AUTH` (token) apropiado.
- Si no quieres que el script aplique cambios automáticamente, no uses `--apply`.
