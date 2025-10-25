" ~/.vim/scripts/bump_version.vim
function! BumpVersion()
  " Search for the version line in the current buffer
  let lnum = search('"version": *"\zs\d\+\.\d\+\.\d\+\ze"', 'n')
  if lnum == 0
    echo "No version line found"
    return
  endif

  " Get the line content
  let line = getline(lnum)

  " Extract the semver string (e.g. 1.30.4)
  let verstr = matchstr(line, '\d\+\.\d\+\.\d\+')
  if verstr == ''
    echo "No version string found"
    return
  endif

  " Split into [major, minor, patch]
  let parts = split(verstr, '\.')

  if len(parts) != 3
    echo "Invalid version format: " . verstr
    return
  endif

  " Increment the minor version and reset the patch
  let major = str2nr(parts[0])
  let minor = str2nr(parts[1]) + 1
  let patch = 0

  " Build the new version string
  let new_ver = printf('%d.%d.%d', major, minor, patch)

  " Replace in the line
  let newline = substitute(line, verstr, new_ver, '')

  " Update the buffer
  call setline(lnum, newline)

  echo "Bumped version to " . new_ver
endfunction

command! BumpVersion call BumpVersion()


