@echo off
title Sincronizacao SkateMan + Git
echo ===================================================
echo  1/2: COPIANDO ARQUIVOS PESADOS PARA O GOOGLE DRIVE
echo ===================================================

:: O comando robocopy sincroniza apenas o que mudou de forma incremental.
:: /MIR = Espelha as pastas (adiciona novos e remove apagados na origem).
:: /R:1 /W:1 = Tenta refazer a copia no maximo 1 vez e espera 1 segundo em caso de arquivo aberto.
:: /NFL /NDL = Esconde a lista individual de milhares de arquivos no terminal para poluir menos a tela.

robocopy "C:\Users\abraa\Documents\skate-man\assets" "G:\Meu Drive\Skate-Game\lfs" /MIR /R:1 /W:1 /NFL /NDL
robocopy "C:\Users\abraa\Documents\skate-man\addons" "G:\Meu Drive\Skate-Game\lfs" /MIR /R:1 /W:1 /NFL /NDL

echo.
echo Pastas 'assets' e 'addons' atualizadas na pasta do Google Drive!
echo.
echo ===================================================
echo  2/2: ENVIANDO CODIGO PARA O GIT
echo ===================================================

set /p mensagem="Digite a mensagem do commit: "

git add .
git commit -m "%mensagem%"
git push origin main

echo.
echo ===================================================
echo  PROCESSO CONCLUIDO COM SUCESSO!
echo ===================================================
pause