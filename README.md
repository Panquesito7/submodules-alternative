# Submodules Alternative

An easy-to-use Git (Sub)modules alternative to make the cloning process easier.

## What's the difference?

- Cloning repositories is now super easier: anyone can clone your repository **without the need for Git**. No more `clone recursive` or `submodule update` commands!
- Submodule addition/update is automated by GitHub Actions (if desired), making it easier to integrate into your projects.
- Lightweight and documented codebase in [Lua](https://www.lua.org/) v5.3.3.
- Git Submodules can sometimes be messy or confusing, which this tool aims to solve.
<!-- - Easily specify which files are ignored at the moment of updating the repositories. This is very useful if you want to modify a repository/submodule. -->

## Usage

1. Create a new file named `repos.lua` (or as you desire) with all your selected repositories ([template](https://github.com/Panquesito7/submodules-alternative/blob/main/repos-template.lua) file).

Your `repos.lua` file should look similar to the following.

```lua
local repos = {
    {
        name = "opencv",
        url = "https://github.com/opencv/opencv",
        dir = "libs/",
        def_branch = "master"
    },
    {
        name = "texto",
        url = "https://github.com/realstealthninja/texto",
        dir = "libs/"
    },
}

-- Fully needed, so that the scripts can access the repositories.
return {
    repos = repos
}
```

### GitHub Actions

This GitHub Action workflow will automatically update or clone the desired repositories.\
You can choose to update, clone, or do both actions.

```yml
name: Submodules Alternative
on:
  schedule:
  #        ┌───────────── minute (0 - 59)
  #        │  ┌───────────── hour (0 - 23)
  #        │  │ ┌───────────── day of the month (1 - 31)
  #        │  │ │ ┌───────────── month (1 - 12 or JAN-DEC)
  #        │  │ │ │ ┌───────────── day of the week (0 - 6 or SUN-SAT)
  #        │  │ │ │ │
  #        │  │ │ │ │
  #        │  │ │ │ │
  #        *  * * * *
  - cron: '0 0 * * 1' # This would run weekly on Monday at 00:00 UTC
jobs:
  update-repos:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0 # This pulls changes before doing any changes
      - uses: Panquesito7/submodules-alternative@v1.3.0
        with:
          repos_filename: repos    # In case your file is named `repos.lua`, you can leave it as `repos`.
          use_pr: true             # Whether to create a pull request when updating/adding the repositories.
          branch_name: repo-update # The branch name to use (only if `use_pr` is enabled).
          commit_message: "Update" # The commit message used when pushing (optional; basic message is used).
          add_repos: false         # If enabled, this will clone all the repositories listed in your repos file.
          update_repos: true       # When enabled, this will attempt to update all the repositories.
          squash_commits: false    # Whether to squash all commits or not (experimental). USE ONLY ON `use_pr` FOR SAFETY.
```

You can also configure to run the workflow manually by using `workflow_dispatch` instead of `schedule`.\
For more information about Cron, you can check [CronHub](https://crontab.cronhub.io/).

### Manually

1. Run `fetch-repos.lua` to clone all the repositories automatically.

> **Note**
>
> You will need to install Lua v5.3.3 in your\
> machine in case you do not have it installed.
>
> Download: <https://www.lua.org/download.html>
>
> **Both `fetch-repos.lua` and `update-repos.lua` require\
> `check-variables.lua` to make sure everything is set properly.**

```bash
lua fetch-repos.lua <repos_filename> # No filename format required!
```

2. Once done, you can push changes. Committing is already done by the script.

```bash
git push
```

3. Done! All of your repositories are now available in your project and can be updated later on. 🎉

If you've updated your repositories list, you can always run the script again and it'll clone the new repositories.

## Updating the repositories

By using GitHub Actions, the repositories will be updated automatically.\
If you wish to do that manually, you can run the following script.

```bash
lua update-repos.lua <repos_filename> # No filename format required!
```

## To-do

- If the squash commits option is enabled, a new repository is added, and the workflow is run again, the commits should be squashed using `force-with-lease`.
- Make sure all the options and everything work perfectly fine.
- Clean up the action code to work faster and better.
- Create a PR per repository update, just like Dependabot does.

## License

See [`LICENSE`](LICENSE) for full information.
