import requests, os
from requests.exceptions import HTTPError
from datetime import datetime
from dateutil.parser import isoparse

###
# API URLs
# org-repos: https://qnetgit.cms.gov/api/v3/orgs/{org}/repos
# repo-action-runs: https://qnetgit.cms.gov/api/v3/repos/{org}/{repo["name"]}/actions/runs
# runs-jobs: https://qnetgit.cms.gov/api/v3/repos/{org}/{repo["name"]}/actions/runs/{run["id"]}/jobs
# job-billable: /repos/{owner}/{repo}/actions/runs/{run_id}/timing ## Not used for self-hosted
###


## Change this to use your own PAT or authentication Token
headers = {
  'Authorization': f'token {os.environ["GHE_HFC_PAT"]}'
}
org = "EQRS"

def get_repos():
    total_time = 0
    month_start = isoparse('2022-03-01T00:00:00Z')
    month_end = isoparse('2022-03-31T23:59:59Z')


    url = f'https://qnetgit.cms.gov/api/v3/orgs/{org}/repos'
    try:
        jRepos = requests.request("GET", url, headers=headers).json()
        for repo in jRepos:
            print(f'Repo: {repo["name"]}')

            run_url = f'https://qnetgit.cms.gov/api/v3/repos/{org}/{repo["name"]}/actions/runs'
            jRuns = requests.request("GET", run_url , headers=headers).json()

            ## Filter down the runs query to only return those in the date range specified
            filter_runs = filter(lambda run: month_end > isoparse(run["created_at"]) > month_start, jRuns["workflow_runs"])
            for run in filter_runs:
                print(f'  Run: {run["name"]}')
                print(f'  Id : {run["id"]}')

                job_url = f'https://qnetgit.cms.gov/api/v3/repos/{org}/{repo["name"]}/actions/runs/{run["id"]}/jobs'
                jJobs = requests.request("GET", job_url , headers=headers).json()
                
                for job in jJobs["jobs"]:
                    print(f'    Job ID: {job["id"]}')
                    print(f'      conclusion: {job["conclusion"]}')

                    start_time = isoparse(job["started_at"])
                    completed_time = isoparse(job["completed_at"])
                    
                    print(f'      start time: {start_time}')
                    print(f'      stop time : {completed_time}')
                    
                    delta = completed_time - start_time
                    print(f'      delta time: {delta}')
                    
                    total_time+=delta.seconds
                    print(f'== Running Total: {total_time}')
        print(f'****** Total Time (seconds): {total_time}')

    except HTTPError as http_err:
        print(f'HTTP error occured: {http_err}')
        print(f'Request: {http_err.request}')
    except Exception as err:
        print(f'Other error occurred: {err}')
        print(err.print_exc())

get_repos()