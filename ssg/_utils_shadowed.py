import os
import sys

def safe_listdir(path):
    try:
        return os.listdir(path)
    except:
        return []


def print_shadows(resource, language, product, ssg_root):
    source_paths = [
        # shared templated checks
        os.path.join("build", product, resource, "shared", language),
        # shared checks
        os.path.join("shared", resource, language),
        # product templated checks
        os.path.join("build", product, resource, language),
        # product checks
        os.path.join(product, resource, language),
    ]

    source_files = [
        set(safe_listdir(os.path.join(ssg_root, path))) for path in source_paths
    ]

    all_source_files = set.union(*source_files)

    for source_file in all_source_files:
        i = 0
        while i < len(source_paths):
            if source_file in source_files[i]:
                break
            i += 1

        assert(i < len(source_paths))

        shadows = set()
        j = i + 1
        while j < len(source_paths):
            if source_file in source_files[j]:
                shadows.add(j)
            j += 1

        if shadows:
            msg = os.path.relpath(
                os.path.join(source_paths[i], source_file), ssg_root
            )

            for shadow in shadows:
                msg += " <- " + os.path.relpath(
                    os.path.join(source_paths[shadow], source_file), ssg_root
                )

            print(msg)
