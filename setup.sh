ln -sf $PWD/spickipedia/ ~/.roswell/local-projects/
ln -sf $PWD/lack/ ~/.roswell/local-projects/
ln -sf $PWD/parenscript/ ~/.roswell/local-projects/
ln -sf $PWD/clack/ ~/.roswell/local-projects/
ln -sf $PWD/mw-diff-sexp ~/.roswell/local-projects/
ln -sf $PWD/cl-pdf ~/.roswell/local-projects/
ln -sf $PWD/clack/ ~/.roswell/local-projects/

(cd popper.js && npm install && npm run build)
(cd bootstrap && npm install && npm run dist)
cp popper.js/dist/umd/index.js spickipedia/static/popper.js
cp bootstrap/dist/js/bootstrap.js spickipedia/static/
cp bootstrap/dist/css/bootstrap.css spickipedia/static/
