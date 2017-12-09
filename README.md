# Simple .vimrc

## Preface
Many of the Vim configurations I found when first learning Vim were pretty crazy. In an effort to better understand how to configure and use Vim, I created this simple .vimrc configuration file. If you're new to Vim, this is a perfect place to start.

To get started, simply clone the repository to your home directory:

```
git clone --depth=1 https://github.com/brandon1024/vimrc.git ~/.vimrcrepo
cp ~/.vimrcrepo/.vimrc ~/.vimrc
```

This .vimrc is constantly evolving! If you want the latest version, do this:

```
cd ~/.vimrcrepo
git pull
cp ~/.vimrcrepo/.vimrc ~/.vimrc
```

## Mappings
### Normal Mode
- New Tab: `te` alias for `:tabe`
- Next Tab: `tn` alias for `:tabnext`
- Previous Tab: `tp` alias for `:tabprev`
- Inverse Whitespace Tab: `SHIFT-TAB`
- Move Line: `ALT-[jk]` or `Command-[jk]` on mac

### Insert Mode
- Inverse Whitespace Tab: `SHIFT-TAB`
- Duplicate Line: `CTRL-d`

## Other Useful Stuff
- In normal mode, `:find <file>` now performs a recursive file search.