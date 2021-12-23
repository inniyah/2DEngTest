#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import sys
import os
import glob
import json

from file_lock import FileLock

def touch(fname, times=None):
    with open(fname, 'a'):
        os.utime(fname, times)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process obj 3d models")
    parser.add_argument('--verbose', '-v', action='count', default=0)
    parser.add_argument("-J", "--json", help="JSON file with extra attributes", required=True)
    parser.add_argument("-P", "--pattern", help="File pattern", required=True)
    args = parser.parse_args()

    if not args.json and not args.pattern:
        print("Wrong arguments")
        sys.exit(-1)

    json_db_filename = args.json
    with FileLock(f"{json_db_filename}.lock"):
        touch(json_db_filename) # make sure that the file exists

        with open(json_db_filename, "r+") as opened_file:
            current_json = opened_file.read()
            if current_json == "":
                current_json = {}
            else:
                current_json = json.loads(current_json)

            current_json = { k: v for k, v in current_json.items() if v }

            for file in glob.glob(args.pattern):
                id = os.path.basename(os.path.splitext(file)[0])
                #~ print(id)
                try:
                    current_json[id]
                except KeyError:
                    current_json[id] = { }

            opened_file.seek(0)
            opened_file.truncate(0)
            json.dump(current_json, opened_file, indent=2, sort_keys=True)
