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

java -jar closure-compiler-v20181210.jar --js_output_file=www/s/result.js www/s/jquery-3.3.1.js www/s/popper.js www/s/bootstrap.js www/s/summernote-bs4.js www/s/visual-diff.js www/s/index.js 
www/s/moment-with-locales.js 

