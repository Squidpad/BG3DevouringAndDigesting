from colorama import init as colorama_init
from colorama import Fore
from colorama import Style
import glob
import os
import xml.etree.ElementTree as Et

MOD_NAME = 'DevouringAndDigesting'
ROOT_PATH = os.path.dirname(__file__) + '/../../' + MOD_NAME


def eprint(*args, **kwargs):
    args_list = list(args)
    if args_list:
        args_list[0] = f"{Fore.RED}{args_list[0]}{Style.RESET_ALL}"
    print(*args_list, **kwargs)


def get_shortpath(path: str) -> (str, str):
    path = os.path.abspath(path)
    path_parts = path.split(os.sep)
    shortpath = path_parts[-2] + os.sep + path_parts[-1] if len(path_parts) > 1 else path_parts[-1]
    return path, shortpath


def load_uids_from_file(filename: str, description: str, main_file_uids: dict = None) -> dict:
    print(f"  {description}")

    if main_file_uids is None:
        main_file_uids = {}
        unseen_main_file_uids = {}
    else:
        unseen_main_file_uids = main_file_uids.copy()

    seen_uids_in_file = {}

    try:
        for content in Et.parse(filename).getroot().findall("./content"):
            content_str = Et.tostring(content, encoding='unicode').rstrip()
            uid = content.get('contentuid')
            if uid:
                uid = uid.lower()
                if uid in seen_uids_in_file:
                    eprint(f"    Attribute 'contentuid' is defined twice in {description}: {uid}")
                else:
                    seen_uids_in_file[uid] = content.text
                    if main_file_uids:
                        if uid in main_file_uids:
                            del unseen_main_file_uids[uid]
                        else:
                            eprint(f"    Found 'contentuid' in {description} that wasn't defined " +
                                   f"in the main localization file: {uid}; {content.text}")
            else:
                eprint(f"    Attribute 'contentuid' is missing in {description}: {content_str}")
            if content.get('version') is None:
                eprint(f"    Attribute 'version' is missing in {description}: {content_str}")

        for uid, text in unseen_main_file_uids.items():
            eprint(f"    Not found 'contentuid' in {description} that's defined " +
                   f"in the main localization file: {uid}; {text}")
    except Et.ParseError as e:
        print(f"    Error parsing {description}: {e}")

    return seen_uids_in_file


def load_all_uids(main_file_path: str, other_files_glob: str) -> dict:
    print(f"Loading localization files")

    all_uids_by_path = {}

    main_file_path, main_file_shortpath = get_shortpath(main_file_path)
    main_file_uids = load_uids_from_file(main_file_path, main_file_shortpath)
    all_uids_by_path[main_file_path] = main_file_uids

    for path in glob.glob(other_files_glob, recursive=True):
        path, shortpath = get_shortpath(path)
        if path == main_file_path:
            continue
        all_uids_by_path[path] = load_uids_from_file(path, shortpath, main_file_uids)

    all_uids_map = {}
    for shortpath, uids in all_uids_by_path.items():
        for uid, text in uids.items():
            if uid not in all_uids_map:
                all_uids_map[uid] = {}
            all_uids_map[uid][shortpath] = text

    return all_uids_map


def find_unused(all_uids_map: dict, paths: list) -> dict:
    print(f"Searching for unused localization strings")

    unused_uids_map = all_uids_map.copy()

    for path in paths:
        for filename in glob.glob(path, recursive=True):
            with open(filename, 'r') as file:
                data = file.read().lower()
                uids = unused_uids_map.copy().keys()
                for uid in uids:
                    if data.find(uid) >= 0:
                        del unused_uids_map[uid]
            if not unused_uids_map:
                return {}

    if unused_uids_map:
        eprint(f"  Found unused localization strings:")
        for uid, loc_dict in unused_uids_map.items():
            text = next(iter(loc_dict.values()))
            eprint(f"    {uid}: {text}")
        eprint(f"    Summary: {len(unused_uids_map)} of {len(all_uids_map)} is unused.")

    return unused_uids_map


def mark_unused(unused_uids_map: dict) -> None:
    print(f"Updating localization files")

    uids_by_path = {}
    for uid, uids_map in unused_uids_map.items():
        for path in uids_map:
            if path not in uids_by_path:
                uids_by_path[path] = []
            uids_by_path[path].append(uid)

    for path, uids in uids_by_path.items():
        print(f"  {get_shortpath(path)[1]}")

        parser = Et.XMLParser(target=Et.TreeBuilder(insert_comments=True))
        root = Et.parse(path, parser).getroot()

        for content in root.findall("./content"):
            index = list(root).index(content)

            prev_elem = None
            prev_elem_is_unused_comment = False
            if index > 0:
                prev_elem = root[index - 1]
                if prev_elem.tag is Et.Comment and prev_elem.text == 'unused':
                    prev_elem_is_unused_comment = True

            uid = content.get('contentuid')

            if uid in uids:
                if not prev_elem_is_unused_comment:
                    comment = Et.Comment('unused')
                    root.insert(index, comment)
            else:
                if prev_elem_is_unused_comment:
                    root.remove(prev_elem)

        new_xml = Et.tostring(root, encoding='unicode', xml_declaration=True)
        new_xml = new_xml.replace("\n", "\r\n").encode('utf-8')
        with open(path, "wb") as file:
            file.write(new_xml)

    return


colorama_init()

all_uids = load_all_uids(
    f"{ROOT_PATH}/Localization/English/{MOD_NAME}.loca.xml",
    f"{ROOT_PATH}/Localization/**/*.loca.xml",
)
print()
unused_uids = find_unused(all_uids, [
    f"{ROOT_PATH}/Public/{MOD_NAME}/**/*.lsx",
    f"{ROOT_PATH}/Public/{MOD_NAME}/Stats/**/*.txt",
    f"{ROOT_PATH}/Mods/{MOD_NAME}/ScriptExtender/Lua/**/*.lua",
])
print()
mark_unused(unused_uids)
