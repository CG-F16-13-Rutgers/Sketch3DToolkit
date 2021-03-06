% Evaluation code for SHREC'13 and SHREC'14.
% Input:
%       rank list files (training or testing dataset)
%       classification files (training or testing dataset, target model dataset) 

% Output:
%       Precision Recall performance                         -- "PR.txt"
%       Other performance metrics (each model and average)   -- "Stats.txt"

% Evaluation measures:
%       NN, 1-Tier, 2-Tier, e_Measure, DCG, mAP

%% Setup variables.
setupvars;
[queryClass, ~] = read_classification_file(DATASET_CONFIG_SKETCH_FILE);
[targetClass, N] = read_classification_file(DATASET_CONFIG_MODEL_FILE);
targetClass(:, 1) = strcat('m', targetClass(:, 1));

%% Evaluate retrieval performance.
fprintf('Evaluating Rank Lists: %s.\n', RANK_DIR);

numQueries = size(queryClass, 1);
numTargets = size(targetClass, 1);
numClasses = size(N, 1);
  
for i = 1:numQueries 
    for j = 1:numClasses
        if (strcmp(queryClass{i, 2}, N{j, 1}) == 1)
            C(i, 1) = N{j, 2};
            break;
        end
    end
end

tic;
[P, AP, NN, FT, ST, DCG, E] = mexEvalRankLists(RANK_DIR, queryClass, targetClass, C);
mAP  = mean(AP); 
mNN  = mean(NN);
mFT  = mean(FT);
mST  = mean(ST);
mDCG = mean(DCG);
mE   = mean(E);
dt = toc;
fprintf('\nAP: %f\nNN: %f\nFT: %f\nST: %f\nDCG: %f\nE: %f\nIn %f minutes.\n', mAP, mNN, mFT, mST, mDCG, mE, dt / 60);

%% Save evaluation result to files.
fid = fopen(RANK_STATS_FILE, 'w');
fprintf(fid, '\t\t NN   \t FT   \t ST   \t E    \t DCG\n');
for i = 1:numQueries
    fprintf(fid, 'No.%d: %2.3f\t %2.3f\t %2.3f\t %2.3f\t %2.3f\n', i, NN(i), FT(i), ST(i), E(i), DCG(i));
end
fprintf(fid, 'NN   \t FT   \t ST   \t E    \t DCG    \t AP  \n');
fprintf(fid, '%2.3f\t %2.3f\t %2.3f\t %2.3f\t %2.3f\t %2.3f\n', mNN, mFT, mST, mE, mDCG, mAP);
fclose(fid);

fid = fopen(RANK_PRC_FILE, 'w');
fprintf(fid, 'Recall  \tPrecision\n');
fclose(fid);
Precision = CalAvgPerf(P, C, numQueries, RANK_PRC_FILE);
Recall = [1:20] / 20;

% Draw PR-Curves.
plot(Recall, Precision);
hold on;
plot(Recall, Precision, '*');
axis([0 1 0 1])
hold off;
xlabel('Precision'),ylabel('Recall')
