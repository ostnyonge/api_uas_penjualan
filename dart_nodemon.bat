@echo off
:start
dart run bin\server.dart
timeout /t 1 > nul
goto start
