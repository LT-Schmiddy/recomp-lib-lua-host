import pathlib, subprocess, os, shutil, tomllib, zipfile, sys
from pathlib import Path


class ModInfo:
    project_root: Path
    mod_toml_file: Path
    mod_data: dict
    
    def __init__(self, mod_toml_str: str, build_dir: str):
        self.project_root = Path(__file__).parent
        self.mod_toml_file = self.project_root.joinpath(mod_toml_str)
        
        self.mod_data = tomllib.loads(self.mod_toml_file.read_text())
        # print(mod_data)
        self.build_dir = self.project_root.joinpath(build_dir)
        self.build_nrm_file = self.build_dir.joinpath(f"{self.mod_data['inputs']['mod_filename']}.nrm")

        self.runtime_mods_dir = self.project_root.joinpath("runtime/mods")
        self.runtime_nrm_file = self.runtime_mods_dir.joinpath(f"{self.mod_data['inputs']['mod_filename']}.nrm")
        self.assets_archive_path =self.project_root.joinpath("assets_archive.zip")

        self.zig_shims_dir = Path(__file__).parent.joinpath("./zig_compat/shims")
        self.zig_cmd = shutil.which("zig")
        self.zig_subcommands = [
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

    def get_mod_file(self):
        # print(f"{self.mod_data['inputs']['mod_filename']}.nrm")
        name = f"{self.mod_data['inputs']['mod_filename']}.nrm"
        print(self.mod_toml_file.parent.joinpath(name))
    
    def get_mod_elf(self):
        print(self.mod_toml_file.parent.joinpath(self.mod_data['inputs']['elf_path']))
        
    def build_zig_shims_posix(self):
        extension = ".sh"
        
        for i in self.zig_subcommands:
            shim = self.zig_shims_dir.joinpath(f"zig_{i}{extension}")
            shim.write_text (f"#!/bin/bash\n\"{self.zig_cmd}\" {i} $*")
            os.chmod(shim, 0o755)

        
    def build_zig_shims_win(self):
        extension = ".bat"
        for i in self.zig_subcommands:
            shim = self.zig_shims_dir.joinpath(f"zig_{i}{extension}")
            shim.write_text (f"\"{self.zig_cmd}\" {i} %*")

    def build_zig_shims(self):
        os.makedirs(self.zig_shims_dir, exist_ok=True)
        if os.name == 'nt':
            self.build_zig_shims_win()
        else:
            self.build_zig_shims_posix()
        
        print("Zig shims generated.")

    def create_asset_archive(self, assets_extract_path_str: str):
            assets_extract_path = self.project_root.joinpath(assets_extract_path_str)
            print(f"Assets folder '{assets_extract_path.name}' not found. Extracting assets from '{self.assets_archive_path.name}'...")
            with zipfile.ZipFile(self.assets_archive_path, 'r') as zip_ref:
                zip_ref.extractall(assets_extract_path)

    def copy_to_runtime_dir(self):
        # Copying files for debugging:
        os.makedirs(self.runtime_mods_dir, exist_ok=True)
        shutil.copy(self.build_nrm_file, self.runtime_nrm_file)

    def run_clean(self):
        shutil.rmtree(self.build_dir)
        shutil.rmtree(self.zig_shims_dir)
        shutil.rmtree(self.project_root.joinpath("./N64Recomp/build"))
        shutil.rmtree(self.project_root.joinpath("./vcpkg_installed"))
    
    def run_build(self):
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
    mod = ModInfo("./mod.toml")
    mod.run_build()
