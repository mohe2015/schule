set -ex

ln -sf $PWD/ ~/.roswell/local-projects/
ln -sf $PWD/lack/ ~/.roswell/local-projects/
ln -sf $PWD/parenscript/ ~/.roswell/local-projects/
ln -sf $PWD/clack/ ~/.roswell/local-projects/
ln -sf $PWD/mw-diff-sexp ~/.roswell/local-projects/
ln -sf $PWD/cl-pdf ~/.roswell/local-projects/
ln -sf $PWD/clack/ ~/.roswell/local-projects/

(cd dependencies/popper.js && yarn install && yarn build)
(cd dependencies/bootstrap && npm install && npm run dist)
cp dependencies/popper.js/packages/popper/dist/umd/popper.js static/
cp dependencies/bootstrap/dist/js/bootstrap.js static/
cp dependencies/bootstrap/dist/css/bootstrap.css static/
cp dependencies/popper.js/packages/popper/dist/umd/popper.js.map static/
cp dependencies/bootstrap/dist/js/bootstrap.js.map static/
cp dependencies/bootstrap/dist/css/bootstrap.css.map static/
