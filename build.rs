extern crate cc;

fn main() {
    cc::Build::new()
        .file("src_asm/real/putc.s")
        .compile("my-asm-lib");
}