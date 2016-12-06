
function knapsack_problem_solver(file_path)
    [items, knapsacks_capacity] = read_data_file(file_path);
    knapsack_problem = KnapsackProblem(knapsacks_capacity, items);
    genetic_algorithm = GeneticAlgorithm(knapsack_problem);
    genetic_algorithm.run();
end

function [items, individual_size] = read_data_file(file_path)
    data = csvread(file_path);
    individual_size = data(1, 1);
    data(1, :) = [];
    items = Item(0,0).empty(size(data, 1), 0);
    
    for i = 1:size(items);
        items(i) = Item(data(i,1), data(i,2));
        items(i);
    end
end