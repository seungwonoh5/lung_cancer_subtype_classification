%% 03/19/2018 Move file
% clear all; clc;
% load('\\115.145.181.76\homes\jhkim\180306_PII_add_data\Raw\sub.mat');
% 
% sfold = '\\115.145.181.76\homes\jhkim\180306_PII_add_data\Raw\';
% ffold = 'K:\PII-2_add_data\PII_added_dicom';
% 
% Gfold = 'GGO IODINE M-INS';
% Vfold = 'VNC-INS';
% 
% for i = 1:length(sub);
%     disp(strcat('Sub_',num2str(sub(i))))
%     mkdir(strcat(sfold,'Sub_',num2str(sub(i))))
%     savfol = strcat(sfold,'Sub_',num2str(sub(i)),'\');
%     
%     cd(strcat(ffold,'\',num2str(sub(i)),'-',Gfold,'\'))
%     tmp = dir('*.nii');
%     copyfile(tmp(1,1).name,savfol);
%     
%     cd(strcat(ffold,'\',num2str(sub(i)),'-',Vfold,'\'))
%     tmp2 = dir('*.nii');
%     copyfile(tmp2(1,1).name,savfol);
%     
%     % rename
%     cd(savfol);
%     movefile(tmp(1,1).name, strcat('Sub',num2str(sub(i)),'_GGO.nii'))
%     movefile(tmp2(1,1).name, strcat('Sub',num2str(sub(i)),'_VNC.nii'))
% %     movefile(strcat('Sub',num2str(sub(i)),'_GGO'),strcat('Sub',num2str(sub(i)),'_GGO.nii'))
% %     movefile(strcat('Sub',num2str(sub(i)),'_VNC'),strcat('Sub',num2str(sub(i)),'_VNC.nii'))
%     clear tmp* savfol
%     disp(strcat('Complete Sub',num2str(sub(i))))
% end

%%
clear all; clc;
addpath(genpath('C:\Users\jhkim\Documents\MATLAB\toolbox.added'));
load('\\115.145.181.76\homes\jhkim\180306_PII_add_data\Raw\sub.mat');

for i = 90:length(sub);
    view_window = [-190 263];
    view_window2 = [-190 263] + 1024; % window ����
    
    fpath = strcat('\\115.145.181.76\homes\jhkim\180306_PII_add_data\Raw\Sub_',num2str(sub(i,1)));
    fpath2 = strcat(fpath,'\Figure\');
    cd(fpath) % Move the file directory 'fpath'
    mkdir(fpath,'Figure'); % Generate folder
    % Load raw image
    data1 = load_nii(strcat('Sub',num2str(sub(i)),'_GGO.nii')); rGGO = data1.img;
    data2 = load_nii(strcat('Sub',num2str(sub(i)),'_VNC.nii')); rVNC = data2.img;
    rVNC = double(rVNC); rGGO = double(rGGO);
    
    % Load ROI
    if sub(i,2) == 1;
        flip_lr('ROI.hdr','flip_roi.nii'); data3 = load_nii('flip_roi.nii'); roi = data3.img;
        clear data1 data2 data3
        %         idx = find(roi(:) == 255); [x y z] = ind2sub(size(rVNC),idx);
        %         imagesc(rVNC(:,:,median(z))), figure, imagesc(rGGO(:,:,median(z))),...,
        %             figure, imagesc(roi(:,:,median(z)))
        %idx = find(roi(:) == 255); roi(idx) = 1; roi = double(roi);
        %tmp1 = rVNC.*roi; tmp2 = rGGO.*roi;
        %val = [max(rVNC(:)), max(rGGO(:)), max(tmp1(:)), max(tmp2(:));
        %    min(rVNC(:)), min(rGGO(:)), min(tmp1(:)), min(tmp2(:))];
        
        if ( min(rVNC(:)) < 0), rVNC = rVNC + 1024; end; % assume range [0 4095]
        if ( min(rGGO(:)) < 0), rGGO = rGGO + 100; end; % uncertain range [0 ?]cia
        
        % 2D jhist figure function
        pat_num = strcat('Sub',num2str(sub(i,1)));
        [hist rhist, gcen] = jhifigu(rGGO,rVNC,roi,fpath2,pat_num);
        save(strcat(pat_num,'_hist'),'hist') % save 512x512 jhist matrix
        save(strcat(pat_num,'_rhist'),'rhist') % save refined jhist matrix (151x50)
        save(strcat(pat_num,'_gcen'),'gcen') % save real value on jhist peak
        save(strcat(pat_num,'_val'),'val') % save min/max value within ROI
        clear hist rhist gcen val tmp* pat_num idx rGGO roi rVNC
    else
        for j = 1:sub(i,2);
            cd(fpath)
            fname = strcat('flip_roi_',num2str(j),'.nii');
            flip_lr(strcat('ROI_',num2str(j),'.hdr'), fname); data3 = load_nii(fname); roi = data3.img;
            clear data1 data2 data3 fname
            
            idx = find(roi(:) == 255); roi(idx) = 1; roi = double(roi);
            tmp1 = rVNC.*roi; tmp2 = rGGO.*roi;
            val = [max(rVNC(:)), max(rGGO(:)), max(tmp1(:)), max(tmp2(:));
                min(rVNC(:)), min(rGGO(:)), min(tmp1(:)), min(tmp2(:))];
            
            if ( min(rVNC(:)) < 0), rVNC = rVNC + 1024; end; % assume range [0 4095]
            if ( min(rGGO(:)) < 0), rGGO = rGGO + 100; end; % uncertain range [0 ?]cia
            
            % 2D jhist figure function
            pat_num = strcat('Sub',num2str(sub(i,1)),' R',num2str(j));
            [hist rhist, gcen] = jhifigu(rGGO,rVNC,roi,fpath2,pat_num);
            save(strcat(pat_num,'_hist_',num2str(j)),'hist')
            save(strcat(pat_num,'_rhist_',num2str(j)),'rhist')
            save(strcat(pat_num,'_gcen_',num2str(j)),'gcen')
            save(strcat(pat_num,'_val_',num2str(j)),'val')
            clear hist rhist gcen val tmp* pat_num idx roi
        end
        clear fpath* rGGO rVNC
    end
end

%% Other figure
clear all; clc;
addpath(genpath('C:\Users\jhkim\Documents\MATLAB\toolbox.added'));
addpath(genpath('\\115.145.181.76\homes\jhkim\180306_PII_add_data\texture\'));
load('\\115.145.181.76\homes\jhkim\180306_PII_add_data\Raw\sub.mat');

for i = 52:length(sub);
    fpath = strcat('\\115.145.181.76\homes\jhkim\180306_PII_add_data\Raw\Sub_',num2str(sub(i,1)));
    fpath2 = strcat(fpath,'\Figure\');
    cd(fpath)

    % Load raw image
    fname1 = strcat('Sub',num2str(sub(i)),'_GGO.nii'); fname1_2 = strcat('Sub',num2str(sub(i)),'_GGO_lr.nii');
    fname2 = strcat('Sub',num2str(sub(i)),'_VNC.nii'); fname2_2 = strcat('Sub',num2str(sub(i)),'_VNC_lr.nii');
    flip_lr(fname1,fname1_2); flip_lr(fname2,fname2_2);
    data1 = load_nii(strcat('Sub',num2str(sub(i)),'_GGO_lr.nii')); rGGO = data1.img;
    data2 = load_nii(strcat('Sub',num2str(sub(i)),'_VNC_lr.nii')); rVNC = data2.img;
    rVNC = double(rVNC); rGGO = double(rGGO);
    
    % Load ROI
    if sub(i,2) == 1;
        data3 = load_nii('ROI.hdr'); roi = data3.img;
        clear data1 data2 data3
        idx = find(roi(:) == 255); roi(idx) = 1; roi = double(roi);
        [idx_i, idx_j, idx_k] = ind2sub(size(roi),idx);
        inten_list = double(rGGO(idx));
        pat_num = strcat('Sub',num2str(sub(i,1)));
        piifig(rGGO,rVNC,roi,500,idx_k,inten_list,fpath2,pat_num);
        
    else
        for j = 1:sub(i,2);
            cd(fpath)
            fname = strcat('ROI_',num2str(j),'.hdr');
            data3 = load_nii(fname); roi = data3.img;
            clear data1 data2 data3 fname
            idx = find(roi(:) == 255); roi(idx) = 1; roi = double(roi);
            [idx_i, idx_j, idx_k] = ind2sub(size(roi),idx);
            inten_list = double(rGGO(idx));
            pat_num = strcat('Sub',num2str(sub(i,1)),' R',num2str(j));
            piifig(rGGO,rVNC,roi,500,idx_k,inten_list,fpath2,pat_num);
        end
    end
    close all
    clearvars -except sub i
end

