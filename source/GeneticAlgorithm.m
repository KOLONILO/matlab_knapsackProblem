classdef GeneticAlgorithm
    properties
        problem
        best_individual
        population
        mating_pool
        offspring
        current_generation
        
        start_time
        finish_time
        
        
    end
    methods
        function self = GeneticAlgorithm(problem)
            self.problem = problem;
            self.best_individual = Individual(problem.individuals_size);
            self.population = Individual(problem.individuals_size).empty(x);
            self.mating_pool = Individual(problem.individuals_size).empty(x);
            self.offspring = Individual(problem.individuals_size).empty(x);
            self.current_generation = 0;

            self.start_time = 0;
            self.finish_time = 0;
        end
    end
    
end

