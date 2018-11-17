

(defvar gtd-org-dir "~/git/gtd"
  "Which auto-completion front end to use.")

(defvar gtd-refile-target "~/git/gtd/refile.org"
  "Which auto-completion front end to use.")


(defvar gtd-diary-target "~/git/gtd/diary.org"
  "Which auto-completion front end to use.")
; Tags with fast selection keys
(defvar gtd-org-tag-alist (quote ((:startgroup)
                            ("@bosch" . ?b)
                            ("@homehi" . ?i)
                            ("@home" . ?h)
                            ("@gfg" . ?g)
                            ("@city" . ?c)
                            ("@kb" . ?k)
                            (:endgroup)
                            ("WAITING" . ?W)
                            ("HOLD" . ?H)
                            ("PERSONAL" . ?P)
                            ("BOSCH" . ?B)
                            ("GFG" . ?G)
                            ("ORG" . ?O)
                            ("crypt" . ?E)
                            ("NOTE" . ?N)
                            ("CANCELLED" . ?C)
                            ("FLAGGED" . ??))))
(setq org-tag-alist gtd-org-tag-alist)

; Allow setting single tags without the menu
(setq org-fast-tag-selection-single-key (quote expert))

; For tag searches ignore tasks with scheduled and deadline dates
(setq org-agenda-tags-todo-honor-ignore-options t)
