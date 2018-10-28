%% Script to combine raw pictures and masks
% To make script work properly, in the same folder must be 2 folders:
% dicom/    masks/      These folders should contain:
% dicom/022/io/im1.dcm ...  dicom/022/vnc/im1.dcm ...     masks/22.img ...
% by Karel Setnicka

% Clear the workspace
close all;
clear all;
clc

% Getting the names of patient folders with dicom files
cd dicom
patients = dir;
cd ..
dataset = zeros([70 83 40 2 80]); % 70x83x40 is maximal mask size

% For loop through all patients
for kk = 1:80
    folder = patients(kk+2).name;
    % Getting list of files in each folder (io, vnc)
    cd dicom
    cd(folder)
    cd io
    l_io = dir;
    cd ..
    cd vnc
    l_vnc = dir;
    cd ..
    cd ..
    cd ..
    
    % Creating empty variables for all dicom images
    d_io = zeros([512, 512, size(l_io,1)-2]);
    d_vnc = zeros([512, 512, size(l_vnc,1)-2]);
        
    % Reading all dicom images of current patient
    for ii = 1:size(l_io,1)-2
        % Loading images IODINE
        filename = ...
          ['dicom/' folder '/io/' l_io(ii+2).name];
        d_io(:,:,ii)  = dicomread(filename);
        % Loading images VNC
        filename = ...
          ['dicom/' folder '/vnc/' l_vnc(ii+2).name];
        d_vnc(:,:,ii) = dicomread(filename);
    end
    
    % Reading all masks
    filename = ['masks/' mat2str(str2num(['uint8(',folder,')'])) '.img'];
    fileID = fopen(filename);
    
    % Reshaping masks to be applicable to dicom images
    A_raw = fread(fileID);
    A_resize = reshape(A_raw, [512 512 size(A_raw,1)/(512*512)]) / 100;
    
    % Applying mask to all dicom images
    d_io = d_io .* A_resize;
    d_vnc = d_vnc .* A_resize;
    
    % Cutting zero matrices in each dimension
    er = 0;
    for hh = 1:size(d_io,1)
        if sum(sum(d_io(hh-er,:,:))) == 0
            d_io(hh-er,:,:) = [];
            d_vnc(hh-er,:,:) = [];
            er = er + 1;
        end
    end
    er = 0;
    for hh = 1:size(d_io,2)
        if sum(sum(d_io(:,hh-er,:))) == 0
            d_io(:,hh-er,:) = [];
            d_vnc(:,hh-er,:) = [];
            er = er + 1;
        end
    end
    er = 0;
    for hh = 1:size(d_io,3)
        if sum(sum(d_io(:,:,hh-er))) == 0
            d_io(:,:,hh-er) = [];
            d_vnc(:,:,hh-er) = [];
            er = er + 1;
        end
    end
    % Fitting ROI to the middle of cube
    % (dimensions are size of biggest mask)
    temp = zeros([70 83 40 2]);
    x1 = round((70-size(d_io, 1))/2)+1;
    x2 = round((83-size(d_io, 2))/2)+1;
    x3 = round((40-size(d_io, 3))/2)+1;
    temp(x1:x1+size(d_io,1)-1, x2:x2+size(d_io,2)-1, ...
            x3:x3+size(d_io,3)-1, 1) = d_io;
    temp(x1:x1+size(d_io,1)-1, x2:x2+size(d_io,2)-1, ...
            x3:x3+size(d_io,3)-1, 2) = d_io;
    % Saving current patient data sample to cumulative dataset variable
    dataset(:,:,:,:,kk) = temp;
end

% Save the dataset to .dat file    
ddat = transpose(reshape(dataset, [(70*83*40*2) 80]));
dlmwrite('IN_raw_input.dat',ddat,'delimiter','\t')
