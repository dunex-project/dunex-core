project('dunex-core', ['d', 'c'], version: '0.0.1')

auth = dependency('dunex-auth', method: 'dub')
commandr = dependency('commandr', method: 'dub')
common = dependency('dunex-core:common', method: 'dub')


# Wip
executable('mkdir', 'src/mkdir/mkdir.d')
executable('cksum', 'src/cksum/cksum.d')
executable('nl', 'src/nl/nl.d', dependencies: [common, commandr])

# Done(-ish)
executable('su', 'src/su/su.d', dependencies: [auth, meson.get_compiler('c').find_library('crypt'), commandr, common])
executable('yes', 'src/yes/yes.d')
executable('tee', 'src/tee/tee.d')
executable('tty', 'src/tty/tty.d')
executable('echo', 'src/echo/echo.d')
executable('uname', 'src/uname/uname.d')
# Somehow we should link this to true and false on install.
executable('return', 'src/return/return.d')
executable('hostid', 'src/hostid/hostid.d')
executable('unlink', 'src/unlink/unlink.d')
executable('sync', 'src/sync/sync.d')
executable('basename', 'src/basename/basename.d')
executable('dirname', 'src/dirname/dirname.d')
executable('tsort', 'src/tsort/tsort.d')
executable('cut', 'src/cut/cut.d')
executable('seq', 'src/seq/seq.d')
executable('sleep', 'src/sleep/sleep.d')
executable('factor', 'src/factor/factor.d')
executable('wc', 'src/wc/wc.d')
executable('cat', 'src/cat/cat.d')
