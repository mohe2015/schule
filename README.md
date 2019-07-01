# wiki

## Requirements

* fcgi
* roswell
* Atom (ubuntu install gnome tweaks and change theme to dark)
* Atom parinfer, slima, language-lisp https://atom.io/packages/slima
* https://github.com/FiloSottile/mkcert

## Installation

```bash
ros install ccl-bin
ros install slime

cd crypt_blowfish
make libbcrypt.so
sudo cp libbcrypt.so /usr/local/lib/
sudo ldconfig
cdd ..

ln -s $PWD/spickipedia/ ~/.roswell/local-projects/
ln -s $PWD/monkeylib-bcrypt/ ~/.roswell/local-projects/
ln -s $PWD/lack/ ~/.roswell/local-projects/
ln -s $PWD/parenscript/ ~/.roswell/local-projects/
ln -s $PWD/clack/ ~/.roswell/local-projects/
```

```lisp
(spickipedia.db:setup-db)
(in-package :spickipedia.db)
(with-connection (db)
  (create-dao 'user :name "Administrator" :hash (bcrypt:hash "xfg3zte94h62j392h") :group "admin")
  (create-dao 'user :name "Anonymous" :hash (bcrypt:hash "xfg3zte94h") :group "anonymous")
  (create-dao 'user :name "<your name>" :hash (bcrypt:hash "fjd8sh3l2h") :group "user"))
(spickipedia:start)


(declaim (optimize (compilation-speed 0) (debug 0) (safety 0) (space 3) (speed 0)))
(save-application "spickipedia"  :clear-clos-caches t :impurify t :prepend-kernel t)
```

```bash
npm install html-minifier -g
html-minifier --collapse-boolean-attributes --collapse-inline-tag-whitespace --collapse-whitespace --decode-entities --remove-attribute-quotes --remove-comments --remove-empty-attributes --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-style-link-type-attributes --remove-tag-whitespace --sort-attributes --sort-class-name --trim-custom-fragments --use-short-doctype -o www/index.html www/index.html
java -jar closure-compiler-v20181210.jar --js_output_file=www/s/result.js --externs externs/jquery-3.3.js www/s/jquery-3.3.1.js www/s/popper.js www/s/bootstrap.js www/s/summernote-bs4.js www/s/visual-diff.js www/s/index.js
npm i -g purgecss
purgecss --content www/index.html --css www/s/all.css --css www/s/bootstrap.min.css --css www/s/index.css --css www/s/summernote-bs4.css -o www/s/ --content www/s/*.js
```

## Browser debugging

### Accessing modules

import('../js/utils.lisp').then(m => module = m)










(dbi:connect-cached :sqlite3 :database-name #P"spickipedia.db")

(mito:connect-toplevel :sqlite3 :database-name #P"spickipedia.db")
(mito:deftable user1 ()
  ((name :col-type (:varchar 64))
   (email :col-type (or (:varchar 128) :null))))
(mito:ensure-table-exists 'user1)
(dbi:disconnect mito:*connection*)
