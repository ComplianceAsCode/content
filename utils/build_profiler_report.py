#!/usr/bin/python3
"""Compare and present build times to user and generate an HTML interactive graph"""
import sys
import argparse


def load_log_file(file) -> dict:
    """Loads Targets and their durations from ninja logfile `file` and returns them in a dict"""

    with open(file, 'r') as file_pointer:
        lines = file_pointer.read().splitlines()

    # {Target: duration} dict
    target_duration_dict = {}

    # an issue appeared with new versions of cmake where the targets are duplicated with a relative
    # and absolute path and therefore they must be filtered here; filters comments too
    lines = [line for line in lines if not line.strip().split()[3].startswith('/') and not
             line.startswith('#')]
    splitLines = [line.strip().split() for line in lines]

    # calculate target compilation duration and add it to dict
    hash_target_duration_dict = {}
    for line in splitLines:
        duration = int(line[1]) - int(line[0])
        hash = line[2]
        target = line[3]

        # filter out lines with duplicate times and concatenate target names
        if hash not in hash_target_duration_dict:
            target_duration_dict[target] = duration
            # add target,duration with new hash
            hash_target_duration_dict[hash] = (target, duration)
        else:
            previous_target = hash_target_duration_dict[hash][0]
            # concatenate previous target with same hash to this one
            concated_target = previous_target + ";" + target
            # remove old target entry and add concatenated target = duraiton
            target_duration_dict[concated_target] = \
                target_duration_dict.pop(previous_target)
            # update target name in hash dict
            hash_target_duration_dict[hash] = (concated_target, duration)

    return target_duration_dict


def format_time(time):
    """Converts a time into a human-readable format"""

    time /= 1000
    if time < 60:
        return '%.1fs' % time
    if time < 60 * 60:
        return '%dm%.1fs' % (time / 60, time % 60)
    return '%dh%dm%.1fs' % (time / (60 * 60), time % (60 * 60) / 60, time % 60)


def generate_webtreemap(current_dict: dict, baseline_dict: dict, logfile: str) -> None:
    """Create file for webtreemap to generate an HTML from; if target is new, append _NEW"""
    with open(logfile + ".webtreemap", 'w') as file_pointer:
        for target in current_dict.keys():
            new_tag = ''
            if baseline_dict and target not in baseline_dict.keys():
                new_tag = '_NEW'

            file_pointer.write(str(current_dict[target]) + ' ' + target + '_'
                               + format_time(current_dict[target]) + new_tag + '\n')


def get_total_time(target_duration_dict: dict) -> int:
    """Return sum of durations for all targets in dict"""
    total_time = 0
    for target in target_duration_dict.keys():
        total_time += target_duration_dict[target]
    return total_time


def get_total_time_intersect(target_duration_dict_a: dict, target_duration_dict_b: dict) -> int:
    """Return sum of durations for targets in A that are also in B"""
    total_time = 0
    for target in target_duration_dict_a.keys():
        if target in target_duration_dict_b.keys():
            total_time += target_duration_dict_a[target]
    return total_time


def print_report(current_dict: dict, baseline_dict: dict = None) -> None:
    """Print report with results of profiling to stdout"""

    # If the targets/outputfiles have changed between baseline and current, we are using
    # total_time_intersect to calculate delta (ratio of durations of targets) instead of total_time
    if baseline_dict and baseline_dict.keys() != current_dict.keys():
        msg = ("Warning: the targets in the current logfile differ from those in the baseline"
               "logfile; therefore the time and time percentage deltas TD and %TD for each target"
               "as well as for the entire build are calculated without taking the added/removed"
               "targets into account, but the total build time at the end does take them into"
               "account. If the added/removed targets modify the behavior of targets in both"
               "logfiles, the D delta may not make sense.\n-----\n")
        print(msg)
        target_mismatch = True
        total_time_current_intersect = get_total_time_intersect(current_dict, baseline_dict)
        total_time_baseline_intesect = get_total_time_intersect(baseline_dict, current_dict)
    else:
        target_mismatch = False

    header = [f'{"Target:":60}', f"{'%':4}", f"{'D':5}", f"{'T':8}",
              f"{'TD':8}", f"{'%TD':5}", "Note"]
    print(' | '.join(header))

    total_time_current = get_total_time(current_dict)
    if baseline_dict:
        total_time_baseline = get_total_time(baseline_dict)

    # sort targets/outputfiles by % taken of build time
    current_dict = dict(sorted(current_dict.items(), key=lambda item: item[1], reverse=True))

    for target in current_dict.keys():
        # percentage of build time that the target took
        perc = current_dict[target]/total_time_current * 100

        # difference between perc in current and in baseline
        delta = 0
        if baseline_dict:
            if target_mismatch:
                if target in baseline_dict.keys():
                    delta = current_dict[target]/total_time_current_intersect * 100 - \
                        baseline_dict[target]/total_time_baseline_intesect * 100
            else:
                delta = perc - (baseline_dict[target]/total_time_baseline * 100)
            if abs(delta) < 0.1:
                delta = 0

        # time is the formatted build time of the target
        time = format_time(current_dict[target])

        # time_delta is the formatted time difference between current and baseline
        if baseline_dict and target in baseline_dict.keys():
            time_delta = current_dict[target] - baseline_dict[target]
            if abs(time_delta) < 60:
                time_delta = 0
            time_delta = format_time(time_delta)
        else:
            time_delta = 0

        # perc_time_delta is a percentage difference of before and after build times
        if baseline_dict and target in baseline_dict.keys():
            perc_time_delta = (current_dict[target]/baseline_dict[target]) * 100 - 100
        else:
            perc_time_delta = 0

        line = [f'{target:60}', f"{perc:4.1f}", f"{delta:5.1f}", f"{time:>8}",
                f"{time_delta:>8}", f"{perc_time_delta:5.1f}"]
        # if target was not in baseline, append note
        if baseline_dict and target not in baseline_dict.keys():
            line.append("Not in baseline")

        # if target has multiple output files, print them on separate lines
        # (times only on the last line)
        if(';' in target):
            print("\n".join(target.rsplit(';', 1)[0].split(';')))
            split_target = target.rsplit(';', 1)[1]
            line[0] = f'{split_target:60}'
        print(' | '.join(line))

    # Print time and % delta of the whole build time
    if baseline_dict:
        # total_perc_time_delta is the percentage change of build times between current and baseline
        total_time_delta = total_time_current - total_time_baseline
        if abs(total_time_delta) < 60:
            total_time_delta = 0
        total_time_delta = format_time(total_time_delta)
        total_perc_time_delta = (total_time_current / total_time_baseline) * 100 - 100
        line = ["-----\nTotal time:", format_time(total_time_current),
                "| TD", f'{total_time_delta:>8}', "| %TD", f'{total_perc_time_delta:+5.1f}']
        # if there are different targets in current and baseline log, add intersect deltas,
        # which compare build times while omitting conficting build targets
        if target_mismatch:
            intersect_time_delta = total_time_current_intersect - total_time_baseline_intesect
            if abs(intersect_time_delta) < 60:
                intersect_time_delta = 0
            intersect_time_delta = format_time(intersect_time_delta)
            line.append(f'| intersect TD {intersect_time_delta:>8}')
            intersect_perc_time_delta = (total_time_current_intersect /
                                         total_time_baseline_intesect) * 100 - 100
            line.append(f'| intersect %TD {intersect_perc_time_delta:+5.1f}')
        print(' '.join(line))
    else:
        print("-----\nTotal time:", format_time(total_time_current))

    # Print targets which are present in baseline but not in current log
    if baseline_dict:
        removed = [target for target in baseline_dict.keys() if target not in current_dict.keys()]
        print("-----\nTargets omitted from baseline:\n", '\n'.join(removed))


def main() -> None:
    """Parse args, check for python version, then generate webtreemap HTML and print report"""

    # Dict key order used by print_report only specified in 3.7.0+
    if sys.version_info < (3, 7, 0):
        sys.stderr.write("You need python 3.7 or later to run this script\n")
        sys.exit(1)

    # Parse arguments
    parser = argparse.ArgumentParser(description='Create .webtreemap and print profiling report',
                                     usage='./build_profiler_report.py <logflie> [--baseline]')
    parser.add_argument('logfile', type=str, help='Ninja logfile to compare against baseline')
    parser.add_argument('--baseline', dest='skipBaseline', action='store_const',
                        const=True, default=False, help='Do not compare logfile with baseline log \
                        (default: compare baseline logfile with current logfile)')

    args = parser.parse_args()

    if args.skipBaseline:
        baseline_dict = None
    else:
        baseline_dict = load_log_file("0.ninja_log")

    logfile = sys.argv[1]
    current_dict = load_log_file(sys.argv[1])

    generate_webtreemap(current_dict, baseline_dict, logfile)
    print_report(current_dict, baseline_dict)


if __name__ == "__main__":
    main()
