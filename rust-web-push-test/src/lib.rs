extern crate tokio;
extern crate web_push;
extern crate futures;
extern crate libc;

use web_push::*;
use futures::{Future, future::lazy};
use std::fs::File;
use libc::c_char;
use std::ffi::CStr;
use std::u32;

#[no_mangle]
pub extern "C" fn send_notification(p256dh_c : *const c_char, auth_c : *const c_char, endpoint_c : *const c_char, private_key_c : *const c_char, content_c : *const c_char) -> u32 {
    let p256dh = unsafe {
        assert!(!p256dh_c.is_null());
        CStr::from_ptr(p256dh_c)
    }.to_str().unwrap().to_string();

    let auth = unsafe {
        assert!(!auth_c.is_null());
        CStr::from_ptr(auth_c)
    }.to_str().unwrap().to_string();

    let endpoint = unsafe {
        assert!(!endpoint_c.is_null());
        CStr::from_ptr(endpoint_c)
    }.to_str().unwrap().to_string();

    let private_key = unsafe {
        assert!(!private_key_c.is_null());
        CStr::from_ptr(private_key_c)
    }.to_str().unwrap().to_string();

    let content = unsafe {
        assert!(!content_c.is_null());
        CStr::from_ptr(content_c)
    }.to_str().unwrap().to_string();

    let subscription_info = SubscriptionInfo {
        keys: SubscriptionKeys {
            p256dh: p256dh,
            auth: auth,
        },
        endpoint: endpoint,
    };

    let file = File::open(private_key).unwrap();
    let sig_builder = VapidSignatureBuilder::from_pem(file, &subscription_info).unwrap();

    let signature = sig_builder.build().unwrap();

    let mut builder = WebPushMessageBuilder::new(&subscription_info).unwrap();
    builder.set_payload(ContentEncoding::AesGcm, content.as_bytes());
    //builder.set_ttl(1337);
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
    return 1;
}
