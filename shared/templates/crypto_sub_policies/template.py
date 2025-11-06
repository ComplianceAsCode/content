def preprocess(data, lang):
    data["configure_crypto_policy_modules"] = ":".join(data["sub_policies"].keys())
    return data
