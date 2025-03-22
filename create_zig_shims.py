import os, shutil
from pathlib import Path

shims_dir = Path(__file__).parent.joinpath("./zig_compat/shims")
zig_cmd = shutil.which("zig")
subcommands = [
    "ar",
    "c++",
    "cc",
    "dlltool",
    "ld.lld",
    "lib",
    "objcopy",
    "ranlib",
    "rc",
]

def build_shims_posix():
    extension = ".sh"
    
    for i in subcommands:
        shim = shims_dir.joinpath(f"zig_{i}{extension}")
        shim.write_text (f"#!/bin/bash\n\"{zig_cmd}\" {i} $*")
        os.chmod(shim, 0o755)

    
def build_shims_win():
    extension = ".bat"
    
    for i in subcommands:
        shim = shims_dir.joinpath(f"zig_{i}{extension}")
        shim.write_text (f"\"{zig_cmd}\" {i} %*")

    

if __name__ == '__main__':
    os.makedirs(shims_dir, exist_ok=True)
    if os.name == 'nt':
        build_shims_win()
    else:
        build_shims_posix()
    
    print("Zig shims generated.")