classdef GeneticAlgorithm < handle
    properties
        individuals_number
        genes_number
        generations_number
        termination_type
        initialization_type
        parents_selection_type
        tournament_size
        crossover_type
        crossover_rate
        crossover_points_number
        mutation_type
        mutation_rate
        survivor_selection_type
        elitism
                
        problem
        best_individual
        population
        mating_pool
        offspring
        current_generation
    end
    methods
        function self = GeneticAlgorithm(problem)
            properties = ini2struct('algorithm.ini');
            
            self.individuals_number = str2double(...
                properties.individualsnumber);
            self.generations_number = str2double(...
                properties.generationsnumber);
            self.termination_type = str2double(...
                properties.terminationconditiontype);
            self.initialization_type = str2double(...
                properties.initializationtype);
            self.parents_selection_type = str2double(...
                properties.parentselectiontype);
            self.crossover_points_number = str2double(...
                properties.crossoverpointsnumber);
            self.survivor_selection_type = str2double(...
                properties.survivorselectiontype);
            self.genes_number = str2double(properties.genesnumber);
            self.tournament_size = str2double(properties.tournamentsize);
            self.crossover_type = str2double(properties.crossovertype);
            self.crossover_rate = str2double(properties.crossoverrate);
            self.mutation_type = str2double(properties.mutationtype);
            self.mutation_rate = str2double(properties.mutationrate);
            self.elitism = str2double(properties.elitism);
        
            self.problem = problem;
            self.best_individual = Individual(problem.individuals_size);
            self.population = ArrayHandler;
            self.population.x = Individual.empty(self.individuals_number,0);
            self.mating_pool = ArrayHandler;
            self.mating_pool.x = Individual.empty(self.individuals_number,0);
            self.offspring = ArrayHandler;
            self.offspring.x = Individual.empty(self.individuals_number,0);
            self.current_generation = 0;
            
            if mod(self.individuals_number, 2) ~= 0
                error('[!] "IndividualsNumber" property value must be even.')
            end
        end
        
        function best_individual = run(self)
            tic;
            self.initialize();
            self.evaluate(self.problem, self.population);
            while self.termination_condition() ~= 1
                self.select_parents();
                self.recombine();
                self.mutate();
                self.evaluate(self.problem, self.offspring);
                [self.population, self.best_individual] = self.survivor_selection();

                self.current_generation = self.current_generation + 1;
                self.current_generation
            end
            
            toc;
        end
        
        function initialize(self)
            if self.initialization_type == 1
                self.random_initialization(self.individuals_number,...
                                           self.problem.alleles,...
                                           self.population,...
                                           self.genes_number);
            else
                error('[!] Value specified by "InitializationType"'...
                         + 'property does not mach with any'...
                         + 'initialization type')
            end
        end
        
        function population = random_initialization(~, individuals_number,...
                                       alleles, population, genes_number)
            for i = 1:individuals_number
                individual = Individual(genes_number);
                for j = 1:genes_number
                    allele = alleles(randperm(numel(alleles), 1));
                    individual.genes(j) = allele;
                end
                population.x(i) = individual;
            end
        end
        
        function evaluate(~, problem, individuals)
            for i = 1:numel(individuals.x)
                individuals.x(i).fitness = problem.get_fitness(individuals.x(i));
            end
            [~, sort_order] = sort([individuals.x.fitness], 'descend');
            individuals.x = individuals.x(sort_order);
        end
        
        function finish = termination_condition(self)
            if self.termination_type == 1
                finish = self.generations_number_condition(...
                                        self.generations_number,...
                                        self.current_generation);
            elseif self.termination_type == 2
                finish = self.fitness_repetition(self.best_individual,...
                                                 self.generations_number);
            end
        end
        
        function finish = generations_number_condition(~,...
                                             maximum_generations_number,...
                                             current_generation)
            finish = 0;
            if maximum_generations_number == current_generation
            	finish = 1;
            end
        end
        
        function finish = fitness_repetition(~, best_individual,... 
                                            maximum_generations_number)
            finish = 0;
            if maximum_generations_number == best_individual.age
                finish = 1;
            end
        end
        
        function select_parents(self)
            if self.parents_selection_type == 1
                for i = 1:self.individuals_number
                    self.tournament_selection(self.tournament_size,...
                                              self.population.x,...
                                              self.mating_pool,...
                                              i);
                end
            else
                error('[!] Value specified by "ParentSelectionType"'...
                         + 'property does not mach with any'...
                         + 'parent selection type')
            end
        end
        
        function tournament_selection(~, tournament_size, population,...
                                      mating_pool,...
                                      mating_pool_index)
            tournament = population(randperm(numel(population),...
                                             tournament_size));
            [~, parent_index] = max([tournament.fitness]);
            mating_pool.x(mating_pool_index) = tournament(parent_index);
        end
            
        function recombine(self)
            for i = 1:2:numel(self.mating_pool.x)
                parent_1 = self.mating_pool.x(i);
                parent_2 = self.mating_pool.x(i+1);

                if self.crossover_type == 1
                    self.cross_n_points(parent_1, parent_2,...
                                        self.crossover_rate,...
                                        self.crossover_points_number,...
                                        self.offspring, i);
                else
                    error('[!] Value specified by "CrossoverType"'...
                         + 'property does not mach with any'...
                         + 'recombination type')
                end
            end
        end
        
        function cross_n_points(~, parent_1, parent_2, crossover_rate,...
                                points_number, offspring,...
                                recombination_index)
            random_rate = rand();
            child_1 = Individual(0);
            child_2 = Individual(0);
            switch_ = 0;

            if random_rate <= crossover_rate
                points = randperm(numel(parent_1.genes), points_number);
                if ismember(numel(parent_1.genes), points) ~= 1
                    points(numel(points)+1) = numel(parent_1.genes);
                end
                points = sort(points);
                last_point = 1;
                for point = points
                    if switch_ == 1
                        child_1.genes = [child_1.genes parent_1.genes(...
                                                        last_point:point)];
                        child_2.genes = [child_2.genes parent_2.genes(...
                                                        last_point:point)];
                    else
                        child_1.genes = [child_1.genes parent_2.genes(...
                                                        last_point:point)];
                        child_2.genes = [child_2.genes parent_1.genes(...
                                                        last_point:point)];
                    end
                    switch_ = ~switch_;
                    last_point = point+1;
                end
            else
                child_1 = parent_1;
                child_2 = parent_2;
 
            end
            offspring.x(recombination_index) = child_1;
            offspring.x(recombination_index+1) = child_2;
        end
            
        function mutate(self)
            if self.mutation_type == 1
                for i = 1:numel(self.offspring.x)
                    self.offspring.x(i) = self.probabilistic_mutation(...
                                                    self.offspring.x(i),...
                                                    self.mutation_rate,...
                                                    self.problem.alleles);
                end
            else
                error('[!] Value specified by "MutationType"'...
                         + 'property does not mach with any'...
                         + 'mutation type')
            end
        end
        
        function child = probabilistic_mutation(~, child,...
                                                    mutation_rate, alleles)
            for i = 1:numel(child.genes)
                random_rate = rand();
                if random_rate <= mutation_rate
                    possible_alleles = alleles;
                    possible_alleles(find(possible_alleles ==...
                                          child.genes(i))) = [];
                    child.genes(i) = possible_alleles(randperm(numel(...
                                                    possible_alleles), 1));
                end
            end
        end
            
        function [population, best_individual] = survivor_selection(self)
            if self.survivor_selection_type == 1
                [population, best_individual] = self.generational_selection(...
                                                     self.population,...
                                                     self.offspring,...
                                                     self.best_individual);
            else
                error('[!] Value specified by "SurvivorSelectionType"'...
                         + 'property does not mach with any'...
                         + 'survivor selection type')
            end
        end
        
        function [offspring, best_individual] = generational_selection(...
                                                        ~, population,...
                                                        offspring,...
                                                        best_individual)
            if best_individual.fitness >= offspring.x(1).fitness
                offspring.x(end) = best_individual;
                best_individual.age = best_individual.age + 1;
            else
                best_individual = offspring.x(1);
            end
        end
        
            
        
        
    end
    
end

