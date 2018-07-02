# Getting started

`hab studio enter` 

This will automatically build a copy of `hab-plan-build` so that it is present for the `build` action.

To change your target platform `export TARGET=<your target>`.  This can be any arbitrary string right now.  This will override $pkg_target detection in hab plan build.

You can't consume packages for your TARGET right now, as the hab install libraries expect the TARGET to match the studio you're in. ( I think this is the behavior I'm seeing ).

Take a look at ruby, glibc, or kernel-headers in the core-plans directory to see examples of how to build for alternate targets.

## Notes

Any callback or variable with a relative path in it will have to be redefined, if sourcing the default plan

Any variables with interpolation will have to be redefined.


## hab plan build,  what's different

Lines
391, added pkg_target override while I experiment
2282-2284, compare pkg_target with pkg_target_excludes() a potential mechanism for plan authors to tell builder that this won't build on XYZ
2238-2259, add additional logic around plan detection. There is still some work here to handle edge cases but for experminations sake it's enough. 

##  Why this approach to multi-platform support?

A Habitat Plan is composed of more than a plan file. It can also optionally contain default.toml, config, and hooks, plus any other files a user might need to build (patches) and run.     
plan.sh and plan.ps1 are not “Linux” and “Windows” plan files,  they are “Plans for targets that support shell and powershell”.

plan.sh and plan.ps1 are fine living in the same directory for binary/library Plans.  When you add run hooks you need to be able to separate the remaining parts of the Plan.  Using nested target directory allows use to be very explicit, while having a generic fallback to minimize duplication where that is desired.

Why not `arch/platform`, `arch`, or `platform`?  Complexity.  Consider the following case:

```
plan.sh
arm/plan.sh
linux/plan.sh
```

When building on `arm-linux`, what is the correct plan to load? Do we consider all 3? How do we convey that to a user?  By using `target` we have a very clear fallback priority:

```
plan.sh
arm-linux/plan.sh
x86_64-linux/plan.sh
```

On `arm-linux`  we would build `arm-linux/plan.sh`, on `x86_64-linux` we would build `x86_64-linux/plan.sh`,  on all other Shell platforms, we would build `plan.sh`
