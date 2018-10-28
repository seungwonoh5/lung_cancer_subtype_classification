
addpath(genpath('./NIfTI_20140122')); % add NIfTI library

data = csvread('/Users/apple/Documents/MATLAB/IN_histogram.csv', 1,0);
% load a vector of subject numbers
load('/Users/apple/Documents/MATLAB/sub_new2.mat'); 

for i=1:length(sub)
    % create a string of full path
    fpath = strcat('/Users/apple/Documents/MATLAB/Medical/Current/Sub', num2str(sub(i)));
    cd(fpath) % Move the file directory 'fpath'

    % Load raw image
    data1 = load_nii(strcat('Sub',num2str(sub(i)),'_GGO.nii')); 
    rGGO = data1.img;
    data2 = load_nii(strcat('Sub',num2str(sub(i)),'_VNC.nii')); 
    rVNC = data2.img;

    % cast data type to double
    rVNC = double(rVNC); 
    rGGO = double(rGGO);

    % image flip for correcting ROI location
    flip_lr(strcat(num2str(sub(i)),'.hdr'),'flip_roi.nii');
    data3 = load_nii('flip_roi.nii'); 
    roi = data3.img;

    clear data1 data2 data3

    % Convert raw images to new image with positive value
    % VNC : -1024 ~ 3071 -> 0 ~ 4095
    % Iodine : -100 ~ 528 -> 0 -> 628

    if (min(rVNC(:)) < 0)
        rVNC = rVNC + 1024; % assume range [0 4095]
    end 
    if (min(rGGO(:)) < 0)
        rGGO = rGGO + 100; % assume range [0 1749] 
    end 

    % Genarate joint histogram by code
    hist = jhist2(rGGO,rVNC,roi,147,45);
    hist = hist(:);
    hist = transpose(hist);
    
    data = [data; hist]; % add one patient
    
    clear hist rhist gcen val tmp* pat_num idx rGGO roi rVNC
end

csvwrite('/Users/apple/Documents/MATLAB/INPUT_hist.csv',data);
