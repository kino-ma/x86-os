#![no_std]
#![feature(global_asm)]
#![feature(asm)]

use panic_halt as _;

#[no_mangle]
pub extern fn start_rs() {
    loop {}
}
