set -ex

ln -sf $PWD/schule/ ~/.roswell/local-projects/
ln -sf $PWD/lack/ ~/.roswell/local-projects/
ln -sf $PWD/parenscript/ ~/.roswell/local-projects/
ln -sf $PWD/clack/ ~/.roswell/local-projects/
ln -sf $PWD/mw-diff-sexp ~/.roswell/local-projects/
ln -sf $PWD/cl-pdf ~/.roswell/local-projects/
ln -sf $PWD/clack/ ~/.roswell/local-projects/

(cd popper.js && yarn install && yarn build)
(cd bootstrap && npm install && npm run dist)
cp popper.js/packages/popper/dist/umd/popper.js schule/static/
cp bootstrap/dist/js/bootstrap.js schule/static/
cp bootstrap/dist/css/bootstrap.css schule/static/
cp popper.js/packages/popper/dist/umd/popper.js.map schule/static/
cp bootstrap/dist/js/bootstrap.js.map schule/static/
cp bootstrap/dist/css/bootstrap.css.map schule/static/
