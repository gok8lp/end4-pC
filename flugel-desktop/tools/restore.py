#!/usr/bin/env python3
"""Preview or restore the home snapshot; existing changed files are backed up."""
from pathlib import Path
import argparse, datetime, json, os, shutil, tempfile
import xml.etree.ElementTree as ET

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--apply', action='store_true')
p.add_argument('--relocate-home', action='store_true')
a = p.parse_args()
root = Path(__file__).resolve().parents[1]
home = Path.home()
manifest = json.loads((root / 'manifest.json').read_text())
links = {e['path'].split('flugel-desktop/home/', 1)[1]: e['origin_symlink']
         for e in manifest['entries'] if e.get('origin_symlink')
         and e['path'].startswith('flugel-desktop/home/')}
backup = home / '.local/state/flugel-desktop-backups' / datetime.datetime.now().strftime('%Y%m%d-%H%M%S')

def save_previous(target):
    if target.exists() or target.is_symlink():
        dest = backup / target.relative_to(home)
        dest.parent.mkdir(parents=True, exist_ok=True)
        if target.is_symlink():
            dest.symlink_to(os.readlink(target))
        else:
            shutil.copy2(target, dest)

changed = 0
for src in sorted((root / 'home').rglob('*')):
    if not src.is_file():
        continue
    rel = src.relative_to(root / 'home')
    target = home / rel
    data = src.read_bytes()
    link = links.get(str(rel))
    if a.relocate_home:
        if link:
            link = link.replace('/home/flugel', str(home))
        try:
            data = data.decode('utf-8').replace('/home/flugel', str(home)).encode('utf-8')
        except UnicodeError:
            pass
    same = (target.is_symlink() and os.readlink(target) == link) if link else (
        target.is_file() and not target.is_symlink() and target.read_bytes() == data)
    if same:
        continue
    changed += 1
    if a.apply:
        save_previous(target)
        target.parent.mkdir(parents=True, exist_ok=True)
        # Replace atomically, including an existing symlink, after making a backup.
        with tempfile.TemporaryDirectory(dir=target.parent) as tempdir:
            temp = Path(tempdir) / 'replacement'
            if link:
                temp.symlink_to(link)
            else:
                temp.write_bytes(data)
                temp.chmod(src.stat().st_mode & 0o777)
            os.replace(temp, target)

# Merge only appearance properties; never replace the full LibreOffice user profile.
if a.apply:
    ns = '{http://openoffice.org/2001/registry}'
    ET.register_namespace('oor', ns[1:-1])
    lo = home / '.config/libreoffice/4/user/registrymodifications.xcu'
    wanted = ET.parse(root / 'templates/libreoffice-appearance.xcu').getroot()
    if lo.exists():
        doc = ET.parse(lo)
        save_previous(lo)
    else:
        doc = ET.ElementTree(ET.Element(ns + 'items'))
    for item in wanted:
        for prop in item:
            for olditem in doc.getroot():
                if olditem.get(ns + 'path') == item.get(ns + 'path'):
                    for oldprop in list(olditem):
                        if oldprop.get(ns + 'name') == prop.get(ns + 'name'):
                            olditem.remove(oldprop)
        doc.getroot().append(item)
    lo.parent.mkdir(parents=True, exist_ok=True)
    doc.write(lo, encoding='utf-8', xml_declaration=True)

print(('APPLIED' if a.apply else 'PREVIEW') + f': {changed} home files differ.')
print('LibreOffice appearance is merged only with --apply.')
print('Previous files: ' + str(backup) if a.apply else 'No files changed. Read KURULUM.md before --apply.')
