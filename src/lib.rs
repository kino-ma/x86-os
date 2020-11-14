#![no_std]
#![feature(global_asm)]
#![feature(asm)]

use panic_halt as _;

#[no_mangle]
pub extern fn kernel_main() {
    // to prevent optimize
    let _i = 0;
    loop {}
}
