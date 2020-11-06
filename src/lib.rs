#![no_std]
#![feature(global_asm)]
#![feature(asm)]

extern  {
    fn puts(s: *const u8) -> ();
    fn putc(s: u8) -> ();
    fn reboot() -> !;
}

use panic_halt as _;

#[no_mangle]
pub extern fn start_rs() {
    unsafe {
        for _ in 1..5 {
            puts("hoge\n\n\nhogefuga".as_ptr());
        }
        for _ in 1..5 {
            putc('x' as u8);
        }
    }
    unsafe { reboot() };
}
