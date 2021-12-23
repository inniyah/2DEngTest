import json
import os
import sys
import datetime

from file_lock import FileLock

class JSONDbEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, set):
            return sorted(obj)
        if isinstance(obj, bytes):
            return escape(obj.decode('utf-8'))
        return json.JSONEncoder.default(self, obj)

def generate_obj_info(obj_filename):
    obj_info = {}
    return obj_info

def get_new_seq_id(obj_filename, obj_type, seq_info):
    assert(obj_type)
    try:
        curr_seq_id = seq_info[obj_type]
    except KeyError:
        curr_seq_id = 1
    seq_info[obj_type] = curr_seq_id + 1
    return curr_seq_id

def touch(fname, times=None):
    with open(fname, 'a'):
        os.utime(fname, times)

def get_obj_info(json_db_filename, obj_filename, obj_type):
    with FileLock(f"{json_db_filename}.lock"):
        touch(json_db_filename) # make sure that the file exists

        with open(json_db_filename, "r+") as opened_file:
            current_json = opened_file.read()
            if current_json == "":
                current_json = {}
            else:
                current_json = json.loads(current_json)

            try:
                seq_info = current_json[':seq_info']
            except KeyError:
                seq_info = { }
                current_json[':seq_info'] = seq_info

            try:
                type_lists = current_json[':type_lists']
            except KeyError:
                type_lists = { }
                current_json[':type_lists'] = type_lists

            try:
                db_entry = current_json[obj_filename]
            except KeyError:
                db_entry = generate_obj_info(obj_filename)
                #~ db_entry[":change_id"] = 0

                assert(obj_type)
                new_seq_id = get_new_seq_id(obj_filename, obj_type, seq_info)
                db_entry[":seq_id"]  = new_seq_id

                try:
                    type_list = type_lists[obj_type]
                except KeyError:
                    type_list = { }
                    type_lists[obj_type] = type_list

                type_list[f"{new_seq_id}"] = obj_filename

                current_json[obj_filename] = db_entry

            now = datetime.datetime.utcnow()
            #~ current_json[':timestamp'] = f"{now.strftime('%Y-%m-%d (%H:%M:%S) UTC')}"

            opened_file.seek(0)
            opened_file.truncate(0)
            json.dump(current_json, opened_file, indent=2, sort_keys=True, cls=JSONDbEncoder)

    return db_entry

def update_obj_info(json_db_filename, obj_filename, db_entry):
    with FileLock(f"{json_db_filename}.lock"):
        touch(json_db_filename) # make sure that the file exists

        with open(json_db_filename, "r+") as opened_file:
            current_json = opened_file.read()
            if current_json == "":
                current_json = {}
            else:
                current_json = json.loads(current_json)

            #~ try:
            #~     old_db_entry = current_json[obj_filename]
            #~     if (old_db_entry[":change_id"] == db_entry[":change_id"]):
            #~         db_entry[":change_id"] += 1
            #~     else:
            #~         print(f"Error, data mismatch for {obj_filename} in {json_db_filename}")
            #~         return False
            #~ except KeyError:
            #~     pass

            now = datetime.datetime.utcnow()
            #~ db_entry[':timestamp'] = f"{now.strftime('%Y-%m-%d (%H:%M:%S) UTC')}"
            #~ current_json[':timestamp'] = f"{now.strftime('%Y-%m-%d (%H:%M:%S) UTC')}"

            current_json[obj_filename] = db_entry

            opened_file.seek(0)
            opened_file.truncate(0)
            json.dump(current_json, opened_file, indent=2, sort_keys=True, cls=JSONDbEncoder)

    return True

def get_all_info(json_db_filename):
    with FileLock(f"{json_db_filename}.lock"):
        touch(json_db_filename) # make sure that the file exists

        with open(json_db_filename, "r") as opened_file:
            current_json = opened_file.read()
            if current_json == "":
                current_json = {
                    ':seq_info': { },
                    ':type_lists': { },
                }
            else:
                current_json = json.loads(current_json)

    return current_json
