cargo build
sudo cp target/debug/libwebpush.so /usr/lib
sudo ldconfig
openssl ecparam -name prime256v1 -genkey -noout -out private.pem
openssl ec -in private.pem -pubout -out vapid_public.pem
openssl ec -in private.pem -pubout -outform DER|tail -c 65|base64|tr '/+' '_-'|tr -d '\n'
