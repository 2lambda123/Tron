#!/usr/bin/env python3.8
import logging
import sys

import pytimeparse

from tron.commands import cmd_utils
from tron.commands.client import Client


log = logging.getLogger("check_exceeding_time")


def parse_cli():
    parser = cmd_utils.build_option_parser()
    parser.add_argument(
        "--job",
        default=None,
        help="Check if a particular job exceeded a time to run. If unset checks all jobs",
    )
    parser.add_argument(
        "--time",
        help="This is used to specify the time that if any job exceeds will show. Defaults to 5 hours",
        type=int,
        dest="time_limit",
        default=18000,
    )
    args = parser.parse_args()
    return args


def check_if_time_exceeded(job_runs, job_expected_runtime, result):
    states_to_check = {"queued", "scheduled", "cancelled", "skipped"}
    for job_run in job_runs:
        if job_run.get("state", "unknown") not in states_to_check:
            if is_job_run_exceeding_expected_runtime(
                job_run,
                job_expected_runtime,
            ):
                result.append(job_run["id"])
    return


def is_job_run_exceeding_expected_runtime(job_run, job_expected_runtime):
    states_to_check = {"queued", "scheduled", "cancelled", "skipped"}
    if (
        job_expected_runtime is not None
        and job_run.get(
            "state",
            "unknown",
        )
        not in states_to_check
    ):
        duration_seconds = pytimeparse.parse(job_run.get("duration", ""))
        if duration_seconds and duration_seconds > job_expected_runtime:
            return True
    return False


def check_job_time(job, time_limit, result):
    job_runs = sorted(
        job.get("runs", []),
        key=lambda k: (k["end_time"] is None, k["end_time"], k["run_time"]),
        reverse=True,
    )

    check_if_time_exceeded(job_runs, time_limit, result)


def main():
    args = parse_cli()
    cmd_utils.setup_logging(args)
    cmd_utils.load_config(args)
    client = Client(args.server, args.cluster_name)
    result = []

    url_index = client.index()
    if args.job is None:
        jobs = client.jobs(include_job_runs=True)
        for job in jobs:
            check_job_time(job=job, time_limit=args.time_limit, result=result)
    else:
        job_url = client.get_url(args.job)
        job = client.job_runs(job_url)
        check_job_time(job=job, client=client, url_index=url_index, result=result)

    if result is None:
        print("All jobs ran within the time limit")
    else:
        print(f"These are the runs that took longer than {args.time_limit} to run: {result}")
    return


if __name__ == "__main__":
    sys.exit(main())
