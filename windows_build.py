#!/usr/bin/env python3
import os
from sys import argv
from subprocess import run
from glob import glob

def cmd(*args, **kwargs):
    print(" ".join(args))
    return run(args, check=True, **kwargs)

cmd("odin", "build", argv[1], "-build-mode:obj", "-target:windows_amd64")
cmd("nasm", "-f win64", "primitives/amd64_windows.asm", "-o asm.obj")
cmd("cl", *glob("*.obj"), "/Fewindows.exe", "/link", "msvcrt.lib", "ntdll.lib", "Shell32.lib", "Bcrypt.lib", "Ws2_32.lib", "Mswsock.lib")

for f in glob("*.obj"):
    os.remove(f)
