;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; VSCode "Alabaster" theme port
(package! alabaster-themes)

;; `s' is avy (VSCode easymotion/flash bind), not evil-snipe
(package! evil-snipe :disable t)

(package! rainbow-delimiters)   ; colourful nested brackets

(package! flyover)   ; ErrorLens-style: show diagnostics on every line
