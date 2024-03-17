#!/usr/bin/python3

#import os
import sys

def fail(text, *args, **kwargs):
    print(text, *args, file=sys.stderr, **kwargs)
    print(
        "Usage: mkdocker FAMILY IMAGE_NAME OS_TYPE VERSION\n"
        "FAMILY: debian, redhat\n"
        "OS_TYPE & OS_VERSION: as stored on Docker hub"
        , file=sys.stderr
    )
    sys.exit(1)

def main():
    if len(sys.argv) < 5:
        fail('Not enough arguments')
    (imtype, imname, ostype, osver) = sys.argv[1:5]
    try:
        with open(f'templates/Dockerfile-{imtype}', 'r') as f:
            template = f.read()
    except:
        fail('Could not load template')
    # TODO: use jinja2 later if necessary
    template = template.replace('{{os}}', ostype)
    template = template.replace('{{os_version}}', osver)
    try:
        with open(f'hosts/Dockerfile-{imname}', 'w') as f:
            f.write(template)
    except:
        fail('Could not save Dockerfile')
    return 0

main()
