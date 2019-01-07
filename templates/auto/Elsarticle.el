(TeX-add-style-hook
 "Elsarticle"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("elsarticle" "$for(classoption)$$classoption$$sep$" "$endfor$")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("url" "hyphens") ("fontenc" "T1") ("enumitem" "inline") ("xcolor" "dvipsnames" "table") ("hyperref" "unicode=true" "colorlinks") ("inputenc" "utf8") ("geometry" "$for(geometry)$$geometry$$sep$" "$endfor$") ("ulem" "normalem") ("babel" "$lang$")))
   (add-to-list 'LaTeX-verbatim-environments-local "VerbatimOut")
   (add-to-list 'LaTeX-verbatim-environments-local "SaveVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "LVerbatim*")
   (add-to-list 'LaTeX-verbatim-environments-local "LVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "BVerbatim*")
   (add-to-list 'LaTeX-verbatim-environments-local "BVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "Verbatim*")
   (add-to-list 'LaTeX-verbatim-environments-local "Verbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "lstlisting")
   (add-to-list 'LaTeX-verbatim-environments-local "code")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "Verb")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "elsarticle"
    "elsarticle10"
    "url"
    "graphicx"
    "booktabs"
    "fontenc"
    "lmodern"
    "caption"
    "subfig"
    "amssymb"
    "amsmath"
    "enumitem"
    "float"
    "tabularx"
    "xcolor"
    "ifxetex"
    "ifluatex"
    "fixltx2e"
    "hyperref"
    "cleveref"
    "tabu"
    "mathpazo"
    "easyReview"
    "upquote"
    "inputenc"
    "eurosym"
    "fontspec"
    "xltxtra"
    "xunicode"
    "microtype"
    "geometry"
    "listings"
    "fancyvrb"
    "longtable"
    "ulem"
    "polyglossia"
    "babel"
    "lscape"
    "setspace")
   (TeX-add-symbols
    '("seq" ["argument"] 2)
    '("doi" 1)
    '("edit" 1)
    '("note" 1)
    '("diag" 1)
    '("bs" 1)
    "euro"
    "tightlist"
    "myshade"
    "maxwidth"
    "Oldincludegraphics"
    "bibinfo")
   (LaTeX-add-environments
    "mydef")
   (LaTeX-add-bibliographies
    "$for(bibliography)$$bibliography$$sep$"
    "$endfor$")
   (LaTeX-add-xcolor-definecolors
    "mylinkcolor"
    "mycitecolor"
    "myurlcolor"))
 :latex)

