function [f, u] = ecm_min_ecf2sp(x,pp)

% [f, u] = ecm_min_ecf2sp(x,pp)

delta_G_by_RT = pp.N_forward' * x - pp.log_Keq_forward;

u = abs(pp.v) ./ [ pp.kc_forward .* [1 - exp(delta_G_by_RT)] ./ [1 + exp(pp.log_Keq_forward) .* exp(delta_G_by_RT)] ];

f = max(pp.enzyme_cost_weights .* u(pp.ind_scored_enzymes));

if sum(delta_G_by_RT>0),
   f = 10^20 * max(delta_G_by_RT);
end
