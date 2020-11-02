#![no_std]
#![no_main]

use panic_halt as _;

#[no_mangle]
extern fn start() {
    let _i = 0;
    loop {}
}
