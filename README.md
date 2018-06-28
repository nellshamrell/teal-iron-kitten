# Getting started

`hab studio enter` 

This will automatically build a copy of `hab-plan-build` so that it is present for the `build` action.

To change your target platform `export TARGET=<your target>`.  This can be any arbitrary string right now.  This will override $pkg_target detection in hab plan build.

You can't consume packages for your TARGET right now, as the hab install libraries expect the TARGET to match the studio you're in. ( I think this is the behavior I'm seeing ).

Take a look at ruby, glibc, or kernel-headers in the core-plans directory to see examples of how to build for alternate targets.

## Notes

Any callback or variable with a relative path in it will have to be redefined, if sourcing the default plan

Any variables with interpolation will have to be redefined.

