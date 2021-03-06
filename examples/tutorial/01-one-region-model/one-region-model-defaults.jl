using Mimi

@defcomp grosseconomy begin
    YGROSS  = Variable(index=[time])    # Gross output
    K       = Variable(index=[time])    # Capital
    l       = Parameter(index=[time], default=[(1. + 0.015)^t * 6404 for t in 1:20])   # Labor
    tfp     = Parameter(index=[time], default=[(1 + 0.065)^t * 3.57 for t in 1:20])    # Total factor productivity
    s       = Parameter(index=[time], default=(ones(20) * 0.22))   # Savings rate
    depk    = Parameter(default=0.1)    # Depreciation rate on capital - Note that it has no time index
    k0      = Parameter(default=130.0)  # Initial level of capital
    share   = Parameter(default=0.3)    # Capital share

    function run_timestep(p, v, d, t)
        # Define an equation for K
        if t == 1
            v.K[t]  = p.k0  # Note the use of v. and p. to distinguish between variables and parameters
        else
            v.K[t]  = (1 - p.depk)^5 * v.K[t-1] + v.YGROSS[t-1] * p.s[t-1] * 5
        end

        # Define an equation for YGROSS
        v.YGROSS[t] = p.tfp[t] * v.K[t]^p.share * p.l[t]^(1-p.share)
    end
end

@defcomp emissions begin
    E       = Variable(index=[time])    # Total greenhouse gas emissions
    sigma   = Parameter(index=[time], default=[(1. - 0.05)^t * 0.58 for t in 1:20])   # Emissions output ratio
    YGROSS  = Parameter(index=[time])   # Gross output - Note that YGROSS is now a parameter

    function run_timestep(p, v, d, t)
        # Define an eqation for E
        v.E[t] = p.YGROSS[t] * p.sigma[t]   # Note the p. in front of YGROSS
    end
end

@Mimi.defmodel model begin

    index[time] = 2015:5:2110

    # Order matters here. If the emissions component were defined first, the model would not run.
    component(grosseconomy)
    component(emissions)

    #
    # Default values are now provided in @defcomp
    #
    # Set parameters for the grosseconomy component
    # grosseconomy.l = [(1. + 0.015)^t * 6404 for t in 1:20]
    # grosseconomy.tfp = [(1 + 0.065)^t * 3.57 for t in 1:20]
    #
    # grosseconomy.s = ones(20) * 0.22
    # grosseconomy.depk = 0.1
    # grosseconomy.k0 = 130.
    # grosseconomy.share = 0.3
    #
    # Set parameters for the emissions component
    # emissions.sigma = [(1. - 0.05)^t * 0.58 for t in 1:20]

    # Connect parameters
    grosseconomy.YGROSS => emissions.YGROSS
end

# Above macro yields this:
# quote
#     tutorial = (Mimi.Model)()
#     (Mimi.set_dimension!)(tutorial, :time, 2015:5:2110)
#     (Mimi.addcomponent)(tutorial, Main.grosseconomy, :grosseconomy)
#     (Mimi.addcomponent)(tutorial, Main.emissions, :emissions)
#     (Mimi.set_parameter!)(tutorial, :grosseconomy, :l, [(1.0 + 0.015) ^ t * 6404 for t = 1:20])
#     (Mimi.set_parameter!)(tutorial, :grosseconomy, :tfp, [(1 + 0.065) ^ t * 3.57 for t = 1:20])
#     (Mimi.set_parameter!)(tutorial, :grosseconomy, :s, ones(20) * 0.22)
#     (Mimi.set_parameter!)(tutorial, :grosseconomy, :depk, 0.1)
#     (Mimi.set_parameter!)(tutorial, :grosseconomy, :k0, 130.0)
#     (Mimi.set_parameter!)(tutorial, :grosseconomy, :share, 0.3)
#     (Mimi.set_parameter!)(tutorial, :emissions, :sigma, [(1.0 - 0.05) ^ t * 0.58 for t = 1:20])
#     (Mimi.connect_parameter)(tutorial, :emissions, :YGROSS, :grosseconomy, :YGROSS)
#     (Mimi.add_connector_comps)(tutorial)
# end

run(model)

# Show model results
model[:emissions, :E]

# Or, as a DataFrame
getdataframe(model, :emissions, :E)
