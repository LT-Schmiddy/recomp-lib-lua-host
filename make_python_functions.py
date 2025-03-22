import pathlib, subprocess, os, shutil, tomllib, zipfile
from pathlib import Path
USING_ASSETS_ARCHIVE = True

project_root = Path(__file__).parent

mod_data = tomllib.loads(project_root.joinpath("mod.toml").read_text())
mod_manifest_data = mod_data["manifest"]
# print(mod_data)
build_dir = project_root.joinpath(f"build")
build_nrm_file = build_dir.joinpath(f"{mod_data['inputs']['mod_filename']}.nrm")

runtime_mods_dir = project_root.joinpath("runtime/mods")
runtime_nrm_file = runtime_mods_dir.joinpath(f"{mod_data['inputs']['mod_filename']}.nrm")

assets_archive_path = project_root.joinpath("assets_archive.zip")
assets_extract_path = project_root.joinpath("assets_extracted/assets")

zig_shims_dir = Path(__file__).parent.joinpath("./zig_compat/shims")
zig_cmd = shutil.which("zig")
zig_subcommands = [
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

def build_zig_shims_posix():
    extension = ".sh"
    
    for i in zig_subcommands:
        shim = zig_shims_dir.joinpath(f"zig_{i}{extension}")
        shim.write_text (f"#!/bin/bash\n\"{zig_cmd}\" {i} $*")
        os.chmod(shim, 0o755)

    
def build_zig_shims_win():
    extension = ".bat"
    
    for i in zig_subcommands:
        shim = zig_shims_dir.joinpath(f"zig_{i}{extension}")
        shim.write_text (f"\"{zig_cmd}\" {i} %*")

def build_zig_shims():
    os.makedirs(zig_shims_dir, exist_ok=True)
    if os.name == 'nt':
        build_zig_shims_win()
    else:
        build_zig_shims_posix()
    
    print("Zig shims generated.")

def create_asset_archive():
    if USING_ASSETS_ARCHIVE and not assets_extract_path.is_dir():
        print(f"Assets folder '{assets_extract_path.name}' not found. Extracting assets from '{assets_archive_path.name}'...")
        with zipfile.ZipFile(assets_archive_path, 'r') as zip_ref:
            zip_ref.extractall(assets_extract_path)

def copy_to_runtime_dir():
    # Copying files for debugging:
    os.makedirs(runtime_mods_dir, exist_ok=True)
    shutil.copy(build_nrm_file, runtime_nrm_file)

def run_build():
    # Unzipping Archive:
    make_run = subprocess.run(
        [
            shutil.which("make"),
        ],
        cwd=pathlib.Path(__file__).parent
    )
    if make_run.returncode != 0:
        raise RuntimeError("Make failed!")

if __name__ == '__main__':
    run_build()