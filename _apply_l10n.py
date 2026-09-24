import re
import glob
import os

VAL = {
    'intl_zh_CN': '正在初始化核心',
    'intl_en': 'Initializing core',
    'intl_ja': 'コアを初期化中',
    'intl_ru': 'Инициализация ядра',
}

def edit(path, subs, must_have=None):
    with open(path, encoding='utf-8') as f:
        s = f.read()
    orig = s
    for pat, rep in subs:
        s, n = re.subn(pat, rep, s, flags=re.DOTALL)
        if n == 0:
            print('  !! NOT MATCHED in', os.path.basename(path), '->', pat[:70])
    if s != orig:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(s)
    return s

# ---------- 1. ARB: remove geodataLoader*, add initializingCore after "init" ----------
for name, val in VAL.items():
    p = f'arb/{name}.arb'
    s = edit(p, [
        (r'  "geodataLoader": "[^"]*",\n', ''),
        (r'  "geodataLoaderDesc": "[^"]*",\n', ''),
    ])
    # insert after the "init" entry
    m = re.search(r'(  "init": "[^"]*",\n)', s)
    if m:
        s = s[:m.end()] + f'  "initializingCore": "{val}",\n' + s[m.end():]
        with open(p, 'w', encoding='utf-8') as f:
            f.write(s)
    else:
        print('  !! init anchor missing in', p)

# ---------- 2. l10n.dart: remove getters, add new one after `get init` ----------
p = 'lib/l10n/l10n.dart'
s = edit(p, [
    (r'\n  /// `[^`]*`\n  String get geodataLoader \{.*?\n  \}\n', ''),
    (r'\n  /// `[^`]*`\n  String get geodataLoaderDesc \{.*?\n  \}\n', ''),
])
new_getter = (
    "\n  /// `Initializing core`\n"
    "  String get initializingCore {\n"
    "    return Intl.message(\n"
    "      'Initializing core',\n"
    "      name: 'initializingCore',\n"
    "      desc: '',\n"
    "      args: [],\n"
    "    );\n"
    "  }\n"
)
m = re.search(r"(  /// `Init`\n  String get init \{\n    return Intl\.message\('Init', name: 'init', desc: '', args: \[\]\);\n  \}\n)", s)
if m:
    s = s[:m.end()] + new_getter + s[m.end():]
    with open(p, 'w', encoding='utf-8') as f:
        f.write(s)
else:
    print('  !! init getter anchor missing in l10n.dart')

# ---------- 3. messages_*.dart ----------
for path in sorted(glob.glob('lib/l10n/intl/messages_*.dart')):
    base = os.path.basename(path)
    key = base[len('messages_'):-len('.dart')]
    val = VAL[key]
    s = edit(path, [
        (r'    "geodataLoader": MessageLookupByLibrary\.simpleMessage\("[^\n]*"\),\n', ''),
        (r'    "geodataLoader": MessageLookupByLibrary\.simpleMessage\(\n      "[^"]*",\n    \),\n', ''),
        (r'    "geodataLoaderDesc": MessageLookupByLibrary\.simpleMessage\("[^\n]*"\),\n', ''),
        (r'    "geodataLoaderDesc": MessageLookupByLibrary\.simpleMessage\(\n      "[^"]*",\n    \),\n', ''),
    ])
    m = re.search(r'(    "init": MessageLookupByLibrary\.simpleMessage\("[^"]*"\),\n)', s)
    if m:
        s = s[:m.end()] + f'    "initializingCore": MessageLookupByLibrary.simpleMessage("{val}"),\n' + s[m.end():]
        with open(path, 'w', encoding='utf-8') as f:
            f.write(s)
    else:
        print('  !! init anchor missing in', base)

# ---------- 4. l10n test ----------
p = 'test/l10n/app_localizations_test.dart'
s = edit(p, [
    (r'    appLocalizations\.geodataLoader,\n', ''),
    (r'    appLocalizations\.geodataLoaderDesc,\n', ''),
])
m = re.search(r'(    appLocalizations\.init,\n)', s)
if m:
    s = s[:m.end()] + '    appLocalizations.initializingCore,\n' + s[m.end():]
    with open(p, 'w', encoding='utf-8') as f:
        f.write(s)
else:
    print('  !! init anchor missing in test')

print('done')
