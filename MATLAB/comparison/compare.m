function comparisonData = compare
    index = UFget;
    j = 1;
    comparisonData = struct('avg_mongoose_times', [], ...
                            'avg_metis_times', [], ...
                            'rel_mongoose_times',  [], ...
                            'rel_metis_times', [], ...
                            'avg_mongoose_imbalance', [], ...
                            'avg_metis_imbalance', [], ...
                            'rel_mongoose_imbalance', [], ...
                            'rel_metis_imbalance', [], ...
                            'avg_mongoose_cut_size', [], ...
                            'avg_metis_cut_size', [], ...
                            'rel_mongoose_cut_size', [], ...
                            'rel_metis_cut_size', [], ...
                            'problem_id', [], ...
                            'problem_name', [], ...
                            'problem_nnz', [], ...
                            'problem_n', []);
    for i = 1:100%length(index.nrows)
        if (index.isReal(i))% && index.numerical_symmetry(i) && index.nnz(i) < 1E7)
            Prob = UFget(i);
            A = Prob.A;
            if (index.numerical_symmetry(i) < 1)
                [m, n] = size(A);
                A = [sparse(m,m) A; A' sparse(n,n)];
            end
            A = mongoose_sanitizeMatrix(A);
            if nnz(A) < 2
                continue
            end
            fprintf('Computing separator for %d: %s\n', i, Prob.name);
            
            comparisonData(j).problem_id = Prob.id;
            comparisonData(j).problem_name = Prob.name;
            comparisonData(j).problem_nnz = index.nnz(i);
            comparisonData(j).problem_n = index.ncols(i);

            % Sanitize the matrix: remove diagonal elements, check for positive edge
            % weights, and make sure it is symmetric.
            
            [~, n] = size(A);
            % Run Mongoose to partition the graph.
            for k = 1:5
                tic;
                partition = mongoose_computeEdgeSeparator(A);
                t = toc;
                fprintf('Mongoose: %0.2f\n', t);
                mongoose_times(j,k) = t;
                part_A = find(partition);
                part_B = find(1-partition);
                perm = [part_A part_B];
                p = length(partition);
                A_perm = A(perm, perm);
                mongoose_cut_size(j,k) = sum(sum(A_perm(p:n, 1:p)));
                mongoose_imbalance(j,k) = abs(0.5-sum(partition)/length(partition));
            end
            
            for k = 1:5
                tic;
                [perm,iperm] = metispart(A, 0, 123456789);
                t = toc;
                fprintf('METIS:    %0.2f\n', t);
                metis_times(j,k) = t;
                perm = [perm iperm];
                A_perm = A(perm, perm);
                metis_cut_size(j,k) = sum(sum(A_perm(p:n, 1:p)));
                metis_imbalance(j,k) = abs(0.5-length(perm)/(length(perm)+length(iperm)));
            end
            j = j + 1;
        end
    end
    
    n = length(mongoose_times);
    
    for i = 1:n
        comparisonData(i).avg_mongoose_times = max(1E-6, trimmean(mongoose_times(i,:), 40));
        comparisonData(i).avg_mongoose_cut_size = max(1E-6, trimmean(mongoose_cut_size(i,:), 40));
        comparisonData(i).avg_mongoose_imbalance = max(1E-6, trimmean(mongoose_imbalance(i,:), 40));
        
        comparisonData(i).avg_metis_times = max(1E-6, trimmean(metis_times(i,:), 40));
        comparisonData(i).avg_metis_cut_size = max(1E-6, trimmean(metis_cut_size(i,:), 40));
        comparisonData(i).avg_metis_imbalance = max(1E-6, trimmean(metis_imbalance(i,:), 40));
        
        min_time = min([comparisonData(i).avg_mongoose_times, comparisonData(i).avg_metis_times]);
        min_cut_size = min([comparisonData(i).avg_mongoose_cut_size, comparisonData(i).avg_metis_cut_size]);
        min_imbalance = min([comparisonData(i).avg_mongoose_imbalance, comparisonData(i).avg_metis_imbalance]);
        
        comparisonData(i).rel_mongoose_times = (comparisonData(i).avg_mongoose_times / min_time);
        comparisonData(i).rel_mongoose_cut_size = ((comparisonData(i).avg_mongoose_cut_size + 1) / (1 + min_cut_size));
        comparisonData(i).rel_mongoose_imbalance = (comparisonData(i).avg_mongoose_imbalance / min_imbalance);
        
        comparisonData(i).rel_metis_times = (comparisonData(i).avg_metis_times / min_time);
        comparisonData(i).rel_metis_cut_size = ((comparisonData(i).avg_metis_cut_size + 1) / (1 + min_cut_size));
        comparisonData(i).rel_metis_imbalance = (comparisonData(i).avg_metis_imbalance / min_imbalance);
        
        comparisonData(i).rel_mongoose_times2 = (comparisonData(i).avg_mongoose_times / comparisonData(i).avg_metis_times);
        comparisonData(i).rel_mongoose_cut_size2 = (comparisonData(i).avg_mongoose_cut_size / comparisonData(i).avg_metis_cut_size);
        
        if (comparisonData(i).rel_mongoose_times > 2)
            disp('outlier! Mongoose significantly worse.')
            i
        end
        if (comparisonData(i).rel_metis_times > 2)
            disp('outlier! METIS significantly worse.')
            i
        end
        
        if (comparisonData(i).rel_mongoose_cut_size > 100)
            disp('outlier! Mongoose cut size significantly worse.')
            comparisonData(i).avg_mongoose_cut_size
            comparisonData(i).avg_metis_cut_size
            comparisonData(i).problem_name
            prob_id = comparisonData(i).problem_id;
            Prob = UFget(prob_id);
            A = Prob.A;
            if (index.numerical_symmetry(prob_id) < 1)
                [m, n] = size(A);
                A = [sparse(m,m) A; A' sparse(n,n)];
            end
            A = mongoose_sanitizeMatrix(A);
            partition = mongoose_computeEdgeSeparator(A);
            part_A = find(partition);
            part_B = find(1-partition);
            perm = [part_A part_B];
            p = length(partition);
            A_perm = A(perm, perm);
            subplot(1,2,1);
            hold on;
            spy(A);
            subplot(1,2,2);
            spy(A_perm);
            hold off;
            mongoose_separator_plot(A, partition, 1-partition, ['mongoose_outlier_' num2str(comparisonData(i).problem_id)]);
            [perm, ~] = metispart(A, 0, 123456789);
            [m, ~] = size(A);
            partition = zeros(m,1);
            for j = 1:m
                partition(j,1) = sum(sign(find(j == perm)));
            end
            mongoose_separator_plot(A, partition, 1-partition, ['metis_' num2str(comparisonData(i).problem_id)]);
        end
        if (comparisonData(i).rel_metis_cut_size > 100)
            disp('outlier! METIS cut size significantly worse.')
            comparisonData(i).avg_mongoose_cut_size
            comparisonData(i).avg_metis_cut_size
            comparisonData(i).problem_name
        end
    end
    
    sorted_rel_mongoose_times = sort([comparisonData.rel_mongoose_times]);
    sorted_rel_mongoose_cut_size = sort([comparisonData.rel_mongoose_cut_size]);
    sorted_avg_mongoose_imbalance = sort([comparisonData.avg_mongoose_imbalance]);
    
    sorted_rel_metis_times = sort([comparisonData.rel_metis_times]);
    sorted_rel_metis_cut_size = sort([comparisonData.rel_metis_cut_size]);
    sorted_avg_metis_imbalance = sort([comparisonData.avg_metis_imbalance]);
    
    sorted_rel_mongoose_times2 = sort([comparisonData.rel_mongoose_times2]);
    sorted_rel_mongoose_cut_size2 = sort([comparisonData.rel_mongoose_cut_size2]);
    
    % Get the Git commit hash for labeling purposes
    [error, commit] = system('git rev-parse --short HEAD');
    commit = strtrim(commit);
    
    % Plot timing profiles
%     figure;
%     plot(sorted_rel_mongoose_times, 1:n, 'Color', 'b');
%     hold on;
%     plot(sorted_rel_metis_times, 1:n, 'Color','r');
%     hold off;
    
    filename = ['Timing' date];
    if(~error)
        title(['Timing Profile - Commit ' commit]);
        filename = ['Timing-' commit];
    end
    %print(filename,'-dpng');
    
    figure;
    plot(1:n, sorted_rel_mongoose_times2, 'Color', 'b');
    hold on;
    plot(1:n, ones(1,n), 'Color','r');
    axis([1 n min(sorted_rel_mongoose_times2) max(sorted_rel_mongoose_times2)]);
    xlabel('Matrix');
    ylabel('Wall Time Relative to METIS');
    hold off;
    
    filename = ['Timing2' date];
    if(~error)
        title(['Timing Profile - Commit ' commit]);
        filename = ['Timing2-' commit];
    end
    print(filename,'-dpng');
    
    plt = Plot();
    plt.LineStyle = {'-', '--'};
    plt.Legend = {'Mongoose', 'METIS'};
    plt.BoxDim = [6, 5];
    
    plt.export([filename '.png']);
    
    % Plot cut size profiles
%     figure;
%     plot(sorted_rel_mongoose_cut_size, 1:n, 'Color', 'b');
%     hold on;
%     plot(sorted_rel_metis_cut_size, 1:n, 'Color','r');
%     axis([0 100 1 n]);
%     hold off;
    
    filename = ['SeparatorSize' date];
    if(~error)
        title(['Separator Size Profile - Commit ' commit]);
        filename = ['SeparatorSize-' commit];
    end
    %print(filename,'-dpng');
    
    figure;
    semilogy(1:n, sorted_rel_mongoose_cut_size2, 'Color', 'b');
    hold on;
    semilogy(1:n, ones(1,n), 'Color','r');
    axis([1 n min(sorted_rel_mongoose_cut_size2) max(sorted_rel_mongoose_cut_size2)]);
    xlabel('Matrix');
    ylabel('Cut Size Relative to METIS');
    hold off;
    
    plt = Plot();
    plt.LineStyle = {'-', '--'};
    plt.Legend = {'Mongoose', 'METIS'};
    plt.BoxDim = [6, 5];
    
    plt.export([filename '.png']);
    
    % Plot imbalance profiles
    figure;
    plot(1:n, sorted_avg_mongoose_imbalance, 'Color', 'b');
    hold on;
    plot(1:n, sorted_avg_metis_imbalance, 'Color','r');
    axis([1 n 0 0.3]);
    xlabel('Matrix');
    ylabel('Imbalance');
    hold off;
    
    filename = ['Imbalance' date];
    if(~error)
        title(['Imbalance Profile - Commit ' commit]);
        filename = ['Imbalance-' commit];
    end
    print(filename,'-dpng');
    
    plt = Plot();
    plt.LineStyle = {'-', '--'};
    plt.Legend = {'Mongoose', 'METIS'};
    plt.BoxDim = [6, 5];
    
    plt.export([filename '.png']);
    
    max(comparisonData(i).rel_mongoose_times)
    max(comparisonData(i).rel_metis_times)
    
    if(~error)
        writetable(struct2table(comparisonData), [commit '.txt']);
    end
end