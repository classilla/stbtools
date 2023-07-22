# Apple Set Top Box/Interactive Television Box Toolsuite

[Another Old VCR Super Hit!](http://oldvcr.blogspot.com/)

Copyright 2023 Cameron Kaiser.  
All rights reserved.  
BSD license.

## What it is

[Read the blog post first!](https://oldvcr.blogspot.com/2023/07/apples-interactive-television-box.html)

This is a set of three Perl tools for working with a "red" ROM dump for the Apple Interative Television Box/Set Top Box (aka AITB, ITV or STB), specifically the STB3.

* The tool `checksum.pl` reads the embedded checksum in a classic Mac ROM and compares with a computed one. Pass the ROM dump on standard input or as a filename argument.

* The tool `resscan.pl` walks a ROM dump and emits the resources it finds. **Currently this only works for red STB ROMs, not the green ROM (which is actually a regular Quadra 605 ROM) and not any other ROMs, though this is intended in the future.** Pass the ROM dump on standard input or as a filename argument. If you pass (a) pair(s) of resource codes and numbers after the ROM filename, then the scanner will emit a dump of that code and resource number, if it exists (such as `DRVR-0.dump`).

* The tool `splicedisk0.pl` walks a ROM dump and inserts the provided disk image into resource `disk#0`. The disk image must be bootable HFS with boot blocks and a blessed System Folder, which the tool will check, and must fit within the provided space. This is intended only for the STB ROM disk image. If you did not change the folder structure but the System Folder got unblessed, try adding the `-fix16` argument to attempt to automatically repair the disk image for insertion.

There are many "gotchas" about this process which are best explained by [the original blog post](https://oldvcr.blogspot.com/2023/07/apples-interactive-television-box.html).

## License

Copyright (C) 2023 Cameron Kaiser. All rights reserved. It is released under the three-clause BSD license, i.e.:

"Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

"THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF/SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."

