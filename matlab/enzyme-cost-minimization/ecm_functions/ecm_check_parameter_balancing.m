% ECM_CHECK_PARAMETER_BALANCING - Checks for balanced parameters
%
% ecm_check_parameter_balancing(r, r_orig, network, quantity_info_used, show_graphics)

function ecm_check_parameter_balancing(r, r_orig, network, quantity_info_used, show_graphics)

eval(default('show_graphics','1','quantity_info_used','[]'));

  i_mu0   = label_names('mu0', quantity_info_used.Symbol);
  i_Keq   = label_names('Keq', quantity_info_used.Symbol);
  i_Kcatf = label_names('Kcatf', quantity_info_used.Symbol);
  i_Kcatr = label_names('Kcatr', quantity_info_used.Symbol);
  i_KM    = label_names('KM', quantity_info_used.Symbol);
  i_KA    = label_names('KA', quantity_info_used.Symbol);
  i_KI    = label_names('KI', quantity_info_used.Symbol);
  
  lower_bound  = cell_string2num(quantity_info_used.LowerBound);
  upper_bound  = cell_string2num(quantity_info_used.UpperBound);
  prior_median = cell_string2num(quantity_info_used.PriorMedian);
  prior_std    = cell_string2num(quantity_info_used.PriorStd);


threshold_mu = 5; % kJ/mol
threshold = 2;

mu0_change = r.mu0-r_orig.mu0; 
ind_change = find(isfinite(mu0_change) .* abs(mu0_change)>0);
if length(ind_change),
 display(sprintf('Changes of mu0 values (additive change > %f kK/mol shown',threshold_mu));
 print_matrix(mu0_change(ind_change), network.metabolites(ind_change))
end

log_Keq_change = log10(r.Keq./r_orig.Keq); 
ind_change = find(isfinite(log_Keq_change) .* abs(log_Keq_change) > log10(threshold));
if length(ind_change),
display(sprintf('Changes of Keq values (fold change > %f shown)',threshold));
print_matrix(10.^log_Keq_change(ind_change), network.actions(ind_change))
end

log_Kcatf_change = log10(r.Kcatf./r_orig.Kcatf); 
ind_change = find(isfinite(log_Kcatf_change) .* abs(log_Kcatf_change) > log10(threshold));
if length(ind_change),
display(sprintf('Changes of Kcatf values (fold change > %f shown)',threshold));
print_matrix(10.^log_Kcatf_change(ind_change), network.actions(ind_change))
end

if find(r.Kcatf < 1.01 * lower_bound(i_Kcatf)),
  display('Kcatf values close to lower bound');
  mytable(network.actions(find(r.Kcatf < 1.01 * lower_bound(i_Kcatf))),0)
else
  display('No Kcatf values close to lower bound');
end
if find(r.Kcatf > 0.99 * upper_bound(i_Kcatf)),
  display('Kcatf values close to upper bound');
  mytable(network.actions(find(r.Kcatf > 0.99 * upper_bound(i_Kcatf))),0)
else
  display('No Kcatf values close to upper bound');
end


log_Kcatr_change = log10(r.Kcatr./r_orig.Kcatr); 
ind_change = find(isfinite(log_Kcatr_change) .* abs(log_Kcatr_change) > log10(threshold));
if length(ind_change),
display(sprintf('Changes of Kcatr values (fold change > %f shown)',threshold));
print_matrix(10.^log_Kcatr_change(ind_change), network.actions(ind_change))
end

log_KM_change = log10(full(r.KM./r_orig.KM));
log_KM_change(~isfinite(log_KM_change)) = 0;
indices = find(abs(log_KM_change(:))>log10(threshold));
if length(indices), 
display(sprintf('Changes of KM values (fold change > %f shown)',threshold));
[~,order] = sort(abs(log_KM_change(indices)));
indices = indices(order(end:-1:1));
[ind_i,ind_j] = ind2sub(size(log_KM_change), indices);
for it = 1:length(indices),
 display(sprintf(' %s / %s: %f', network.actions{ind_i(it)}, network.metabolites{ind_j(it)}, 10.^log_KM_change(indices(it)))); 
end
end

log_KA_change = log10(full(r.KA./r_orig.KA));
log_KA_change(~isfinite(log_KA_change)) = 0;
indices = find(abs(log_KA_change(:))>log10(threshold));
[~,order] = sort(abs(log_KA_change(indices)));
indices = indices(order(end:-1:1));
if length(indices), 
display(sprintf('Changes of KA values (fold change > %f shown)',threshold));
[ind_i,ind_j] = ind2sub(size(log_KA_change), indices);
for it = 1:length(indices),
 display(sprintf(' %s / %s: %f', network.actions{ind_i(it)}, network.metabolites{ind_j(it)}, 10.^log_KA_change(indices(it)))); 
end
end

log_KI_change = log10(full(r.KI./r_orig.KI));
log_KI_change(~isfinite(log_KI_change)) = 0;
indices = find(abs(log_KI_change(:))>log10(threshold));
[~,order] = sort(abs(log_KI_change(indices)));
indices = indices(order(end:-1:1));
if length(indices), 
display(sprintf('Changes of KI values (fold change > %f shown)',threshold));
[ind_i,ind_j] = ind2sub(size(log_KI_change), indices);
for it = 1:length(indices),
 display(sprintf(' %s / %s: %f', network.actions{ind_i(it)}, network.metabolites{ind_j(it)}, 10.^log_KI_change(indices(it)))); 
end
end

if show_graphics,

  figure(1);
  subplot(2,3,1); plot(r_orig.Keq,  r.Keq, 'r.'); 
  title('Keq'); xlabel('Original data'); ylabel('Balanced values'); 
  set(gca, 'XScale','log','YScale','log'); 
  hold on; a = [min(r.Keq) max(r.Keq)]; plot([a(1) a(2)],[a(1) a(2)],'-k'); axis tight; 
  
  subplot(2,3,2); plot(r_orig.Kcatf,r.Kcatf,'r.'); 
  title('Kcatf'); xlabel('Original data'); ylabel('Balanced values');
  set(gca, 'XScale','log','YScale','log'); 
  hold on; a = [min(r.Kcatf) max(r.Kcatf)]; plot([a(1) a(2)],[a(1) a(2)],'-k'); axis tight; 

  subplot(2,3,3); plot(r_orig.Kcatr,r.Kcatr,'r.'); 
  title('Kcatr'); xlabel('Original data'); ylabel('Balanced values');
  set(gca, 'XScale','log','YScale','log'); 
  hold on; a = [min(r.Kcatr) max(r.Kcatr)]; plot([a(1) a(2)],[a(1) a(2)],'-k'); axis tight; 

  subplot(2,3,4); plot(r_orig.KM(:),r.KM(:),'r.'); 
  title('KM'); xlabel('Original data'); ylabel('Balanced values'); 
  set(gca, 'XScale','log','YScale','log'); 
  hold on; a = [min(r.KM(r.KM>0)), max(r.KM(:))];
  plot([a(1) a(2)],[a(1) a(2)],'-k');
  axis tight; 

  subplot(2,3,5); plot(r_orig.KA(:),r.KA(:),'r.'); 
  if sum(r.KA),
    title('KA'); xlabel('Original data'); ylabel('Balanced values');
    set(gca, 'XScale','log','YScale','log'); 
    hold on; a = [min(r.KA(r.KA>0)), max(r.KA(:))]; plot([a(1) a(2)],[a(1) a(2)],'-k'); axis tight; 
  end
  
  subplot(2,3,6); plot(r_orig.KI(:),r.KI(:),'r.'); 
  if sum(r.KI),
  title('KI'); xlabel('Original data'); ylabel('Balanced values');
  set(gca, 'XScale','log','YScale','log'); 
  hold on; a = [min(r.KI(r.KI>0)), max(r.KI(:))]; plot([a(1) a(2)],[a(1) a(2)],'-k'); axis tight; 
  end
  
  figure(2); clf 
  
  subplot(2,3,1); hold on;
  edges = log10(lower_bound(i_Keq)):1:log10(upper_bound(i_Keq));
  bar(edges+0.5,[histc(log10(r.Keq), edges), histc(log10(r_orig.Keq), edges)],'grouped'); colormap([1 0 1; 1 0 0]);
  title('log10 Keq'); a = axis; 
  plot(log10(lower_bound(i_Keq)) *[1 1],[0,a(4)],'k-');
  plot(log10(upper_bound(i_Keq)) *[1 1],[0,a(4)],'k-');
  plot(log10(prior_median(i_Keq)) *[1 1],[0,a(4)],'b-');
  plot([log10(prior_median(i_Keq)) + prior_std(i_Keq) *[-1,1] ], 0.95*a(4)*[1,1],'b-','Linewidth',2);
  axis([log10(lower_bound(i_Keq))-1,log10(upper_bound(i_Keq))+1,0,a(4)]);
  
  subplot(2,3,2); hold on;
  edges = log10(lower_bound(i_Kcatf)):0.5:log10(upper_bound(i_Kcatf));
  bar(edges+0.25,[histc(log10(r.Kcatf), edges), histc(log10(r_orig.Kcatf), edges)],'grouped'); colormap([1 0 1; 1 0 0]);
  title('log10 Kcatf'); a = axis; 
  plot(log10(lower_bound(i_Kcatf)) *[1 1],[0,a(4)],'k-');
  plot(log10(upper_bound(i_Kcatf)) *[1 1],[0,a(4)],'k-');
  plot(log10(prior_median(i_Kcatf)) *[1 1],[0,a(4)],'b-');
  plot([log10(prior_median(i_Kcatf)) + prior_std(i_Kcatf) * [-1,1] ], 0.95*a(4)*[1,1],'b-','Linewidth',2);
  axis([log10(lower_bound(i_Kcatf))-1,log10(upper_bound(i_Kcatf))+1,0,a(4)]);

  subplot(2,3,3); hold on;
  edges = log10(lower_bound(i_Kcatr)):0.5:log10(upper_bound(i_Kcatr));
  bar(edges+0.25,[histc(log10(r.Kcatr), edges), histc(log10(r_orig.Kcatr), edges)],'grouped'); colormap([1 0 1; 1 0 0]);
  title('log10 Kcatr'); a = axis; 
  plot(log10(lower_bound(i_Kcatr)) *[1 1],[0,a(4)],'k-');
  plot(log10(upper_bound(i_Kcatr)) *[1 1],[0,a(4)],'k-');
  plot(log10(prior_median(i_Kcatr)) *[1 1],[0,a(4)],'b-');
  plot([log10(prior_median(i_Kcatr)) + prior_std(i_Kcatr) *[-1,1] ], 0.95*a(4)*[1,1],'b-','Linewidth',2);
  axis([log10(lower_bound(i_Kcatr))-1,log10(upper_bound(i_Kcatr))+1,0,a(4)]);

  subplot(2,3,4); hold on;
  edges = log10(lower_bound(i_KM)):0.5:log10(upper_bound(i_KM));
  bar(edges+0.25,[histc(full(log10(r.KM(r.KM~=0))), edges), histc(log10(full(r_orig.KM(r_orig.KM~=0))), edges)],'grouped'); colormap([1 0 1; 1 0 0]);
  title('log10 KM'); a = axis; 
  plot(log10(lower_bound(i_KM)) *[1 1],[0,a(4)],'k-');
  plot(log10(upper_bound(i_KM)) *[1 1],[0,a(4)],'k-');
  plot(log10(prior_median(i_KM)) *[1 1],[0,a(4)],'b-');
  plot([log10(prior_median(i_KM)) + prior_std(i_KM) *[-1,1] ], 0.95*a(4)*[1,1],'b-','Linewidth',2);
  axis([log10(lower_bound(i_KM))-1,log10(upper_bound(i_KM))+1,0,a(4)]);
    
  subplot(2,3,5); hold on;
  edges = log10(lower_bound(i_KA)):0.5:log10(upper_bound(i_KA));
  bar(edges+0.25,[histc(full(log10(r.KA(r.KA~=0))), edges), histc(full(log10(r_orig.KA(r_orig.KA~=0))), edges)],'grouped'); colormap([1 0 1; 1 0 0]);
  title('log10 KA'); a = axis; 
  plot(log10(lower_bound(i_KA)) *[1 1],[0,a(4)],'k-');
  plot(log10(upper_bound(i_KA)) *[1 1],[0,a(4)],'k-');
  plot(log10(prior_median(i_KA)) *[1 1],[0,a(4)],'b-');
  plot([log10(prior_median(i_KA)) + prior_std(i_KA) *[-1,1] ], 0.95*a(4)*[1,1],'b-','Linewidth',2);
  axis([log10(lower_bound(i_KA))-1,log10(upper_bound(i_KA))+1,0,a(4)]);
    
  subplot(2,3,6); hold on;
  edges = log10(lower_bound(i_KI)):0.5:log10(upper_bound(i_KI));
  bar(edges+0.25,[histc(full(log10(r.KI(r.KI~=0))), edges), histc(full(log10(r_orig.KI(r_orig.KI~=0))), edges)],'grouped'); colormap([1 0 1; 1 0 0]);
  title('log10 KI'); a = axis; 
  plot(log10(lower_bound(i_KI)) *[1 1],[0,a(4)],'k-');
  plot(log10(upper_bound(i_KI)) *[1 1],[0,a(4)],'k-');
  plot(log10(prior_median(i_KI)) *[1 1],[0,a(4)],'b-');
  plot([log10(prior_median(i_KI)) + prior_std(i_KI) *[-1,1] ], 0.95*a(4)*[1,1],'b-','Linewidth',2);
  axis([log10(lower_bound(i_KI))-1,log10(upper_bound(i_KI))+1,0,a(4)]);


end 