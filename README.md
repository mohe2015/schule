# wiki

## Requirements

* Common Lisp
* postgresql

## Installation

sudo pacman -S --needed postgresql
sudo -iu postgres
initdb -D /var/lib/postgres/data
exit
sudo systemctl start postgresql
sudo -iu postgres
createuser --interactive
spickipedia
n
n
n
createdb spickipedia
exit
git clone https://github.com/phppgadmin/phppgadmin /usr/share/nginx/phppgadmin

(mito:create-dao 'user :name "Administrator" :hash (hash "xfg3zte94h62j392h") :group "admin")
(mito:create-dao 'user :name "Anonymous" :hash (hash "xfg3zte94h") :group nil)
(mito:create-dao 'user :name "<your name>" :hash (hash "fjd8sh3l2h") :group "user")

```bash
npm install html-minifier -g
html-minifier --collapse-boolean-attributes --collapse-inline-tag-whitespace --collapse-whitespace --decode-entities --remove-attribute-quotes --remove-comments --remove-empty-attributes --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-style-link-type-attributes --remove-tag-whitespace --sort-attributes --sort-class-name --trim-custom-fragments --use-short-doctype -o www/index.html www/index.html
java -jar closure-compiler-v20181210.jar --js_output_file=www/s/result.js --externs externs/jquery-3.3.js www/s/jquery-3.3.1.js www/s/popper.js www/s/bootstrap.js www/s/summernote-bs4.js www/s/visual-diff.js www/s/index.js
npm i -g purgecss
purgecss --content www/index.html --css www/s/all.css --css www/s/bootstrap.min.css --css www/s/index.css --css www/s/summernote-bs4.css -o www/s/ --content www/s/*.js
