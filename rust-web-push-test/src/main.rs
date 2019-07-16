extern crate tokio;
extern crate web_push;
extern crate base64;
extern crate futures;

use web_push::*;
use futures::{Future, future::lazy};
use std::fs::File;

#[no_mangle]
pub extern "C" fn call_from_c() {
    println!("Just called a Rust function from C!");
}

fn main() {
    let subscription_info = SubscriptionInfo {
        keys: SubscriptionKeys {
            p256dh: String::from("BNDRhvO49PwYz5FqEapH9JtP2OMmI6rYA6wXIkJ0bwN_DFKyxPVxJw6O0Is-tGm8weReb0UwECEzWfvNMMQOvj0"),
            auth: String::from("0S5U5eOryRe6pxVPCvla5A")
        },
        endpoint: String::from("https://fcm.googleapis.com/fcm/send/c6XIlT4IvGs:APA91bEBZoXgfhD8ocTLjhYCdF-vf3s2lG94ICReKc_IG8pvBhyAClObjBfYRr2g8szLwX1VnGzwVIRXOEJGEPmLzGIUXYH23Cl-GuVIkAbt7q5nZQdcaMcKTtdBW-pCEMcmNZmziAQ9"),
    };

    let file = File::open("private.pem").unwrap();

    let mut sig_builder = VapidSignatureBuilder::from_pem(file, &subscription_info).unwrap();
    sig_builder.add_claim("sub", "mailto:test@example.com");
    sig_builder.add_claim("foo", "bar");
    sig_builder.add_claim("omg", 123);

    let signature = sig_builder.build().unwrap();

    let mut builder = WebPushMessageBuilder::new(&subscription_info).unwrap();
    let content = "Encrypted payload to be sent in the notification".as_bytes();
    builder.set_payload(ContentEncoding::AesGcm, content);
    builder.set_ttl(1337);
    builder.set_vapid_signature(signature);

    match builder.build() {
       Ok(message) => {
           let client = WebPushClient::new().unwrap();

           tokio::run(lazy(move || {
               client
                   .send(message)
                   .map(|_| {
                       println!("OK");
                   }).map_err(|error| {
                       println!("ERROR: {:?}", error)
                   })
               }));
       },
       Err(error) => {
           println!("ERROR in building message: {:?}", error)
       }
    }
}
