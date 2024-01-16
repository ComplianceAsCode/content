import os
import jinja2
from ssg.build_yaml import Profile
from ssg.environment import open_environment


def command_sub(args):
    product_yaml = os.path.join(args.ssg_root, "products", args.product, "product.yml")
    env_yaml = open_environment(args.build_config_yaml, product_yaml)
    try:
        profile1 = Profile.from_yaml(args.profile1, env_yaml)
        profile2 = Profile.from_yaml(args.profile2, env_yaml)
    except jinja2.exceptions.TemplateNotFound as e:
        print("Error: Profile {} could not be found.".format(str(e)))
        exit(1)

    subtracted_profile = profile1 - profile2

    exclusive_rules = len(subtracted_profile.get_rule_selectors())
    exclusive_vars = len(subtracted_profile.get_variable_selectors())
    if exclusive_rules > 0 or exclusive_vars > 0:
        print(
            "{} rules were left after subtraction.\n"
            "{} variables were left after subtraction.".format(exclusive_rules, exclusive_vars)
        )
        profile1_basename = os.path.splitext(os.path.basename(args.profile1))[0]
        profile2_basename = os.path.splitext(os.path.basename(args.profile2))[0]
        subtracted_profile_filename = "{}_sub_{}.profile".format(
            profile1_basename, profile2_basename
        )
        print(
            "Creating a new profile containing the exclusive selections: {}".format(
                subtracted_profile_filename
            )
        )
        subtracted_profile.title = profile1.title + " subtracted by " + profile2.title
        subtracted_profile.dump_yaml(subtracted_profile_filename)
        print("Profile {} was created successfully".format(subtracted_profile_filename))
    else:
        print("Subtraction would produce an empty profile. No new profile was generated")
