

(defvar gtd-org-dir "~/git/gtd"
  "Which auto-completion front end to use.")

(defvar gtd-refile-target "~/git/gtd/refile.org"
  "Which auto-completion front end to use.")


(defvar gtd-diary-target "~/git/gtd/diary.org"
  "Which auto-completion front end to use.")

(defvar gtd-use-clock nil
  "Enable Task clocking ")

(defvar gtd-agenda-exclude-fast '("gfg" "dwj")
  "exclude this tags from Adgenda by pressing M-\ RET. allways small characters here!")
                                        ; Tags with fast selection keys
(defvar gtd-org-tag-alist (quote ((:startgroup)
                                  ("@bosch" . ?b)
                                  ("@homehi" . ?h)
                                  ("@home" . ?k)
                                  ("@gfg" . ?g)
                                  (:endgroup)
                                  ("WAITING" . ?W)
                                  ("HOLD" . ?H)
                                  ("PERSONAL" . ?P)
                                  ("BOSCH" . ?B)
                                  ("GFG" . ?G)
                                  ("NOTE" . ?N)
                                  ("CANCELLED" . ?C)
                                  ("FLAGGED" . ??))))



;; Capture templates for: TODO tasks, Notes, appointments, phone calls,
;; meetings, and org-protocol
(defvar gtd-org-capture-templates
  (quote (("t" "todo" entry (file gtd-refile-target)
           "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
          ("r" "respond" entry (file gtd-refile-target)
           "* NEXT Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
          ("n" "note" entry (file gtd-refile-target)
           "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
          ("j" "Journal" entry (file+datetree gtd-diary-target)
           "* %?\n%U\n" :clock-in t :clock-resume t)
          ("w" "org-protocol" entry (file gtd-refile-target)
           "* TODO Review %c\n%U\n" :immediate-finish t)
          ("m" "Meeting" entry (file gtd-refile-target)
           "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
          ("p" "Phone call" entry (file gtd-refile-target)
           "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t)
          ("h" "Habit" entry (file gtd-refile-target)
           "* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n")))
  "Capture templates for org-capture")


(defvar gtd-org-babel-load-languages
   '((emacs-lisp . t)
        (dot . t)
        (ditaa . t)
        (R . t)
        (python . t)
        (ruby . t)
        (gnuplot . t)
        (clojure . t)
        (shell . t)
        (ledger . t)
        (org . t)
        (plantuml . t)
        (latex . t))
  "bla")
