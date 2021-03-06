# Integration Guide:  Porting Mimi Models from v0.4.0 to v0.5.0

## Overview

The release of Mimi v0.5.0 is a breaking release, necessitating the adaptation of existing models' syntax and structure in order for those models to run on this new version.  This guide provides an overview of the steps required to get most models using the v0.4.0 API working with v0.5.0.  It is **not** a comprehensive review of all changes and new functionalities, but a guide to the minimum steps required to port old models between versions.  For complete information on the new version and its functionalities, see the full documentation.

This guide is organized into six main sections, each descripting an independent set of changes that can be undertaken in any order desired.  For clarity, these sections echo the organization of the `userguide`.

1) Defining components
2) Constructing a model
3) Running the model
4) Accessing results
5) Plotting
6) Advanced topics

## Defining Components

The `run_timestep` function is now contained by the `@defcomp` macro, and takes the parameters `p, v, d, t`, referring to Parameters, Variables, and Dimensions of the component you defined.  The fourth argument is an AbstractTimestep, i.e., either a `FixedTimestep` or a `VariableTimestep`.  Similarly, the optional `init` function is also contained by `@defcomp`, and takes the parameters `p, v, d`.  Thus, as described in the user guide, defining a single component is now done as follows:

```julia
@defcomp component1 begin

    # First define the state this component will hold
    savingsrate = Parameter()

    # Second, define the (optional) init function for the component
    function init(p, v, d)
    end

    # Third, define the run_timestep function for the component
    function run_timestep(p, v, d, t)
    end

end
```

## Constructing a Model

In an effort to standardize the function naming protocol within Mimi, and to streamline it with the Julia convention, several function names have been changed.  The table below lists a **subset** of these changes, focused on the exported API functions most commonly used in model construction.  

| Old Syntax                | New Syntax                |
| ------------------------  |:-------------------------:|
|`connectparameter`         |`connect_parameter`        |
|`setleftoverparameters`    |`set_leftover_params!`     |
|`setparameter`             |`set_parameter!`           |
|`adddimension`             |`add_dimension!`            |
|`setindex`                 |`set_dimension!`           |  

Changes to various optional keyword arguments:

 - `connect_parameter`:  In the case that a component parameter is connected to a variable from a prior timestep, it is necessary to use the `offset` keyword argument to prevent a cycle.  The offset value is an `Int` specifying the offset in terms of timesteps as below.

```julia
connect_parameter(mymodel, :TargetComponent=>:parametername, :SourceComponent=>:variablename, offset = 1)
```
- `addcomponent`:  Previously the optional keyword arguments `start` and `stop` could be used to specify times for components that do not run for the full length of the model. These arguments are now `first` and `last` respectively.

```julia
addcomponent(mymodel, ComponentC; first=2010, last=2100)
```
                        
Finally, in order to finish connecting components, it is necessary to run `add_connector_comps` as below.

```julia
add_connector_comps(mymodel)

```

## Running a Model

## Accessing Results

## Plotting

This release of Mimi does not include the plotting functionality previously offered by Mimi.  While the previous files are still included, the functions are not exported as efforts are made to simplify and improve the plotting associated with Mimi.  

The new version does, however, include a new UI tool that can be used to visualize model results.  This `explore` function is described in the User Guide under **Advanced Topics**.

## Advanced Topics

### Timesteps and available functions

As previously mentioned, some relevant function names have changed.  These changes were made to eliminate ambiguity.  For example, the new naming clarifies that `is_last` returns whether the timestep is on the last valid period to be run, not whether it has run through that period already.  This check can still be achieved with `is_finished`, which retains its name and function.  Below is a subset of such changes related to timesteps and available functions.

| Old Syntax                | New Syntax                |
| ------------------------  |:-------------------------:|
|`isstart`                  |`is_first`                 |
|`isstop`                   |`is_last`                  |    

### Parameter connections between different length components

### More on parameter indices

### Updating an external parameter

The function `update_external_parameter` is now written as `update_external_param`.

### Setting parameters with a dictionary

The function `setleftoverparameters` is now written as `set_leftover_params!`.

### Using NamedArrays for setting parameters

### The internal 'build' function and model instances

###  The explorer UI
