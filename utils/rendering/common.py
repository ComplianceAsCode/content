import re


def resolve_var_substitutions(text):
    # The <sub .../> here is not the HTML subscript element <sub>...</sub>,
    # and therefore is invalid HTML.
    # so this code substitutes the whole sub element with contents of its idref prefixed by $
    # as occurrence of sub with idref implies that substitution of XCCDF values takes place
    return re.sub(
        r'<sub\s+idref="([^"]*)"\s*/>', r"<tt>$\1</tt>", text)
    

def resolve_var_substitutions_in_rule(rule):
    rule.description = resolve_var_substitutions(rule.description)