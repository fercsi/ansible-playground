#!/usr/bin/python3

#import os
import sys

def fail(text, *args, **kwargs):
    print(text, *args, file=sys.stderr, **kwargs)
    print(
        "Usage: mkdocker FAMILY IMAGE_NAME OS_IMAGE\n"
        "FAMILY: debian, redhat\n"
        , file=sys.stderr
    )
    sys.exit(1)

def main():
    if len(sys.argv) < 4:
        fail('Not enough arguments')
    (imtype, imname, os_image) = sys.argv[1:4]
    try:
        with open(f'templates/Dockerfile-{imtype}', 'r') as f:
            template = f.read()
    except:
        fail('Could not load template')
    # TODO: use jinja2 later if necessary
    template = template.replace('{{image}}', os_image)
    try:
        with open(f'hosts/Dockerfile-{imname}', 'w') as f:
            f.write(template)
    except:
        fail('Could not save Dockerfile')
    return 0

main()
