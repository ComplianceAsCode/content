from __future__ import absolute_import
from __future__ import print_function

import os.path
import yaml

from ..yaml import DocumentationNotComplete, open_and_macro_expand


def dump_yaml_preferably_in_original_order(dictionary, file_object):
    try:
        return yaml.dump(dictionary, file_object, indent=4, sort_keys=False)
    except TypeError as exc:
        # Older versions of libyaml don't understand the sort_keys kwarg
        if "sort_keys" not in str(exc):
            raise exc
        return yaml.dump(dictionary, file_object, indent=4)


class XCCDFEntity(object):
    """
    This class can load itself from a YAML with Jinja macros,
    and it can also save itself to YAML.

    It is supposed to work with the content in the project,
    when entities are defined in the benchmark tree,
    and they are compiled into flat YAMLs to the build directory.
    """
    KEYS = dict(
            id_=lambda: "",
            definition_location=lambda: "",
    )

    MANDATORY_KEYS = set()

    GENERIC_FILENAME = ""
    ID_LABEL = "id"

    def __init__(self, id_):
        super(XCCDFEntity, self).__init__()
        self._assign_defaults()
        self.id_ = id_

    def _assign_defaults(self):
        for key, default in self.KEYS.items():
            default_val = default()
            if isinstance(default_val, RuntimeError):
                default_val = None
            setattr(self, key, default_val)

    @classmethod
    def get_instance_from_full_dict(cls, data):
        """
        Given a defining dictionary, produce an instance
        by treating all dict elements as attributes.

        Extend this if you want tight control over the instance creation process.
        """
        entity = cls(data["id_"])
        for key, value in data.items():
            setattr(entity, key, value)
        return entity

    @classmethod
    def process_input_dict(cls, input_contents, env_yaml, product_cpes=None):
        """
        Take the contents of the definition as a dictionary, and
        add defaults or raise errors if a required member is not present.

        Extend this if you want to add, remove or alter the result
        that will constitute the new instance.
        """
        data = dict()

        for key, default in cls.KEYS.items():
            if key in input_contents:
                if input_contents[key] is not None:
                    data[key] = input_contents[key]
                del input_contents[key]
                continue

            if key not in cls.MANDATORY_KEYS:
                data[key] = cls.KEYS[key]()
            else:
                msg = (
                    "Key '{key}' is mandatory for definition of '{class_name}'."
                    .format(key=key, class_name=cls.__name__))
                raise ValueError(msg)

        return data

    @classmethod
    def parse_yaml_into_processed_dict(cls, yaml_file, env_yaml=None, product_cpes=None):
        """
        Given yaml filename and environment info, produce a dictionary
        that defines the instance to be created.
        This wraps :meth:`process_input_dict` and it adds generic keys on the top:

        - `id_` as the entity ID that is deduced either from thefilename,
          or from the parent directory name.
        - `definition_location` as the original location whenre the entity got defined.
        """
        file_basename = os.path.basename(yaml_file)
        entity_id = os.path.splitext(file_basename)[0]
        if file_basename == cls.GENERIC_FILENAME:
            entity_id = os.path.basename(os.path.dirname(yaml_file))

        if env_yaml:
            env_yaml[cls.ID_LABEL] = entity_id
        yaml_data = open_and_macro_expand(yaml_file, env_yaml)

        try:
            processed_data = cls.process_input_dict(yaml_data, env_yaml, product_cpes)
        except ValueError as exc:
            msg = (
                "Error processing {yaml_file}: {exc}"
                .format(yaml_file=yaml_file, exc=str(exc)))
            raise ValueError(msg)

        if yaml_data:
            msg = (
                "Unparsed YAML data in '{yaml_file}': {keys}"
                .format(yaml_file=yaml_file, keys=list(yaml_data.keys())))
            raise RuntimeError(msg)

        if not processed_data.get("definition_location", ""):
            processed_data["definition_location"] = yaml_file

        processed_data["id_"] = entity_id

        return processed_data

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None, product_cpes=None):
        yaml_file = os.path.normpath(yaml_file)

        local_env_yaml = None
        if env_yaml:
            local_env_yaml = dict()
            local_env_yaml.update(env_yaml)

        try:
            data_dict = cls.parse_yaml_into_processed_dict(yaml_file, local_env_yaml, product_cpes)
        except DocumentationNotComplete as exc:
            raise
        except Exception as exc:
            msg = (
                "Error loading a {class_name} from {filename}: {error}"
                .format(class_name=cls.__name__, filename=yaml_file, error=str(exc)))
            raise RuntimeError(msg)

        result = cls.get_instance_from_full_dict(data_dict)

        return result

    def represent_as_dict(self):
        """
        Produce a dict representation of the class.

        Extend this method if you need the representation to be different from the object.
        """
        data = dict()
        for key in self.KEYS:
            value = getattr(self, key)
            if value or True:
                data[key] = getattr(self, key)
        del data["id_"]
        return data

    def dump_yaml(self, file_name, documentation_complete=True):
        to_dump = self.represent_as_dict()
        to_dump["documentation_complete"] = documentation_complete
        with open(file_name, "w+") as f:
            dump_yaml_preferably_in_original_order(to_dump, f)

    def to_xml_element(self):
        raise NotImplementedError()
