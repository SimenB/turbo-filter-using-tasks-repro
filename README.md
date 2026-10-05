# `filterUsingTasks` drops package dependencies from `--filter=<pkg>...`

`app` depends on `lib` in `package.json`. Both have a `lint` script. `lint` depends on `^build`, and neither package has a `build` script.

With `futureFlags.filterUsingTasks` off, `turbo run lint --filter=app...` runs `app#lint` and `lib#lint`. With the flag on, it runs only `app#lint`. `lib#lint` comes back only when `lint` depends on `^lint`.

The [docs](https://turborepo.dev/docs/reference/configuration#filterusingtasks) say `...` traverses the task graph in addition to the package graph, so `lib#lint` should be selected in both cases.

## Run

```sh
npm install
npx turbo@canary run lint --filter='app...' --dry
```

`./repro.sh [version]` runs the filter with the flag off and on, against `lint.dependsOn` set to `[]`, `["^build"]` and `["^lint"]`. It restores `turbo.json` when it exits.

```
filterUsingTasks=false lint.dependsOn=[]          app#lint lib#lint
filterUsingTasks=false lint.dependsOn=["^build"]  app#lint lib#lint
filterUsingTasks=false lint.dependsOn=["^lint"]   app#lint lib#lint
filterUsingTasks=true  lint.dependsOn=[]          app#lint
filterUsingTasks=true  lint.dependsOn=["^build"]  app#lint
filterUsingTasks=true  lint.dependsOn=["^lint"]   app#lint lib#lint
```
