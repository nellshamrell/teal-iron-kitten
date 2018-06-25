## Adding additional toolchain targets to plans / core-plans

## NOTES

For this experiment, I'm operating under the assumption that we are moving forward with a new linux platform based on glibc-2.25 or earlier.
I'm also making the assumption that we will start using 'target triplet': arch-platform-toolchain, either by extending necessary components to know about the toolchain or utilizing the existing tuple and (optionally) embedding toolchain in platform.  Ex: x86_64-linux, x86_64-linux_glibc225

I'm also making the assumption that we'd have to treat hooks, and by extension config/default.toml, the same as plans and be able to target toolchain differences with the same mechanism. I'd hope we wouldn't have to but we won't know until we find the one edge case.   Windows/Linux split is currently already in this case.

I will also be considering the effect of adding additional architectures, under the assumption we will eventually want to target ARM.  I'm not considering that work in scope, merely the effects it would have, in order to avoid re-work and/or fatigue? by our users if we have to make major changes again. 

The experiment will be focusing on plans,  but includes other components here to track how changes I experiment with may impact them. 

## The Experiment

I'll use ruby/ruby24 as a substitute for glibc. The application will be a Rails app, without scaffolding so that we can include run hook as well as the plan in this discussion. This repository will contain one directory for each of the above options. Any additional options will be added to this document as they are experimented with. 

##  What needs to happen for this to work? 

### Plans / Core-plans

#### Metadata
Any changed we make should *not* require our users to update their plans in order for things to continue working as-is.

Plan files will need to be updated with additional metadata.  For the upcoming work we will need to track, at minimum, supported toolchains. We should consider supported architectures and platforms as well. We could utilize a single metadata value.  Default values should reflect the world as it is today. 

** Names are so we have concrete examples ** 

`pkg_supported_arch=()`     
`pkg_supported_platform=()`   # This is implied in the extention of the file today.  Do we ever support Darwin, *BSD, Solaris, etc?  Then this may need to be explicit and not implied.
`pkg_supported_toolchains=()`

or

`pkg_supported_triplets=()`

##### Questions
If users provide no value, do we assume that plan authors intend to support everything on their target platform, regardless of architecture or toolchain? Or only our 'rolling-release' toolchain. Can we make the same assumptions about architecture?

_SM_  I think we should assume that rolling release is the only target unless otherwise specified. Opt-in to old-and-busted feels like the right behavior.  


#### Structure

Where plans need to differ, how do we handle that?

##### Maximal-Branching 

Each plan would contain all information necessary to build on every triplet it supports. This would be accomplished by the Studio exposing what triplet it is currently targeting (this will likey need to be done in all cases), and having logic around each component that needs to vary.  

Will hooks need the same logic?  Supervisor will need to expose the target triplet in that case.  

_SM_ I think this would make package maintence more difficult, as you would need to to understand how a change affects all supported triplets, especially in the case of hooks.

##### Adding -toolchain to the directory a package is stored in.

This has the benefit of this is how musl packages are handled today. If we were to have core/glibc and core/glibc-255,  we would have to have logic in the dependent plans to load the correct one. Alternatively, the pkg_name could be shared between the two, but with different directory structure. 

The second option feels wrong, as there is today an implied contract between directory name and pkg_name. 

##### Nesting directories based on toolchain

This would allow for consistant naming between directory and pkg_name, however hab-plan-build (and possibly builder) would need to understand what to load and when. 

Ex:  
foo/plan.sh
foo/linux-glibc255/plan.sh 
and
foo/plan.sh [pkg_supported_triplets=(x86_64-linux-glibc x86_64-linux-glibc255)

Both would be potentially valid.

It would also allow for a clean seperation of hooks and configuration that needed to be different.  This would allow not only toolchain differences, but platform differences to live in the same directory.  

There could also be some shared code between the two, if we chose to follow a pattern like  foo/shared/plan.sh  that could be sourced and then overridden, or toolchain always sources the original and then overrides.  This pattern would still have the side affect of having to know how a change will affect all potential toolchains, making plan maintentence more difficult. 

##### Embedding toolchain in plan name

We could embed toolchain in the plan file name, ex: plan.glibc255.sh.  This would have the same pros/cons as the directory structure, but without being able to seperate hooks or configuration. We'd have to also embed the same information in hooks, or have branching logic there. 


##### Completely seperate repos

Maximal duplication.  This would be a nightmare to maintain, making sure that updates are made in both places, but would allow us to shut it all down very easily when it's time.  

_SM_  I don't really think this is an option, but I'm including it for completeness sake. There is likely more conversation that could be had than the above sentence, but it's not worth the time unless other people think this is a valid solution.


### Package Metadata

### Studio

### Hab CLI

### Hab Supervisor

### Builder


