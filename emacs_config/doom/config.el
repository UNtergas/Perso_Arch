;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; Look (ported from VSCode settings.json)

(setq doom-theme 'alabaster-themes-light
      doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 15)
      display-line-numbers-type 'relative)

(setq-default tab-width 2
              evil-shift-width 2
              standard-indent 2)

(+global-word-wrap-mode +1)

;;; Keybinds (ported from VSCode keybindings.json + vim settings)

(defun my/split-and-follow (side)
  "Split current window toward SIDE and focus the new one (VSCode splitEditor*)."
  (select-window (split-window nil nil side)))

(after! avy
  ;; easymotion/flash look: home-row labels, dim backdrop
  (setq avy-keys (string-to-list "asdfghjklqwertyuiopzxcvbnm")
        avy-background t))

(map!
 ;; s -> labelled n-char jump (vim.easymotion `<leader><leader>/`)
 :nv "s"   #'avy-goto-char-timer

 ;; ]d / [d -> next/prev diagnostic; git hunks (Doom's ]d/[d) moved to ]g / [g
 :m  "]d"  #'next-error
 :m  "[d"  #'previous-error
 :m  "]g"  #'+vc-gutter/next-hunk
 :m  "[g"  #'+vc-gutter/previous-hunk

 ;; alt+p / alt+o -> indent / outdent
 :ni "M-p" (cmd! (evil-shift-right-line 1))
 :ni "M-o" (cmd! (evil-shift-left-line 1))
 :v  "M-p" #'+evil/shift-right
 :v  "M-o" #'+evil/shift-left

 ;; ctrl+b toggle sidebar, ctrl+n focus explorer
 :nvig "C-b" #'+treemacs/toggle
 :nvig "C-n" #'treemacs-select-window

 ;; ctrl+alt+arrows -> focus group
 :g  "C-M-<left>"  #'windmove-left
 :g  "C-M-<right>" #'windmove-right
 :g  "C-M-<up>"    #'windmove-up
 :g  "C-M-<down>"  #'windmove-down

 ;; ctrl+w q / ctrl+w ctrl+w -> close editor, ctrl+w a -> close all
 (:map evil-window-map
  "q"   #'kill-current-buffer
  "C-w" #'kill-current-buffer
  "a"   #'doom/kill-all-buffers)

 ;; ctrl+k chords
 (:nv "C-k" nil
  :prefix "C-k"
  :nv "<left>"  (cmd! (my/split-and-follow 'left))
  :nv "<right>" (cmd! (my/split-and-follow 'right))
  :nv "<up>"    (cmd! (my/split-and-follow 'above))
  :nv "<down>"  (cmd! (my/split-and-follow 'below))
  :nv "a"       #'find-file          ; explorer.newFile
  :nv "A"       #'make-directory     ; explorer.newFolder
  :nv "h"       #'+evil/window-move-left
  :nv "l"       #'+evil/window-move-right
  :nv "k"       #'+evil/window-move-up
  :nv "j"       #'+evil/window-move-down))

;; ctrl+d -> add next match as cursor (VSCode), replaces Doom's M-d/M-D
(map! :n "M-d" nil :n "M-D" nil :v "M-d" nil :v "M-D" nil
      :n "C-d" #'evil-multiedit-match-symbol-and-next
      :v "C-d" #'evil-multiedit-match-and-next
      (:after evil-multiedit
       :map evil-multiedit-mode-map
       :nv "M-d" nil :nv "M-D" nil
       :nv "C-d" #'evil-multiedit-match-and-next))
