# Submodules Alternative

An easy-to-use Git modules alternative to make the cloning process easier.

## What's the difference?

- Cloning repositories for is now super easier: anyone clone the repository **without the need of Git**. No more `clone recursive` or `submodule update` commands!
- Submodule addition/update is automated by GitHub Actions (if desired), making it easier to integrate in your projects.
- Lightweight and documented codebase written in [Lua](https://www.lua.org/) v5.3.0.
- Git Submodules can be a bit messy or confusing sometimes, which this tool improves.
<!-- - Easily specify which files are ignored at the moment of updating the repositories. This is very useful if you want to modify a repository/submodule. -->

## Usage

1. Create a new file named `repos.lua` (or as you desire) with all your desired repositories ([template](hhttps://github.com/Panquesito7/submodules-alternative/blob/main/repos.lua) file).

Your `repos.lua` file should look similar to the following.

```lua
local repos = {
    {
        name = "opencv",
        url = "https://github.com/opencv/opencv",
        dir = "libs/",
        clone_modules = true
    },
    {
        name = "texto",
        url = "https://github.com/realstealthninja/texto",
        dir = "libs/",
        clone_modules = false
    },
}

return {
    repos = repos
}
```

### GitHub Actions

This GitHub Action workflow will automatically both clone\
all the repositories and update them if there's any update.

```yml
name: Test the scripts work
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
      - uses: Panquesito7/submodules-alternative@v1
        with:
          repos_filename: repos
          use_pr: true
          branch_name: submodule-update
          commit_message: "Add/update submodules"
          add_repos: false      # This will clone all the repositories listed in your repos file
          update_repos: true    # When enabled, this will update all the repositories
```

You can also configure to run the workflow manually by using `workflow_dispatch` instead of `schedule`.\
For more information about Cron, you can check [CronHub](https://crontab.cronhub.io/).

### Manually

1. Run `fetch-repos.lua` to clone all the repositories automatically.

> **Note:**
>
> You will need to install Lua v5.3.0 in your\
> machine in case you do not have it installed.
>
> Download: <https://www.lua.org/download.html>

```bash
lua fetch-repos.lua <repos_filename> # No filename format required!
```

3. Once done, you can commit and push changes.

```bash
git add .
git commit -m "Add modules"
git push
```

4. Done! All of your repositories are now available in your project, and can be updated later on.

If you've updated your repositories list, you can always run the script again and it'll clone the new repositories.

## Updating the repositories

By using GitHub Actions, the repositories will be updated automatically.\
If you wish to do that manually, you can run the following script.

```bash
lua update-repos.lua <repos_filename> # No filename format required!
```

## License

See [`LICENSE`](LICENSE) for full information.
