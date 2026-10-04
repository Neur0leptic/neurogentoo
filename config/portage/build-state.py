#!/usr/bin/env python3
"""Inspect Portage's installed metadata and record successful compiler passes."""

import argparse
import json
from pathlib import Path
import re
import time

import portage


def packages(db, pattern):
    return sorted(cp for cp in db.cp_all() if re.search(pattern, cp))


def snapshot(db, atoms):
    result = {}
    for atom in atoms:
        versions = db.match(atom)
        if not versions:
            raise ValueError(f'required installed package is missing: {atom}')
        for cpv in versions:
            stamp, slot = db.aux_get(cpv, ['BUILD_TIME', 'SLOT'])
            if not stamp.isdigit():
                raise ValueError(f'missing BUILD_TIME: {cpv}')
            key = portage.cpv_getkey(cpv) + ':' + slot.split('/')[0]
            result[key] = max(result.get(key, 0), int(stamp))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('list', 'record', 'check'))
    parser.add_argument('--pattern', default='llvm|rust')
    parser.add_argument('--stage')
    parser.add_argument('--receipt', type=Path)
    args = parser.parse_args()
    db = portage.db['/']['vartree'].dbapi
    atoms = packages(db, args.pattern)
    if args.action == 'list':
        if not atoms:
            raise ValueError('no installed packages matched the compiler pass')
        print('\n'.join(atoms))
    elif args.action == 'record':
        result = snapshot(db, atoms)
        if not result:
            raise ValueError('cannot record an empty build pass')
        args.receipt.parent.mkdir(parents=True, exist_ok=True)
        temporary = args.receipt.with_suffix('.tmp')
        temporary.write_text(json.dumps({'schema': 1, 'stage': args.stage,
                                        'completed': int(time.time()), 'packages': result}) + '\n')
        temporary.replace(args.receipt)
    else:
        receipt = json.loads(args.receipt.read_text())
        if receipt['schema'] != 1 or receipt['stage'] != args.stage or not receipt['packages']:
            raise ValueError('invalid compiler pass receipt')
        # Later compiler passes or manual rebuilds can supersede earlier passes.
        for atom, stamp in receipt['packages'].items():
            # depclean can remove a superseded compiler slot after the final pass.
            current = snapshot(db, [atom if db.match(atom) else atom.split(':')[0]])
            if max(current.values(), default=0) < stamp:
                raise ValueError(f'build output predates the recorded pass: {atom}')


if __name__ == '__main__':
    main()
