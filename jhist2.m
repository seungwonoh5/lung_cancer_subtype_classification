function  hist2 = jhist2(ref, hol, mask, no_bins1,no_bins2)
% form joint hist for pRM analysis
% assume rnage between 0 and 4096
% need to provide ref_range = [min max]
% no_bins1 = ref_bin, no_bins2 = hol_bin

ref = ref(:); hol = hol(:); mask = mask(:); % make it long vector
no_bin_ref = no_bins1; 
no_bin_hol = no_bins2; 
joint_hist = zeros(no_bin_ref, no_bin_hol); % allocate histogram

%floor(ref.*no_bin_ref./range ) + 1;
scaled_gray_ref = floor(ref.*no_bin_ref./4095)+1;
scaled_gray_hol = floor(hol.*no_bin_hol./4095)+1;

for i = 1:length(ref)
    if(mask(i) > 0) 
        joint_hist(scaled_gray_ref(i), scaled_gray_hol(i)) = joint_hist(scaled_gray_ref(i), scaled_gray_hol(i)) + 1;
    end
end  % generate histograms

hist2 = joint_hist;

