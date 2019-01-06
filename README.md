# wiki

## Requirements

* maybe libgit2
* Common Lisp
* postgresql

npm install html-minifier -g

git reset --hard && html-minifier --collapse-boolean-attributes --collapse-inline-tag-whitespace 
--collapse-whitespace --decode-entities --remove-attribute-quotes --remove-comments 
--remove-empty-attributes --remove-optional-tags --remove-redundant-attributes 
--remove-script-type-attributes --remove-style-link-type-attributes --remove-tag-whitespace 
--sort-attributes --sort-class-name --trim-custom-fragments --use-short-doctype  -o www/index.html 
www/index.html
