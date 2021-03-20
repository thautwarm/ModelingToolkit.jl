module ODEPrecompileTest
    using ModelingToolkit

    function system(; kwargs...)
        # Define some variables
        @parameters t σ ρ β
        @variables x(t) y(t) z(t)
        D = Differential(t)

        # Define a differential equation
        eqs = [D(x) ~ σ*(y-x),
            D(y) ~ x*(ρ-z)-y,
            D(z) ~ x*y - β*z]

        de = ODESystem(eqs)
        return ODEFunction(de, [x,y,z], [σ,ρ,β]; kwargs...)
    end

    # Build an ODEFunction as part of the module's precompilation. These cases
    # will not work, because the generated RGFs are put into the ModelingToolkit cache.
    const f_bad = system()
    const f_noeval_bad = system(; eval_expression=false)

    # Setting eval_expression=false and eval_module=[this module] will ensure
    # the RGFs are put into our own cache, initialised below.
    import GeneralizedGenerated: NGG
    const RefValPool = NGG.RefValPool
    const RefValIndex = NGG.RefValIndex
    const ExprPool = NGG.ExprPool
    const ExprIndex = NGG.ExprIndex
    const CallPool = NGG.CallPool
    const CallIndex = NGG.CallIndex
    const f_noeval_good = system(; eval_expression=false, eval_module=@__MODULE__)
end
