;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; Look (ported from VSCode settings.json)

(setq doom-theme 'alabaster-themes-light
      doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 15)
      display-line-numbers-type 'relative)

(setq-default tab-width 2
              evil-shift-width 2
              standard-indent 2)

;; Global default indent for JS/TS/web modes (lsp-mode passes these to the
;; formatter). Override per project with a .dir-locals.el (see KEYBINDS/README).
(setq js-indent-level 2
      typescript-indent-level 2
      typescript-ts-mode-indent-offset 2
      tsx-ts-mode-indent-offset 2
      json-ts-mode-indent-offset 2
      css-indent-offset 2
      web-mode-markup-indent-offset 2
      web-mode-css-indent-offset 2
      web-mode-code-indent-offset 2)

(+global-word-wrap-mode +1)

;;; Keybinds (ported from VSCode keybindings.json + vim settings)

(defun my/split-and-follow (side)
  "Split current window toward SIDE and focus the new one (VSCode splitEditor*)."
  (select-window (split-window nil nil side)))

(after! avy
  ;; easymotion/flash look: home-row labels, dim backdrop
  (setq avy-keys (string-to-list "asdfghjklqwertyuiopzxcvbnm")
        avy-background t))

(defun my/indent-line ()
  "Indent current line by `evil-shift-width', keeping point and Evil state."
  (interactive)
  (save-excursion
    (indent-rigidly (line-beginning-position) (line-end-position) evil-shift-width)))

(defun my/outdent-line ()
  "Outdent current line by `evil-shift-width', keeping point and Evil state."
  (interactive)
  (save-excursion
    (indent-rigidly (line-beginning-position) (line-end-position) (- evil-shift-width))))

(map!
 ;; s -> labelled n-char jump (vim.easymotion `<leader><leader>/`)
 :nv "s"   #'avy-goto-char-timer

 ;; ]d / [d -> next/prev diagnostic; git hunks (Doom's ]d/[d) moved to ]g / [g
 :m  "]d"  #'next-error
 :m  "[d"  #'previous-error
 :m  "]g"  #'+vc-gutter/next-hunk
 :m  "[g"  #'+vc-gutter/previous-hunk

 ;; alt+p / alt+o -> indent / outdent
 :ni "M-p" #'my/indent-line
 :ni "M-o" #'my/outdent-line
 :v  "M-p" #'+evil/shift-right
 :v  "M-o" #'+evil/shift-left

 ;; ctrl+s -> save
 :nvieg "C-s" #'save-buffer

 ;; ctrl+f -> search in buffer (same as /), replaces page-down scroll
 :nmv "C-f" #'evil-search-forward

 ;; gr / gR: drop quickrun/eval operators, gr -> show references
 :nm  "gR" nil
 :v   "gR" nil
 :nm  "gr" #'+lookup/references

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

;; colourful bracket pairs (VSCode editor.bracketPairColorization)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;; ErrorLens-style: show every diagnostic at the end of its line, not only
;; where the cursor is.
(use-package! flyover
  :disabled t   ; TEMP: disabled, was laggy. Remove this line to re-enable.
  :hook ((flycheck-mode flymake-mode) . flyover-mode)
  :config
  (setq flyover-checkers '(flycheck flymake)
        flyover-levels '(error warning)
        flyover-display-mode 'always
        flyover-show-at-eol t
        flyover-show-virtual-line nil
        flyover-hide-when-cursor-is-on-same-line nil))

;; avoid showing the current line's diagnostic twice
(after! lsp-ui
  ;; TEMP: re-enable alongside flyover (was off to avoid duplicates)
  ;; (setq lsp-ui-sideline-show-diagnostics nil)
  )

;; readable on the light Alabaster theme: dark text on a pale tinted background
(custom-set-faces!
  '(flyover-error   :foreground "#a40000" :background "#fbe3e3")
  '(flyover-warning :foreground "#7a4b00" :background "#fdf0d0"))

;; Diagnostics as a coloured mark at the start of the line (cheap, no text):
;; red = error, yellow = warning
(after! flycheck
  (setq flycheck-indication-mode 'right-fringe))
(custom-set-faces!
  '(flycheck-fringe-error   :foreground "#d32f2f")
  '(flycheck-fringe-warning :foreground "#e6a700")
  '(flycheck-fringe-info    :foreground "#1e88e5"))

;; tsserver was growing to ~2 GB in a pnpm monorepo: trim its work
(after! lsp-mode
  (setq lsp-clients-typescript-disable-automatic-typing-acquisition t ; no @types downloads/scans
        lsp-idle-delay 1.0                                            ; wait longer before re-querying LSP
        lsp-clients-typescript-max-ts-server-memory 3072)             ; MB, same cap as VSCode
  (dolist (re '("[/\\\\]\\.pnpm\\'" "[/\\\\]dist\\'" "[/\\\\]\\.turbo\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories re)))
