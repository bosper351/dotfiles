;; -*- lexical-binding: t; -*-

;; == Startup optimization
;; This is evaluated befure Emacs window opens. Options that manipulate frame/GC
;; land here.

;; ========== UI Tweaks ============
;; Default frame configuration: full screen, good-looking title bar on macOS
(setq frame-resize-pixelwise t)
(tool-bar-mode -1)                      ; All these tools are in the menu-bar anyway
(scroll-bar-mode -1)
(setq default-frame-alist '((fullscreen . maximized)

                            ;; You can turn off scroll bars by uncommenting these lines:
                            ;; (vertical-scroll-bars . nil)
                            ;; (horizontal-scroll-bars . nil)

                            ;; Setting the face in here prevents flashes of
                            ;; color as the theme gets activated
                            (background-color . "#242529")
                            (foreground-color . "#ffffff")
                            (ns-appearance . dark)
                            (ns-transparent-titlebar . t)))

;; Disable package.el to use Elpaca instead
(setq package-enable-at-startup nil)
