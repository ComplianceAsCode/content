def preprocess(data, lang):
    data["configure_crypto_policy_modules"] = ":".join([sub_policy["module_name"] for sub_policy in data["sub_policies"]])
    return data
