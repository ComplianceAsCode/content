import ssg.cce as tested_module


def test_is_cce_format_valid():
    icv = tested_module.is_cce_format_valid
    assert icv("CCE-27191-6")
    assert icv("CCE-7223-7")

    assert not icv("not-valid")
    assert not icv("1234-5")
    assert not icv("TBD")
    assert not icv("CCE-TBD")
    assert not icv("CCE-abcde-f")


def test_is_cce_value_valid():
    icv = tested_module.is_cce_value_valid
    assert icv("CCE-27191-6")
    assert icv("CCE-27223-7")

    assert not icv("1234-5")
    assert not icv("12345-6")
