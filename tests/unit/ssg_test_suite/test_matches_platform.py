import pytest

from ssg_test_suite import common


def test_simple_match():
    scenario_platforms = ["Red Hat Enterprise Linux 7"]
    benchmark_cpes = {"cpe:/o:redhat:enterprise_linux:7"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == True


def test_simple_no_match():
    scenario_platforms = ["Red Hat Enterprise Linux 7"]
    benchmark_cpes = {"cpe:/o:redhat:enterprise_linux:8"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == False


def test_multi_platform_all():
    scenario_platforms = ["multi_platform_all"]
    benchmark_cpes = {"cpe:/o:redhat:enterprise_linux:7"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == True


def test_multi_platform_match():
    scenario_platforms = ["multi_platform_rhel"]
    benchmark_cpes = {"cpe:/o:redhat:enterprise_linux:7"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == True


def test_multi_platform_no_match():
    scenario_platforms = ["multi_platform_fedora"]
    benchmark_cpes = {"cpe:/o:redhat:enterprise_linux:7"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == False


def test_list_simple_match_first():
    scenario_platforms = ["Red Hat Enterprise Linux 7",
                          "Red Hat Enterprise Linux 8"]
    benchmark_cpes = {"cpe:/o:redhat:enterprise_linux:7"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == True


def test_list_simple_match_second():
    scenario_platforms = ["Red Hat Enterprise Linux 7",
                          "Red Hat Enterprise Linux 8"]
    benchmark_cpes = {"cpe:/o:redhat:enterprise_linux:8"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == True


def test_list_simple_no_match():
    scenario_platforms = ["Red Hat Enterprise Linux 7",
                          "Red Hat Enterprise Linux 8"]
    benchmark_cpes = {"cpe:/o:redhat:enterprise_linux:9"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == False


def test_list_multi_platform_match_first():
    scenario_platforms = ["multi_platform_rhel", "multi_platform_debian"]
    benchmark_cpes = {"cpe:/o:redhat:enterprise_linux:8"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == True


def test_list_multi_platform_match_second():
    scenario_platforms = ["multi_platform_rhel", "multi_platform_debian"]
    benchmark_cpes = {"cpe:/o:debianproject:debian:9"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == True


def test_list_multi_platform_no_match():
    scenario_platforms = ["multi_platform_debian", "multi_platform_ubuntu"]
    benchmark_cpes = {"cpe:/o:redhat:enterprise_linux:8"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == False


def test_list_combined_match():
    scenario_platforms = ["multi_platform_debian", "multi_platform_ubuntu",
                          "Red Hat Enterprise Linux 8"]
    benchmark_cpes = {"cpe:/o:redhat:enterprise_linux:8"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == True


def test_list_combined_match_2():
    scenario_platforms = ["Debian 9", "multi_platform_ubuntu", "openSUSE",
                          "Red Hat Enterprise Linux 8"]
    benchmark_cpes = {"cpe:/o:debianproject:debian:9"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == True


def test_list_combined_no_match():
    scenario_platforms = ["multi_platform_ubuntu", "multi_platform_fedora",
                          "Red Hat Enterprise Linux 8", "openSUSE"]
    benchmark_cpes = {"cpe:/o:debianproject:debian:9"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == False


def test_simple_multiple_benchmark_cpes():
    scenario_platforms = ["Red Hat Enterprise Linux 7"]
    benchmark_cpes = {"cpe:/o:redhat:enterprise_linux:7",
                      "cpe:/o:redhat:enterprise_linux:7::client",
                      "cpe:/o:redhat:enterprise_linux:7::computenode"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == True


def test_simple_multiple_unrelated_benchmark_cpes():
    scenario_platforms = ["Red Hat Enterprise Linux 7"]
    benchmark_cpes = {"cpe:/o:redhat:enterprise_linux:7",
                      "cpe:/o:redhat:enterprise_linux:8"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == True


def test_simple_multiple_bogus_benchmark_cpes():
    scenario_platforms = ["Red Hat Enterprise Linux 7"]
    benchmark_cpes = {"cpe:/o:abcdef:ghijklm:42"
                      "cpe:/o:zzzzz:xxxx:77",
                      "cpe:/o:redhat:enterprise_linux:7"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == True

def test_simple_multiple_bogus_benchmark_cpes_no_match():
    scenario_platforms = ["Fedora"]
    benchmark_cpes = {"cpe:/o:abcdef:ghijklm:42"
                      "cpe:/o:zzzzz:xxxx:77",
                      "cpe:/o:redhat:enterprise_linux:7"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == False


def test_multiple_multiple_bogus_benchmark_cpes_no_match():
    scenario_platforms = ["Fedora", "openSUSE"]
    benchmark_cpes = {"cpe:/o:abcdef:ghijklm:42"
                      "cpe:/o:zzzzz:xxxx:77",
                      "cpe:/o:redhat:enterprise_linux:7"}
    assert common.matches_platform(scenario_platforms, benchmark_cpes) == False


def test_typo():
    scenario_platforms = ["Rrd Hat Enterprise Linux 7"]
    benchmark_cpes = {"cpe:/o:redhat:enterprise_linux:7"}
    with pytest.raises(ValueError):
        common.matches_platform(scenario_platforms, benchmark_cpes)


def test_wrong_multi_platform():
    scenario_platforms = ["multi_platform_fidorka"]
    benchmark_cpes = {"cpe:/o:fedoraproject:fedora:30"}
    with pytest.raises(ValueError):
        common.matches_platform(scenario_platforms, benchmark_cpes)
