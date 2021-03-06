;; get 
(defun doc_string (x / is_comment file2lines temp file line_num lines remove_def line2func_example)
  (check "doc_string" (list x (list str? sym?)))
  (defun is_comment(x)
    (if (str? x)
        (or (= "" (str_strip x " "))
            (and (> (len x) 2) (= ";;" (substr (str_lstrip x nil) 1 2)))
            (= "(check " (pipe x (list (list str_lstrip nil) (list substr 1 7) str_lower ) ))
            )
        nil ) )
  (defun file2lines(file / f line lines)
    (setq f (open (findfile (strcat file ".lsp")) "r"))
    (while (setq line (read-line f))
           (setq lines (consend line lines)))
    lines)  
  (defun remove_def (line / defword)
    (setq line (str_lstrip line " ("))
    (setq defword (first (str_split line nil)))
    (str_strip (substr line (+ 1  (strlen defword))) nil)
    )
  (defun line2func_example(line)
    (pipe line
          (list
            (list str_strip nil)
            (list str_replace "(" " ( ")
            (list str_replace ")" " ) ")
            (list str_split nil)
            (lambda (x / defword) 
              (setq defword (str_lower (cadr x))
                    x (skip x 2))
              (cond
                ((== defword "defun") (cons (car x) (cddr x)))
                ((== defword "defcls") (cons (str_lstrip (car x) "'") (cddddr x)))
                )
              )
            (list take_while (lambda (x) (not_in x (list ")" "/"))))
            (list concat " ")
            (lambda (x) (strcat "(" x ")"))
            ))
    )
  (setq x (str_lower (str x)))
  (if (not_in x {func_pos_dict})
      (*error* (strcat x " not in Docs"))
      )
  (setq temp (dot {func_pos_dict} x)
        file (car temp)
        line_num (cdr temp)
        lines (file2lines file)
        )
  ;; file (findfile (strcat (car temp) ".lsp"))
  (princ (strcat "\n" x " in " (findfile (strcat file ".lsp")) ":"))
  (foreach i (chain (list
                      (reversed (take_while (reversed (span lines 0 line_num)) is_comment))
                      (list (line2func_example (get_nth lines line_num)))
                      (take_while (span lines (+ line_num 1) nil) is_comment)))
           (princ (strcat "\n" i )))
  (if (cls_func? (eval (read x)))
      (foreach i (eval (read (strcat "_" x)))
               (princ (strcat "\n  " (str i)))
               )
      )
  (princ)
  )
(defun C:?? ()
  (doc_string (getstring "\nDoc of?  "))
  )
(defun spell_hint (word / ret)
  (check "spell_hint" (list word (list str? sym?)))
  (setq word (str_lower (str word)))
  (princ (strcat "\nHint for \"" word "\":\n"))
  (princ (pipe
           {func_pos_dict}
           (list
             al_keys
             (list select (lambda (i) (cons (str_find i word) (str_lower i))))
             (list where (lambda (x) (not_nil? (car x))))
             sort
             al_values
             (list concat ", ")
             )
           ))
  (princ "\n")
  (princ)
  )
(defun c:??? ()
  (spell_hint (getstring "\nSpell hint of?  "))
  )