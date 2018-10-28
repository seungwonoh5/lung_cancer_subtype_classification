tmp = load_nii('216.hdr');
roi = tmp.img;
idx = find(roi(:) > 0);
[x, y, z] = ind2sub(size(roi), idx);
imagesc(roi(:,:,median(z)));
