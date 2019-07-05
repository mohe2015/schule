

(macrolet ((:div (&rest rest)
             (if (equal (subseq rest 0 5)
                        '(:style "display: none;" :class "container-fluid my-tab position-absolute" :id))
               ``(tab ,,(nth 5 rest) ,',@(subseq rest 6))
               nil)))
  (:div :style "display: none;" :class "container-fluid my-tab position-absolute" :id "create-teacher-tab"
    (:FORM :method "POST" :action "/api/teachers" :id "create-teacher-form")))
