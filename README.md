# ygg

Simple installer for using [BinaryBuilder.jl][BB] built binaries from [Yggdrasil][YGG]
outside of Julia.

## Installation and usage

0. Install dependencies: `ygg` requires `julia` and `make`.

1. Clone this repository and `cd` to it:
   ```bash
   $ git clone https://github.com/fredrikekre/ygg.git

   $ cd ygg
   ```

2. Run `make` to install the `ygg` executable:
   ```bash
   $ make
   ```
   By default all executables, including `ygg`, is installed to the `build/bin` directory
   inside the repository. Either make sure this directory is available in `$PATH` or
   configure the target `bin` directory by specifying `$YGGBINDIR`, for example,
   if you have `$HOME/bin` in `$PATH`:
   ```bash
   $ make YGGBINDIR=$HOME/bin
   ```
   This will install `ygg`, and all binaries `ygg` itself will install, to `$HOME/bin/ygg`.

3. Install, update, and uninstall binaries with `ygg install <binary>`,
   `ygg install <binary>`, and `ygg uninstall <binary>`, respectively. For example, to
   install the `zstd` compression binary:
   ```bash
   $ ygg install zstd
   ```

4. To update `ygg` itself, e.g. if there are new binaries added to the repo, simply run
   ```
   $ ygg update ygg
   ```

## Available binaries

The binaries that are currently available to install with `ygg` are:

 - `clang`
 - `clang++`
 - `convert`
 - `duf`
 - `ffmpeg`
 - `ffprobe`
 - `fzf`
 - `gh`
 - `ghr`
 - `git`
 - `git-crypt`
 - `gof3r`
 - `htop`
 - `identify`
 - `kubectl`
 - `pandoc`
 - `pandoc-crossref`
 - `pdfattach`
 - `pdfdetach`
 - `pdffonts`
 - `pdfimages`
 - `pdfinfo`
 - `pdfseparate`
 - `pdftocairo`
 - `pdftohtml`
 - `pdftoppm`
 - `pdftops`
 - `pdftotext`
 - `pdfunite`
 - `rclone`
 - `rr`
 - `rg` (`ripgrep`)
 - `tectonic`
 - `tokei`
 - `tmux`
 - `unpaper`
 - `zstd`/`zstdmt`
 - `node`
 - `7z`

 If a binary is available in Yggdrasil it is, in general, quite easy to add new ones:
 just a single line in the `Makefile`!


 [BB]: https://github.com/JuliaPackaging/BinaryBuilder.jl
 [YGG]: https://github.com/JuliaPackaging/Yggdrasil
