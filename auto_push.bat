@echo off
title Sincronizacao SkateMan + Git
echo ===================================================
echo  1/2: COPIANDO ARQUIVOS PESADOS PARA O GOOGLE DRIVE
echo ===================================================

for /f %%a in ('powershell -Command "Get-Date -Format 'dd-MM'"') do set DATA=%%a
set DESTINO=G:\Meu Drive\Skate-Game\lfs

echo Data identificada: %DATA%
echo.
echo Compactando a pasta 'assets'...
tar -a -c -f "%DESTINO%\assets-%DATA%.zip" "C:\Users\abraa\Documents\skate-man\assets"

echo Compactando a pasta 'addons'...
tar -a -c -f "%DESTINO%\addons-%DATA%.zip" "C:\Users\abraa\Documents\skate-man\addons"

echo.
echo Arquivos 'assets-%DATA%.zip' e 'addons-%DATA%.zip' criados no Drive!
echo.
set /p mensagem="Digite a mensagem do commit: "

git add .
git commit -m "%mensagem%"
git push origin main

echo.
echo ===================================================
echo  PROCESSO CONCLUIDO COM SUCESSO!
echo ===================================================
pause