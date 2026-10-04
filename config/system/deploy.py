#!/usr/bin/env python3
"""Merge selected native system files without overwriting local edits.

Only installer-owned fields are compared on resume. A plain-text previous copy
preserves the initial stage3 defaults or the last deployed policy for comparison.
No policy file is executed as Python or shell.
"""

import argparse
import os
from pathlib import Path
import re
import shlex
import stat
import tempfile


def active(text):
    return [line.split('#', 1)[0].strip() for line in text.splitlines()
            if line.split('#', 1)[0].strip()]


def mode_for(relative):
    if relative.startswith(('etc/init.d/', 'etc/udhcpc/', 'usr/local/sbin/')):
        return 0o755
    return 0o600 if relative == 'etc/doas.conf' else 0o644


def kind_for(relative):
    if relative.startswith(('etc/conf.d/', 'etc/env.d/')) or relative == 'etc/rc.conf':
        return 'shell'
    return {'etc/hosts': 'hosts', 'etc/fstab': 'fstab', 'etc/resolv.conf': 'resolver',
            'etc/locale.gen': 'lines', 'etc/doas.conf': 'strict-lines',
            'etc/pam.d/system-login': 'pam'}.get(relative, 'exact')


def safe_path(root, relative):
    if not relative or relative.startswith('/') or '..' in relative.split('/'):
        raise ValueError(f'invalid system policy path: {relative}')
    path = root / relative
    # These files are provisioned in a real target root, never through symlinks.
    for current in (path, *path.parents):
        if current == root:
            break
        if current.is_symlink():
            raise ValueError(f'preserve/review symlinked system path: {current}')
    if path.exists() and not path.is_file():
        raise ValueError(f'system file is not a regular file: {path}')
    return path


def write_atomic(path, text, mode):
    if path.is_file() and path.read_text() == text and stat.S_IMODE(path.stat().st_mode) == mode:
        return
    missing = []
    parent = path.parent
    while not parent.exists():
        missing.append(parent)
        parent = parent.parent
    for directory in reversed(missing):
        directory.mkdir()
        directory.chmod(0o755)
    fd, temporary = tempfile.mkstemp(prefix='.install-system.', dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as stream:
            stream.write(text)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary, mode)
        os.replace(temporary, path)
    finally:
        Path(temporary).unlink(missing_ok=True)


def assignment(line):
    match = re.match(r'^\s*([A-Za-z_][A-Za-z0-9_]*)=(.*)$', line)
    if not match:
        return None
    values = shlex.split(match[2], comments=True)
    if len(values) != 1:
        raise ValueError(f'expected a single literal assignment: {line}')
    return match[1], values[0]


def merge(kind, current, wanted, previous):
    lines = current.splitlines(keepends=True)
    required = active(wanted)
    pristine = previous is not None and current == previous
    previous = previous or ''

    def permitted(key, actual, expected, before):
        if actual != expected and actual and not pristine and before != actual:
            raise ValueError(f'local edit conflicts with requested {key}: {actual!r}')

    if kind == 'shell':
        desired = dict(assignment(line) for line in required)
        raw = {assignment(line)[0]: line for line in required}
        for key, value in desired.items():
            found = [assignment(line)[1] for line in lines
                     if re.match(rf'^\s*{re.escape(key)}=', line)]
            expected = [value]
            before = [assignment(line)[1] for line in previous.splitlines()
                      if re.match(rf'^\s*{re.escape(key)}=', line)]
            permitted(key, found, expected, before)
            if found != expected:
                lines = [line for line in lines if not re.match(rf'^\s*{re.escape(key)}=', line)]
                lines.append(raw[key] + '\n')
    elif kind == 'fstab':
        for row in required:
            fields = row.split()
            if len(fields) != 6:
                raise ValueError(f'invalid fstab policy: {row}')
            key = fields[1]
            found = [line.split('#', 1)[0].split() for line in lines
                     if len(line.split('#', 1)[0].split()) >= 2
                     and line.split('#', 1)[0].split()[1] == key]
            before = [row.split() for row in active(previous) if len(row.split()) >= 2 and row.split()[1] == key]
            permitted(key, found, [fields], before)
            if found != [fields]:
                lines = [line for line in lines if len(line.split('#', 1)[0].split()) < 2
                         or line.split('#', 1)[0].split()[1] != key]
                lines.append(row + '\n')
    elif kind == 'hosts':
        for row in required:
            address, *aliases = row.split()
            for alias in aliases:
                other = [line for line in active(current) if alias in line.split()[1:]
                         and line.split()[0] not in ('127.0.0.1', '::1')]
                if other:
                    raise ValueError(f'hostname {alias} already has a different address')
            present = {alias for line in active(''.join(lines)) if line.split()[0] == address
                       for alias in line.split()[1:]}
            missing = [alias for alias in aliases if alias not in present]
            if missing:
                lines.append(address + ' ' + ' '.join(missing) + '\n')
    elif kind == 'resolver':
        found = [line for line in active(current) if line.split()[0] == 'nameserver']
        before = [line for line in active(previous) if line.split()[0] == 'nameserver']
        permitted('nameserver', found, required, before)
        if found != required:
            lines = [line for line in lines if not re.match(r'^\s*nameserver\s', line)]
            lines.extend(line + '\n' for line in required)
    elif kind == 'pam':
        if not any(re.search(r'^session\s+.*\bpam_xdg\.so\b', line) for line in active(current)):
            lines.extend(line + '\n' for line in required)
    elif kind in ('lines', 'strict-lines'):
        present = active(current)
        missing = [line for line in required if line not in present]
        if missing and kind == 'strict-lines' and present and not pristine:
            if active(previous) != present:
                raise ValueError('existing rules differ; merge the requested rules explicitly')
        lines.extend(line + '\n' for line in missing)
    else:
        permitted('contents', current, wanted, previous)
        return wanted

    # Appending a row to a file lacking a final newline must not join two rules.
    result = ''.join(line if line.endswith('\n') else line + '\n' for line in lines)
    return result


def deploy(action, source, root, layer, relatives, values):
    if not re.fullmatch(r'[a-z][a-z0-9-]*', layer):
        raise ValueError('invalid system policy layer')
    pending = []
    for relative in relatives:
        policy = safe_path(source / layer, relative)
        target = safe_path(root, relative)
        receipt = safe_path(root, 'var/lib/install-system/system-files/' + relative)
        current = target.read_text() if target.exists() else ''
        previous = receipt.read_text() if receipt.exists() else None
        if action == 'seed':
            # Called once, directly after verified stage3 extraction, or for the
            # temporary resolver that the host just supplied. Never re-baseline.
            if previous is None:
                write_atomic(receipt, current, 0o600)
            continue
        wanted = policy.read_text()
        def replace(match):
            if match[1] not in values:
                raise ValueError(f'missing system template value: {match[1]}')
            value = values[match[1]]
            if not value or re.search(r'[\x00-\x1f\x7f"`$\\]', value):
                raise ValueError(f'invalid system template value: {match[1]}')
            return value
        wanted = re.sub(r'@([A-Z_]+)@', replace, wanted)
        try:
            result = merge(kind_for(relative), current, wanted, previous)
        except ValueError as error:
            raise ValueError(f'{target}: {error}') from error
        mode = mode_for(relative)
        if action == 'check':
            if not target.is_file() or current != result or stat.S_IMODE(target.stat().st_mode) != mode:
                raise ValueError(f'system policy is incomplete: {target}')
        else:
            pending.append((target, result, mode, receipt, wanted))
    # Validate every requested destination before writing the first file.
    for target, result, mode, receipt, wanted in pending:
        write_atomic(target, result, mode)
        write_atomic(receipt, wanted, 0o600)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('seed', 'apply', 'check'))
    parser.add_argument('layer')
    parser.add_argument('files', nargs='+')
    parser.add_argument('--root', type=Path, default=Path('/'))
    parser.add_argument('--value', action='append', default=[])
    args = parser.parse_args()
    try:
        deploy(args.action, Path(__file__).resolve().parent, args.root.resolve(), args.layer,
               args.files, dict(item.split('=', 1) for item in args.value))
    except (OSError, ValueError) as error:
        parser.exit(1, f'{error}\n')


if __name__ == '__main__':
    main()
