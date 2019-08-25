set -ex

mkdir -p uploads

ln -sf $PWD/ ~/quicklisp/local-projects/
ln -sf $PWD/lack/ ~/quicklisp/local-projects/
ln -sf $PWD/parenscript/ ~/quicklisp/local-projects/
ln -sf $PWD/clack/ ~/quicklisp/local-projects/
ln -sf $PWD/mw-diff-sexp ~/quicklisp/local-projects/
ln -sf $PWD/cl-pdf ~/quicklisp/local-projects/
ln -sf $PWD/clack/ ~/quicklisp/local-projects/

(cd dependencies/popper.js && yarn install && yarn build)
(cd dependencies/bootstrap && npm install && npm run dist)
(cd dependencies/rust-web-push && ./setup.sh)
(cd dependencies/mathlive && npm install)
cp dependencies/popper.js/packages/popper/dist/umd/popper.js static/
cp dependencies/bootstrap/dist/js/bootstrap.js static/
cp dependencies/bootstrap/dist/css/bootstrap.css static/
cp dependencies/popper.js/packages/popper/dist/umd/popper.js.map static/
cp dependencies/bootstrap/dist/js/bootstrap.js.map static/
cp dependencies/bootstrap/dist/css/bootstrap.css.map static/
cp dependencies/mathlive/dist/mathlive.mjs static/mathlive.js
cp dependencies/mathlive/dist/mathlive.core.css static/
cp dependencies/mathlive/dist/mathlive.css static/
