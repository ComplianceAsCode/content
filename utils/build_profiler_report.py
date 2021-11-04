#!/usr/bin/python3
import sys


def LoadLogFile(file) -> dict:
    """Loads Targets and their durations from ninja logfile `file` and returns them in a dict"""

    with open(file, 'r') as fp:
        lines = fp.read().splitlines()

    # {Target: duration} dict
    TargetDurationDict = {}
    for line in lines:
        line = line.split()

        # ToDo - create better comment detection
        if line[0][0] != '#':

            # calculate target compilation duration and add it to dict
            duration = int(line[1]) - int(line[0])
            TargetDurationDict[line[3]] = duration

    return TargetDurationDict


def FormatTime(t):
    """Converts a time into a human-readable format"""

    t /= 1000
    if t < 60:
        return '%.1fs' % t
    if t < 60 * 60:
        return '%dm%.1fs' % (t / 60, t % 60)
    return '%dh%dm%.1fs' % (t / (60 * 60), t % (60 * 60) / 60, t % 60)


def GenerateWebTreeMap(CurrentDict: dict, BaselineDict: dict) -> None:
    """Create file for webtreemap to generate an HTML from; if target is new, append _NEW"""
    with open(sys.argv[1] + ".webtreemap", 'w') as fp:
        for target in CurrentDict.keys():
            new_tag = ''
            if BaselineDict and target not in BaselineDict.keys():
                new_tag = '_NEW'

            fp.write(str(CurrentDict[target]) + ' ' + target
                     + '_' + FormatTime(CurrentDict[target]) + new_tag + '\n')


def GetTotalTime(TargetDurationDict: dict) -> int:
    """Return sum of durations for all targets in dict"""
    total_time = 0
    for target in TargetDurationDict.keys():
        total_time += TargetDurationDict[target]
    return total_time


def GetTotalTimeIntersect(TargetDurationDict_A: dict, TargetDurationDict_B: dict) -> int:
    """Return sum of durations for targets in A that are also in B"""
    total_time = 0
    for target in TargetDurationDict_A.keys():
        if target in TargetDurationDict_B.keys():
            total_time += TargetDurationDict_A[target]
    return total_time


def PrintReport(CurrentDict: dict, BaselineDict: dict = None) -> None:
    """Print report with results of profiling to stdout"""

    # If the targets have changed between baseline and current, we are using total_time_intersect
    # to calculate delta (ratio of durations of targets) instead of total_time
    if BaselineDict and BaselineDict.keys() != CurrentDict.keys():
        print("Warning: the targets in the current logfile differ from those in the baseline\
             logfile; therefore the Δ delta is calculated without taking the added/removed\
                  targets into consideration. If the added/removed targets modify the behavior of\
                      targets in both logfiles, the Δ delta may not make sense.\n-----")
        target_mismatch = True
        total_time_current_intersect = GetTotalTimeIntersect(CurrentDict, BaselineDict)
        total_time_baseline_intesect = GetTotalTimeIntersect(BaselineDict, CurrentDict)
    else:
        target_mismatch = False

    header = [f'{"Target:":60}', f"{'%':4}", f"{'Δ':5}", f"{'T':8}", f"{'%Δ':5}", "Note"]
    print(' | '.join(header))

    total_time_current = GetTotalTime(CurrentDict)
    if BaselineDict:
        total_time_baseline = GetTotalTime(BaselineDict)

    # sort targets by % taken of build time
    temp = {k: v for k, v in sorted(CurrentDict.items(), key=lambda item: item[1], reverse=True)}
    CurrentDict = temp

    for target in CurrentDict.keys():
        # percentage of build time that the target took
        perc = CurrentDict[target]/total_time_current * 100

        # difference between perc in current and in baseline
        delta = 0
        if BaselineDict:
            if target_mismatch:
                if target in BaselineDict.keys():
                    delta = CurrentDict[target]/total_time_current_intersect * 100 - \
                        BaselineDict[target]/total_time_baseline_intesect * 100

            else:
                delta = perc - (BaselineDict[target]/total_time_baseline * 100)

        # time is the formatted build time of the target
        time = FormatTime(CurrentDict[target])

        # timeDelta a percentage difference of before and after build times 
        if BaselineDict and target in BaselineDict.keys():
            timeDelta = (CurrentDict[target]/BaselineDict[target]) * 100 - 100
        else:
            timeDelta = 0

        line = [f'{target:60}', f"{perc:4.1f}", f"{delta:5.1f}", f"{time:8}", f"{timeDelta:+5.1f}"]
        # if target was not in baseline, append note
        if BaselineDict and target not in BaselineDict.keys():
            line.append("Not in baseline")
        print(' | '.join(line))

    # Print time and % delta of the whole build time
    if BaselineDict:
        # totalDelta is the percentage change of build times between current and baseline
        totalDelta = (total_time_current / total_time_baseline) * 100 - 100
        line = ["-----\nTotal time:", FormatTime(total_time_current), "| %Δ", f'{totalDelta:+.1f}']
        # if there are different targets in current and baseline log, add intersect delta, which
        # compares build times while omitting conficting build targets
        if target_mismatch:
            intersectDelta = (total_time_current_intersect / total_time_baseline_intesect)\
                 * 100 - 100
            line.append(f'| intersect %Δ{intersectDelta:+5.1f}')
        print(' '.join(line))
    else:
        print("-----\nTotal time:", FormatTime(total_time_current))

    # Print targets which are present in baseline but not in current log
    if BaselineDict:
        removed = [target for target in BaselineDict.keys() if target not in CurrentDict.keys()]
        print("-----\nTargets omitted from baseline:\n", '\n'.join(removed))


def main() -> None:
    # Dict key order used by PrintReport only specified in 3.7.0+
    if sys.version_info < (3, 7, 0):
        sys.stderr.write("You need python 3.7 or later to run this script\n")
        exit(1)

    if len(sys.argv) != 2:
        print("Incorrect number of arguments")
        sys.exit(99)

    # skip loading baseline if we are creating it
    if sys.argv[1] != "0.ninja_log":
        BaselineDict = LoadLogFile("0.ninja_log")
    else:
        BaselineDict = None
    CurrentDict = LoadLogFile(sys.argv[1])

    GenerateWebTreeMap(CurrentDict, BaselineDict)
    PrintReport(CurrentDict, BaselineDict)


if __name__ == "__main__":
    main()
