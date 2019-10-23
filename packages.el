 ;;; packages.el --- gtd Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2014 Sylvain Benner
;; Copyright (c) 2014-2015 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq gtd-packages
      '(
        org
        org-agenda
        boxquote
	      )
      )

;; List of packages to exclude.
(setq gtd-excluded-packages '())

(when (not (spacemacs/system-is-mswindows))
  (push 'bbdb gtd-packages))


(defun gtd/init-bbdb()
  (use-package bbdb
    :defer t
    :bind (("<f9> b" . bbdb)
           ("<f9> p" . bh/phone-call)
           )
    :config
    (progn
      (spacemacs|require 'bbdb-com)
      ;; Phone capture template handling with BBDB lookup
      ;; Adapted from code by Gregory J. Grubbs
      (defun bh/phone-call ()
        "Return name and company info for caller from bbdb lookup"
        (interactive)
        (let* (name rec caller)
          (setq name (completing-read "Who is calling? "
                                      (bbdb-hashtable)
                                      'bbdb-completion-predicate
                                      'confirm))
          (when (> (length name) 0)
            ;; Something was supplied - look it up in bbdb
            (setq rec
                  (or (first
                       (or (bbdb-search (bbdb-records) name nil nil)
                           (bbdb-search (bbdb-records) nil name nil)))
                      name)))

          ;; Build the bbdb link if we have a bbdb record, otherwise just return the name
          (setq caller (cond ((and rec (vectorp rec))
                              (let ((name (bbdb-record-name rec))
                                    (company (bbdb-record-company rec)))
                                (concat "[[bbdb:"
                                        name "]["
                                        name "]]"
                                        (when company
                                          (concat " - " company)))))
                             (rec)
                             (t "NameOfCaller")))
          (insert caller)))
      )
    )
  )


(defun gtd/init-boxquote()
  (use-package boxquote
    :defer t
    :bind (
           ( "<f9> r" . boxquote-region)
           ( "<f9> f" . boxquote-insert-file))))


(defun gtd/pre-init-org-agenda()
  (use-package org-habit
    :defer t
    :commands org-is-habit-p)
  )

(defun gtd/pre-init-org-archive ()
  (spacemacs|use-package-add-hook org-archive
    :post-config
    (progn
       (setq org-archive-mark-done nil)
       (setq org-archive-location "%s_archive::* Archived Tasks")
      )
    )
  )

(defun gtd/post-init-org-agenda ()
  (global-set-key (kbd "<f12>") 'org-agenda)
  (global-set-key (kbd "<f5>") 'bh/org-todo)
  (global-set-key (kbd "<S-f5>") 'bh/widen)
  (global-set-key (kbd "<f10>") 'bh/set-truncate-lines)
  (global-set-key (kbd "<f8>") 'org-cycle-agenda-files)
  (global-set-key (kbd "<f9> <f9>") 'bh/show-org-agenda)
  (global-set-key (kbd "<f9> c") 'calendar)
  (global-set-key (kbd "<f9> g") 'gnus)
  (global-set-key (kbd "<f9> h") 'bh/hide-other)
  (global-set-key (kbd "<f9> n") 'bh/toggle-next-task-display)
  (global-set-key (kbd "<f9> o") 'bh/make-org-scratch)
  (global-set-key (kbd "<f9> s") 'bh/switch-to-scratch)
  (global-set-key (kbd "<f9> S") 'org-save-all-org-buffers)
  (global-set-key (kbd "<f9> t") 'bh/insert-inactive-timestamp)
  (global-set-key (kbd "<f9> T") 'bh/toggle-insert-inactive-timestamp)
  (global-set-key (kbd "<f9> v") 'visible-mode)
  (global-set-key (kbd "<f9> l") 'org-toggle-link-display)
  (global-set-key (kbd "C-<f9>") 'previous-buffer)
  (global-set-key (kbd "M-<f9>") 'org-toggle-inline-images)
  (global-set-key (kbd "C-<f10>") 'next-buffer)
  (setq org-agenda-restriction-lock-highlight-subtree nil)

  ;; Keep tasks with dates on the global todo lists
  (setq org-agenda-todo-ignore-with-date nil)

  ;; Keep tasks with deadlines on the global todo lists
  (setq org-agenda-todo-ignore-deadlines nil)

  ;; Keep tasks with scheduled dates on the global todo lists
  (setq org-agenda-todo-ignore-scheduled nil)

  ;; Keep tasks with timestamps on the global todo lists
  (setq org-agenda-todo-ignore-timestamp nil)

  ;; Remove completed deadline tasks from the agenda view
  (setq org-agenda-skip-deadline-if-done t)

  ;; Remove completed scheduled tasks from the agenda view
  (setq org-agenda-skip-scheduled-if-done t)

  ;; Remove completed items from search results
  (setq org-agenda-skip-timestamp-if-done t)

  ;; Skip scheduled items if they are repeated beyond the current deadline.
  (setq org-agenda-skip-scheduled-if-deadline-is-shown  (quote repeated-after-deadline))

  (setq org-agenda-include-diary nil)
  (setq org-agenda-diary-file gtd-diary-target)
  (setq org-agenda-insert-diary-extract-time t)

  ;; Include agenda archive files when searching for things
  (setq org-agenda-text-search-extra-files (quote (agenda-archives)))
  (setq org-agenda-span 'day)

  (setq org-agenda-files (list gtd-org-dir))

  ;; Do not dim blocked tasks
  (setq org-agenda-dim-blocked-tasks nil)

  ;; Compact the block agenda view
  (setq org-agenda-compact-blocks t)

  ;; Custom agenda command definitions
  (setq org-agenda-custom-commands
        (quote (("N" "Notes" tags "NOTE"
                 ((org-agenda-overriding-header "Notes")
                  (org-tags-match-list-sublevels t)))
                ("h" "Habits" tags-todo "STYLE=\"habit\""
                 ((org-agenda-overriding-header "Habits")
                  (org-agenda-sorting-strategy
                   '(todo-state-down effort-up category-keep))))
                (" " "Agenda"
                 ((agenda "" nil)
                  (tags "REFILE"
                        ((org-agenda-overriding-header "Tasks to Refile")
                         (org-tags-match-list-sublevels nil)))
                  (tags-todo "-CANCELLED/!"
                             ((org-agenda-overriding-header "Stuck Projects")
                              (org-agenda-skip-function 'bh/skip-non-stuck-projects)
                              (org-agenda-sorting-strategy
                               '(category-keep))))
                  (tags-todo "-HOLD-CANCELLED/!"
                             ((org-agenda-overriding-header "Projects")
                              (org-agenda-skip-function 'bh/skip-non-projects)
                              (org-tags-match-list-sublevels 'indented)
                              (org-agenda-sorting-strategy
                               '(category-keep))))
                  (tags-todo "-CANCELLED/!NEXT"
                             ((org-agenda-overriding-header
                               (concat "Project Next Tasks"
                                       (if bh/hide-scheduled-and-waiting-next-tasks
                                           ""
                                         " (including WAITING and SCHEDULED tasks)")))
                              (org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                              (org-tags-match-list-sublevels t)
                              (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-sorting-strategy
                               '(todo-state-down effort-up category-keep))))
                  (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                             ((org-agenda-overriding-header
                               (concat "Project Subtasks"
                                       (if bh/hide-scheduled-and-waiting-next-tasks
                                           ""
                                         " (including WAITING and SCHEDULED tasks)")))
                              (org-agenda-skip-function 'bh/skip-non-project-tasks)
                              (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-sorting-strategy
                               '(category-keep))))
                  (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                             ((org-agenda-overriding-header
                               (concat "Standalone Tasks"
                                       (if bh/hide-scheduled-and-waiting-next-tasks
                                           ""
                                         " (including WAITING and SCHEDULED tasks)")))
                              (org-agenda-skip-function 'bh/skip-project-tasks)
                              (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-sorting-strategy
                               '(category-keep))))
                  (tags-todo "-CANCELLED+WAITING|HOLD/!"
                             ((org-agenda-overriding-header
                               (concat "Waiting and Postponed Tasks"
                                       (if bh/hide-scheduled-and-waiting-next-tasks
                                           ""
                                         " (including WAITING and SCHEDULED tasks)")))
                              (org-agenda-skip-function 'bh/skip-non-tasks)
                              (org-tags-match-list-sublevels nil)
                              (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                              (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)))
                  (tags "-REFILE/"
                        ((org-agenda-overriding-header "Tasks to Archive")
                         (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                         (org-tags-match-list-sublevels nil))))
                 nil))))



  (setq org-agenda-clock-consistency-checks
        (quote (:max-duration "4:00"
                              :min-duration 0
                              :max-gap 0
                              :gap-ok-around ("4:00"))))

  ;; Agenda clock report parameters
  (setq org-agenda-clockreport-parameter-plist
        (quote (:link t :maxlevel 5 :fileskip0 t :compact t :narrow 80)))

  ;; Agenda log mode items to display (closed and state changes by default)
  (setq org-agenda-log-mode-items (quote (closed state)))

  ;; For tag searches ignore tasks with scheduled and deadline dates
  (setq org-agenda-tags-todo-honor-ignore-options t)

  ;; ;; WARNING!!! Following function call will drastically increase spacemacs launch time.
  ;; ;; This is at the end of my .emacs - so appointments are set up when Emacs starts
  ;; (bh/org-agenda-to-appt)

  ;; Activate appointments so we get notifications,
  ;; but only run this when emacs is idle for 15 seconds
  (run-with-idle-timer 15 nil (lambda () (appt-activate t)))

  ;; If we leave Emacs running overnight - reset the appointments one minute after midnight
  (run-at-time "24:01" nil 'bh/org-agenda-to-appt))



(defun gtd/pre-init-org ()
  (spacemacs|use-package-add-hook org
    :post-config
    (progn
      (setq org-default-notes-file gtd-refile-target)
      (use-package org-id
        :defer t
        :commands org-id-find)))
  )


(defun gtd/post-init-org ()
  (add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\|txt\\)$" . org-mode))
  (use-package org-capture
    :defer t
    :commands org-capture
    :config
    (setq org-capture-templates gtd-org-capture-templates))
  (use-package org-src
    :defer t
    :config
    ;; Use fundamental mode when editing plantuml blocks with C-c '
    (add-to-list 'org-src-lang-modes (quote ("plantuml" . fundamental))))

  (setq org-agenda-auto-exclude-function 'bh/org-auto-exclude-function)

  (setq org-tag-alist gtd-org-tag-alist)
                                        ; Allow setting single tags without the menu
  (setq org-fast-tag-selection-single-key (quote expert))

                                        ; For tag searches ignore tasks with scheduled and deadline dates
  (setq org-agenda-tags-todo-honor-ignore-options t)

  ;; =TODO= state keywords and colour settings:
  (setq org-todo-keywords
        (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
                (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" "PHONE" "MEETING"))))

  ;; ;; TODO Other todo keywords doesn't have appropriate faces yet. They should
  ;; ;; have faces similar to spacemacs defaults.
  ;; (setq org-todo-keyword-faces
  ;;       (quote (("TODO" :foreground "red" :weight bold)
  ;;               ("NEXT" :foreground "blue" :weight bold)
  ;;               ("DONE" :foreground "forest green" :weight bold)
  ;;               ("WAITING" :foreground "orange" :weight bold)
  ;;               ("HOLD" :foreground "magenta" :weight bold)
  ;;               ("CANCELLED" :foreground "forest green" :weight bold)
  ;;               ("MEETING" :foreground "forest green" :weight bold)
  ;;               ("PHONE" :foreground "forest green" :weight bold))))

  ;; (setq org-use-fast-todo-selection t)

  ;; This cycles through the todo states but skips setting timestamps and
  ;; entering notes which is very convenient when all you want to do is fix
  ;; up the status of an entry.
  (setq org-treat-S-cursor-todo-selection-as-state-change nil)

  (setq org-todo-state-tags-triggers
        (quote (("CANCELLED" ("CANCELLED" . t))
                ("WAITING" ("WAITING" . t))
                ("HOLD" ("WAITING") ("HOLD" . t))
                (done ("WAITING") ("HOLD"))
                ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
                ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
                ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

  (setq org-directory gtd-org-dir)


  ;; Targets include this file and any file contributing to the agenda - up to 9 levels deep
  (setq org-refile-targets (quote ((nil :maxlevel . 9)
                                   (org-agenda-files :maxlevel . 9))))

  ;; Use full outline paths for refile targets - we file directly with IDO
  (setq org-refile-use-outline-path t)

  ;; ;; Targets complete directly with IDO
  (setq org-outline-path-complete-in-steps nil)

  ;; Allow refile to create parent tasks with confirmation
  (setq org-refile-allow-creating-parent-nodes (quote confirm))

  ;;   ;; ;; Use IDO for both buffer and file completion and ido-everywhere to t
  (setq org-completion-use-ido t)
  (setq ido-everywhere t)
  (setq ido-max-directory-size 100000)
  (ido-mode (quote both))
  ;;   ;; ;; Use the current window when visiting files and buffers with ido
  (setq ido-default-file-method 'selected-window)
  (setq ido-default-buffer-method 'selected-window)
  ;;   ;; ;; Use the current window for indirect buffer display
  (setq org-indirect-buffer-display 'current-window)

  ;; Set default column view headings: Task Effort Clock_Summary
  (setq org-columns-default-format
        "%50ITEM(Task) %10TODO %3PRIORITY %TAGS %10Effort(Effort){:} %10CLOCKSUM")
  ;; global Effort estimate values
  ;; global STYLE property values for completion
  (setq org-global-properties (quote (("Effort_ALL" . "0:15 0:30 0:45 1:00 2:00 3:00 4:00 5:00 6:00 0:00")
                                      ("STYLE_ALL" . "habit"))))
  ;; Disable the default org-mode stuck projects agenda view
  (setq org-stuck-projects (quote ("" nil nil "")))

  (defvar bh/hide-scheduled-and-waiting-next-tasks t)

  (setq org-list-allow-alphabetical t)

  ;; ;; Explicitly load required exporters
  ;; (require 'ox-html)
  ;; (require 'ox-latex)
  ;; (require 'ox-ascii)

  (setq org-ditaa-jar-path "~/git/org-mode/contrib/scripts/ditaa.jar")
  (setq org-plantuml-jar-path "~/java/plantuml.jar")

  (add-hook 'org-babel-after-execute-hook 'bh/display-inline-images 'append)

  ;; Make babel results blocks lowercase
  (setq org-babel-results-keyword "results")

  ;; Do not prompt to confirm evaluation
  ;; This may be dangerous - make sure you understand the consequences
  ;; of setting this -- see the docstring for details
  (setq org-confirm-babel-evaluate nil)
  ;; Don't enable this because it breaks access to emacs from my
  ;; Android phone
  (setq org-startup-with-inline-images nil)

  (org-babel-do-load-languages
   (quote org-babel-load-languages)  gtd-org-babel-load-languages)
  )

;; ;; experimenting with docbook exports - not finished
;; (setq org-export-docbook-xsl-fo-proc-command "fop %s %s")
;; (setq org-export-docbook-xslt-proc-command "xsltproc --output %s /usr/share/xml/docbook/stylesheet/nwalsh/fo/docbook.xsl %s")
;; ;;
;; ;; Inline images in HTML instead of producting links to the image
;; (setq org-html-inline-images t)
;; ;; Do not use sub or superscripts - I currently don't need this functionality in my documents
;; (setq org-export-with-sub-superscripts nil)
;; ;; Use org.css from the norang website for export document stylesheets
;; (setq org-html-head-extra "<link rel=\"stylesheet\" href=\"http://doc.norang.ca/org.css\" type=\"text/css\" />")
;; (setq org-html-head-include-default-style nil)
;; ;; Do not generate internal css formatting for HTML exports
;; (setq org-export-htmlize-output-type (quote css))
;; ;; Export with LaTeX fragments
;; (setq org-export-with-LaTeX-fragments t)
;; ;; Increase default number of headings to export
;; (setq org-export-headline-levels 6)

;; ;; List of projects
;; ;; norang       - http://www.norang.ca/
;; ;; doc          - http://doc.norang.ca/
;; ;; org-mode-doc - http://doc.norang.ca/org-mode.html and associated files
;; ;; org          - miscellaneous todo lists for publishing
;; (setq org-publish-project-alist
;;       ;;
;;       ;; http://www.norang.ca/  (norang website)
;;       ;; norang-org are the org-files that generate the content
;;       ;; norang-extra are images and css files that need to be included
;;       ;; norang is the top-level project that gets published
;;       (quote (("norang-org"
;;                :base-directory "~/git/www.norang.ca"
;;                :publishing-directory "/ssh:www-data@www:~/www.norang.ca/htdocs"
;;                :recursive t
;;                :table-of-contents nil
;;                :base-extension "org"
;;                :publishing-function org-html-publish-to-html
;;                :style-include-default nil
;;                :section-numbers nil
;;                :table-of-contents nil
;;                :html-head "<link rel=\"stylesheet\" href=\"norang.css\" type=\"text/css\" />"
;;                :author-info nil
;;                :creator-info nil)
;;               ("norang-extra"
;;                :base-directory "~/git/www.norang.ca/"
;;                :publishing-directory "/ssh:www-data@www:~/www.norang.ca/htdocs"
;;                :base-extension "css\\|pdf\\|png\\|jpg\\|gif"
;;                :publishing-function org-publish-attachment
;;                :recursive t
;;                :author nil)
;;               ("norang"
;;                :components ("norang-org" "norang-extra"))
;;               ;;
;;               ;; http://doc.norang.ca/  (norang website)
;;               ;; doc-org are the org-files that generate the content
;;               ;; doc-extra are images and css files that need to be included
;;               ;; doc is the top-level project that gets published
;;               ("doc-org"
;;                :base-directory "~/git/doc.norang.ca/"
;;                :publishing-directory "/ssh:www-data@www:~/doc.norang.ca/htdocs"
;;                :recursive nil
;;                :section-numbers nil
;;                :table-of-contents nil
;;                :base-extension "org"
;;                :publishing-function (org-html-publish-to-html org-org-publish-to-org)
;;                :style-include-default nil
;;                :html-head "<link rel=\"stylesheet\" href=\"/org.css\" type=\"text/css\" />"
;;                :author-info nil
;;                :creator-info nil)
;;               ("doc-extra"
;;                :base-directory "~/git/doc.norang.ca/"
;;                :publishing-directory "/ssh:www-data@www:~/doc.norang.ca/htdocs"
;;                :base-extension "css\\|pdf\\|png\\|jpg\\|gif"
;;                :publishing-function org-publish-attachment
;;                :recursive nil
;;                :author nil)
;;               ("doc"
;;                :components ("doc-org" "doc-extra"))
;;               ("doc-private-org"
;;                :base-directory "~/git/doc.norang.ca/private"
;;                :publishing-directory "/ssh:www-data@www:~/doc.norang.ca/htdocs/private"
;;                :recursive nil
;;                :section-numbers nil
;;                :table-of-contents nil
;;                :base-extension "org"
;;                :publishing-function (org-html-publish-to-html org-org-publish-to-org)
;;                :style-include-default nil
;;                :html-head "<link rel=\"stylesheet\" href=\"/org.css\" type=\"text/css\" />"
;;                :auto-sitemap t
;;                :sitemap-filename "index.html"
;;                :sitemap-title "Norang Private Documents"
;;                :sitemap-style "tree"
;;                :author-info nil
;;                :creator-info nil)
;;               ("doc-private-extra"
;;                :base-directory "~/git/doc.norang.ca/private"
;;                :publishing-directory "/ssh:www-data@www:~/doc.norang.ca/htdocs/private"
;;                :base-extension "css\\|pdf\\|png\\|jpg\\|gif"
;;                :publishing-function org-publish-attachment
;;                :recursive nil
;;                :author nil)
;;               ("doc-private"
;;                :components ("doc-private-org" "doc-private-extra"))
;;               ;;
;;               ;; Miscellaneous pages for other websites
;;               ;; org are the org-files that generate the content
;;               ("org-org"
;;                :base-directory "~/git/org/"
;;                :publishing-directory "/ssh:www-data@www:~/org"
;;                :recursive t
;;                :section-numbers nil
;;                :table-of-contents nil
;;                :base-extension "org"
;;                :publishing-function org-html-publish-to-html
;;                :style-include-default nil
;;                :html-head "<link rel=\"stylesheet\" href=\"/org.css\" type=\"text/css\" />"
;;                :author-info nil
;;                :creator-info nil)
;;               ;;
;;               ;; http://doc.norang.ca/  (norang website)
;;               ;; org-mode-doc-org this document
;;               ;; org-mode-doc-extra are images and css files that need to be included
;;               ;; org-mode-doc is the top-level project that gets published
;;               ;; This uses the same target directory as the 'doc' project
;;               ("org-mode-doc-org"
;;                :base-directory "~/git/org-mode-doc/"
;;                :publishing-directory "/ssh:www-data@www:~/doc.norang.ca/htdocs"
;;                :recursive t
;;                :section-numbers nil
;;                :table-of-contents nil
;;                :base-extension "org"
;;                :publishing-function (org-html-publish-to-html)
;;                :plain-source t
;;                :htmlized-source t
;;                :style-include-default nil
;;                :html-head "<link rel=\"stylesheet\" href=\"/org.css\" type=\"text/css\" />"
;;                :author-info nil
;;                :creator-info nil)
;;               ("org-mode-doc-extra"
;;                :base-directory "~/git/org-mode-doc/"
;;                :publishing-directory "/ssh:www-data@www:~/doc.norang.ca/htdocs"
;;                :base-extension "css\\|pdf\\|png\\|jpg\\|gif\\|org"
;;                :publishing-function org-publish-attachment
;;                :recursive t
;;                :author nil)
;;               ("org-mode-doc"
;;                :components ("org-mode-doc-org" "org-mode-doc-extra"))
;;               ;;
;;               ;; http://doc.norang.ca/  (norang website)
;;               ;; org-mode-doc-org this document
;;               ;; org-mode-doc-extra are images and css files that need to be included
;;               ;; org-mode-doc is the top-level project that gets published
;;               ;; This uses the same target directory as the 'doc' project
;;               ("tmp-org"
;;                :base-directory "/tmp/publish/"
;;                :publishing-directory "/ssh:www-data@www:~/www.norang.ca/htdocs/tmp"
;;                :recursive t
;;                :section-numbers nil
;;                :table-of-contents nil
;;                :base-extension "org"
;;                :publishing-function (org-html-publish-to-html org-org-publish-to-org)
;;                :html-head "<link rel=\"stylesheet\" href=\"http://doc.norang.ca/org.css\" type=\"text/css\" />"
;;                :plain-source t
;;                :htmlized-source t
;;                :style-include-default nil
;;                :auto-sitemap t
;;                :sitemap-filename "index.html"
;;                :sitemap-title "Test Publishing Area"
;;                :sitemap-style "tree"
;;                :author-info t
;;                :creator-info t)
;;               ("tmp-extra"
;;                :base-directory "/tmp/publish/"
;;                :publishing-directory "/ssh:www-data@www:~/www.norang.ca/htdocs/tmp"
;;                :base-extension "css\\|pdf\\|png\\|jpg\\|gif"
;;                :publishing-function org-publish-attachment
;;                :recursive t
;;                :author nil)
;;               ("tmp"
;;                :components ("tmp-org" "tmp-extra")))))

;; ;; I'm lazy and don't want to remember the name of the project to publish when I modify
;; ;; a file that is part of a project.  So this function saves the file, and publishes
;; ;; the project that includes this file
;; ;;
;; ;; It's bound to C-S-F12 so I just edit and hit C-S-F12 when I'm done and move on to the next thing
;; (defun bh/save-then-publish (&optional force)
;;   (interactive "P")
;;   (save-buffer)
;;   (org-save-all-org-buffers)
;;   (let ((org-html-head-extra)
;;         (org-html-validation-link "<a href=\"http://validator.w3.org/check?uri=referer\">Validate XHTML 1.0</a>"))
;;     (org-publish-current-project force)))

;; (global-set-key (kbd "C-s-<f12>") 'bh/save-then-publish)

;; (setq org-latex-listings t)

;; (setq org-html-xml-declaration (quote (("html" . "")
;;                                        ("was-html" . "<?xml version=\"1.0\" encoding=\"%s\"?>")
;;                                        ("php" . "<?php echo \"<?xml version=\\\"1.0\\\" encoding=\\\"%s\\\" ?>\"; ?>"))))

;; (setq org-export-allow-BIND t)

;; Variable org-show-entry-below is deprecated
;; (setq org-show-entry-below (quote ((default))))


;; EOF
