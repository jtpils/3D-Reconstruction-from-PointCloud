function [model, pt_idx] = ransac(A, B, ransac_param)
% Args:
%   A, B: Point set A and B each with size m x n. m points with n
%         dimensions. [x, y, z]' for example.
%   ransac_param: Parameter setting for ransac algorithm 
% Returns:
%   model: Matrix containing Rotation and Translation matrix. [R, T; 0, 1]
%   pt_idx: vector of matched point indices 

sample_size = ransac_param.sample_size; % number of sample pairs to use
th_dist = ransac_param.th_dist; % distance threshold
itr_num = ransac_param.itr_num; % number of iteration
inl_ratio = ransac_param.inl_ratio;% inlier ratio

if sample_size < 3
    fprintf('Need more sample pairs to fit !\n');
    return
end

% transform to homogenous coord
match_num = size(A, 2);
A_homo = [A; ones(1, match_num)];
B_homo = [B; ones(1, match_num)];

if match_num < sample_size
    fprintf('Total pairs not enough !\n')
    return
end

inl_th = round(match_num*inl_ratio);
models = cell(1, itr_num);
inl_num = zeros(1, itr_num);

for i=1:1:itr_num
    sample_idx = rand_idx(match_num, sample_size); % return random index
    F = trans_solve_svd(A(:,sample_idx), B(:,sample_idx));
    dist = dist_cal(F*A_homo, B_homo);
    inl_idx = find(dist<th_dist);
    inl_num(i) = length(inl_idx);
    if length(inl_idx)<inl_th
        continue;
    end
    models{i} = F;
end

[num, idx] = max(inl_num);
if num < inl_th
    fprintf('Mo model meets success criteria !\n')
    return
end

model = models{idx};
dist = dist_cal(model*A_homo, B_homo);
pt_idx = find(dist < th_dist);

return